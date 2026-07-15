import Foundation
import RxSwift

/// OKX 公共 REST：ticker / candles / books（优先 openapi，失败回落 www）。
extension VLTradeService {

    /// REST API 主机列表。
    private static let restHosts = [
        "https://openapi.okx.com",
        "https://www.okx.com"
    ]

    /// REST 拉取最新 ticker。
    func fetchOKXTicker(instId: String) -> Observable<VLTradeTickerModel> {
        fetchOKXFirstSuccess(paths: Self.restHosts.map {
            "\($0)/api/v5/market/ticker?instId=\(instId)"
        }).map { json in
            let rows = json["data"] as? [[String: Any]] ?? []
            guard let first = rows.first,
                  let ticker = VLTradeOKXMapper.ticker(from: first) else {
                throw VLTradeOKXError.invalidPayload
            }
            return ticker
        }
    }

    /// REST 拉取盘口（sz=5 对齐 books5）。
    func fetchOKXBooks(instId: String, size: Int = 5) -> Observable<VLTradeOrderBookModel> {
        fetchOKXFirstSuccess(paths: Self.restHosts.map {
            "\($0)/api/v5/market/books?instId=\(instId)&sz=\(size)"
        }).map { json in
            let rows = json["data"] as? [[String: Any]] ?? []
            guard let first = rows.first,
                  let book = VLTradeOKXMapper.orderBook(from: first) else {
                throw VLTradeOKXError.invalidPayload
            }
            return book
        }
    }

    /// REST 拉取 K 线（最多 100 根）。
    func fetchOKXCandles(instId: String, bar: String, limit: Int = 100) -> Observable<[VLTradeCandleModel]> {
        fetchOKXFirstSuccess(paths: Self.restHosts.map {
            "\($0)/api/v5/market/candles?instId=\(instId)&bar=\(bar)&limit=\(limit)"
        }).map { json in
            let rows = (json["data"] as? [[Any]] ?? []).compactMap { row -> [String]? in
                let strings = row.map { "\($0)" }
                return strings.count >= 6 ? strings : nil
            }
            let candles = VLTradeOKXMapper.candles(from: rows)
            guard !candles.isEmpty else { throw VLTradeOKXError.invalidPayload }
            return candles
        }
    }

    /// 依次尝试多个 URL，取第一个成功响应。
    func fetchOKXFirstSuccess(paths: [String]) -> Observable<[String: Any]> {
        let urls = paths.compactMap(URL.init(string:))
        guard !urls.isEmpty else {
            return .error(VLTradeOKXError.invalidPayload)
        }
        return fetchOKXJSON(url: urls[0])
            .catchError { error -> Observable<[String: Any]> in
                guard urls.count > 1 else { return .error(error) }
                return self.fetchOKXJSON(url: urls[1])
            }
    }

    /// 通用 OKX JSON GET。
    func fetchOKXJSON(url: URL) -> Observable<[String: Any]> {
        Observable.create { observer in
            var request = URLRequest(url: url)
            request.timeoutInterval = 15
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error {
                    observer.onError(error)
                    return
                }
                guard let data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      (json["code"] as? String) == "0" else {
                    observer.onError(VLTradeOKXError.invalidPayload)
                    return
                }
                observer.onNext(json)
                observer.onCompleted()
            }
            task.resume()
            return Disposables.create { task.cancel() }
        }
    }
}

/// OKX REST 解析失败。
enum VLTradeOKXError: Error {
    case invalidPayload
}
