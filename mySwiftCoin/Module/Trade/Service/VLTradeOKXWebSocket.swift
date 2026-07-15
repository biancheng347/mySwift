import Foundation
import RxSwift
import RxRelay

/// OKX 公共行情 WebSocket：建连成功后再订阅；TLS 失败轮换端点。
final class VLTradeOKXWebSocket: NSObject {

    /// 最新 ticker。
    private(set) lazy var tickerPublisher = PublishRelay<VLTradeTickerModel>()
    /// 最新盘口。
    private(set) lazy var orderBookPublisher = PublishRelay<VLTradeOrderBookModel>()
    /// 连接状态（true = 已握手并订阅）。
    private(set) lazy var connectedPublisher = BehaviorRelay<Bool>(value: false)

    /// 主备频道：8443 失败时再试 443（省略端口）。
    private let endpoints: [URL] = [
        URL(string: "wss://ws.okx.com:8443/ws/v5/public")!,
        URL(string: "wss://ws.okx.com/ws/v5/public")!
    ]
    private var endpointIndex = 0
    private var session: URLSession?
    private var task: URLSessionWebSocketTask?
    private var bookInstId: String?
    private var tickerInstIds: [String] = []
    private var isListening = false
    private var reconnectWork: DispatchWorkItem?
    private let lock = NSLock()
    private let delegateQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "VLTradeOKXWebSocket"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    deinit {
        disconnect()
    }

    /// 订阅：BTC+ETH ticker，当前币对 books5。
    func subscribe(bookInstId: String, tickerInstIds: [String]) {
        let tickers = Array(Set(tickerInstIds + [bookInstId])).sorted()
        lock.lock()
        let same = self.bookInstId == bookInstId
            && self.tickerInstIds == tickers
            && task != nil
            && connectedPublisher.value
        self.bookInstId = bookInstId
        self.tickerInstIds = tickers
        lock.unlock()
        if same {
            sendSubscribe()
            return
        }
        reconnect()
    }

    /// 兼容单币对订阅。
    func subscribe(instId: String) {
        subscribe(bookInstId: instId, tickerInstIds: [instId])
    }

    /// 断开并清理。
    func disconnect() {
        lock.lock()
        isListening = false
        bookInstId = nil
        tickerInstIds = []
        reconnectWork?.cancel()
        reconnectWork = nil
        task?.cancel(with: .goingAway, reason: nil)
        task = nil
        session?.invalidateAndCancel()
        session = nil
        lock.unlock()
        connectedPublisher.accept(false)
    }
}

fileprivate extension VLTradeOKXWebSocket {

    /// 重建连接（握手成功后再发 subscribe）。
    func reconnect() {
        disconnectSoft()
        lock.lock()
        let hasTarget = bookInstId != nil
        lock.unlock()
        guard hasTarget else { return }

        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        let session = URLSession(configuration: config, delegate: self, delegateQueue: delegateQueue)
        let url = endpoints[endpointIndex % endpoints.count]
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        let task = session.webSocketTask(with: request)
        self.session = session
        self.task = task
        isListening = true
        #if DEBUG
        print("[VLTradeOKXWebSocket] connecting \(url.absoluteString)")
        #endif
        task.resume()
        listen()
        scheduleHandshakeTimeout()
    }

    /// 仅关掉旧 socket，保留目标 instId。
    func disconnectSoft() {
        reconnectWork?.cancel()
        reconnectWork = nil
        isListening = false
        task?.cancel(with: .goingAway, reason: nil)
        task = nil
        session?.invalidateAndCancel()
        session = nil
        connectedPublisher.accept(false)
    }

    /// 握手超时换下一端点。
    func scheduleHandshakeTimeout() {
        let work = DispatchWorkItem { [weak self] in
            guard let self, self.isListening, !self.connectedPublisher.value else { return }
            #if DEBUG
            print("[VLTradeOKXWebSocket] handshake timeout, rotate endpoint")
            #endif
            self.endpointIndex += 1
            self.scheduleReconnect(delay: 0.3)
        }
        reconnectWork = work
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 8, execute: work)
    }

    /// 发送订阅（须在 didOpen 之后）。
    func sendSubscribe() {
        lock.lock()
        let book = bookInstId
        let tickers = tickerInstIds
        lock.unlock()
        guard let book else { return }
        var args: [[String: String]] = tickers.map {
            ["channel": "tickers", "instId": $0]
        }
        args.append(["channel": "books5", "instId": book])
        let payload: [String: Any] = ["op": "subscribe", "args": args]
        guard let data = try? JSONSerialization.data(withJSONObject: payload),
              let text = String(data: data, encoding: .utf8) else { return }
        task?.send(.string(text)) { [weak self] error in
            if let error {
                #if DEBUG
                print("[VLTradeOKXWebSocket] subscribe failed \(error.localizedDescription)")
                #endif
                self?.connectedPublisher.accept(false)
                self?.scheduleReconnect(delay: 2)
                return
            }
            self?.connectedPublisher.accept(true)
        }
    }

    /// 循环收消息；只处理「当前 task」的回调，避免 cancel 旧连接误触发重连风暴。
    func listen() {
        guard isListening, let task else { return }
        task.receive { [weak self] result in
            guard let self else { return }
            // 旧 task 被 disconnectSoft 取消后，回调可能晚于新连接把 isListening 置回 true
            guard task === self.task, self.isListening else { return }
            switch result {
            case .success(let message):
                self.handle(message: message)
                self.listen()
            case .failure(let error):
                if Self.isCancellation(error) { return }
                #if DEBUG
                print("[VLTradeOKXWebSocket] receive failed \(error.localizedDescription)")
                #endif
                self.connectedPublisher.accept(false)
                self.endpointIndex += 1
                self.scheduleReconnect(delay: 2)
            }
        }
    }

    /// 主动 cancel / invalidate 产生的错误，不应轮换端点重连。
    static func isCancellation(_ error: Error) -> Bool {
        if let urlError = error as? URLError, urlError.code == .cancelled { return true }
        let ns = error as NSError
        return ns.domain == NSURLErrorDomain && ns.code == NSURLErrorCancelled
    }

    /// 失败后重连。
    func scheduleReconnect(delay: TimeInterval) {
        reconnectWork?.cancel()
        let work = DispatchWorkItem { [weak self] in
            guard let self else { return }
            self.lock.lock()
            let book = self.bookInstId
            self.lock.unlock()
            guard book != nil else { return }
            self.reconnect()
        }
        reconnectWork = work
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + delay, execute: work)
    }

    /// 分发文本帧。
    func handle(message: URLSessionWebSocketTask.Message) {
        let text: String?
        switch message {
        case .string(let value): text = value
        case .data(let data): text = String(data: data, encoding: .utf8)
        @unknown default: text = nil
        }
        guard let text else { return }
        if text == "ping" {
            task?.send(.string("pong")) { _ in }
            return
        }
        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }
        if let event = json["event"] as? String {
            if event == "error" {
                #if DEBUG
                print("[VLTradeOKXWebSocket] error \(json["msg"] ?? "")")
                #endif
            }
            return
        }
        guard let arg = json["arg"] as? [String: Any],
              let channel = arg["channel"] as? String,
              let rows = json["data"] as? [[String: Any]],
              let first = rows.first else { return }
        switch channel {
        case "tickers":
            if let ticker = VLTradeOKXMapper.ticker(from: first) {
                tickerPublisher.accept(ticker)
            }
        case "books5":
            if let book = VLTradeOKXMapper.orderBook(from: first) {
                orderBookPublisher.accept(book)
            }
        default:
            break
        }
    }
}

extension VLTradeOKXWebSocket: URLSessionWebSocketDelegate {

    /// 握手完成后再订阅。
    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol protocol: String?
    ) {
        guard webSocketTask === task else { return }
        reconnectWork?.cancel()
        #if DEBUG
        print("[VLTradeOKXWebSocket] opened")
        #endif
        sendSubscribe()
    }

    /// 对端关闭。
    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?
    ) {
        guard webSocketTask === task else { return }
        connectedPublisher.accept(false)
        endpointIndex += 1
        scheduleReconnect(delay: 2)
    }

    /// TLS / 传输层失败（忽略主动 cancel）。
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        guard task === self.task, let error else { return }
        if Self.isCancellation(error) { return }
        #if DEBUG
        print("[VLTradeOKXWebSocket] complete error \(error.localizedDescription)")
        #endif
        connectedPublisher.accept(false)
        endpointIndex += 1
        scheduleReconnect(delay: 2)
    }
}
