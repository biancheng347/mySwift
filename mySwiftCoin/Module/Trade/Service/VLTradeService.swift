import Foundation
import RxSwift

/// 交易页数据源：OKX REST 优先，失败回落 mock；实时价走 WebSocket。
final class VLTradeService {

    /// 是否启用真实 OKX REST（单测可关）。
    var useLiveREST: Bool

    /// 注入；默认走真实 REST。
    init(useLiveREST: Bool = true) {
        self.useLiveREST = useLiveREST
    }

    /// 拉取 ticker（OKX REST → mock）。
    func getTicker(symbol: String, category: VLTradeCategory = .spot) -> Observable<VLTradeTickerModel> {
        let mock = delayedJust(mockTicker(symbol: symbol), after: 0.15)
        guard useLiveREST else { return mock }
        let instId = VLTradeOKXMapper.instId(for: category, symbol: symbol)
        return fetchOKXTicker(instId: instId).catchError { _ in mock }
    }

    /// 拉取指定周期 K 线（OKX REST → mock）。
    func getCandles(
        symbol: String,
        timeframe: VLTradeTimeframe,
        category: VLTradeCategory = .spot
    ) -> Observable<[VLTradeCandleModel]> {
        let mock = delayedJust(mockCandles(symbol: symbol, timeframe: timeframe), after: 0.2)
        guard useLiveREST else { return mock }
        let instId = VLTradeOKXMapper.instId(for: category, symbol: symbol)
        return fetchOKXCandles(instId: instId, bar: timeframe.okxBar).catchError { _ in mock }
    }

    /// 拉取盘口（OKX REST books → mock；实时优先进 WS）。
    func getOrderBook(symbol: String, category: VLTradeCategory = .spot) -> Observable<VLTradeOrderBookModel> {
        let mock = category == .futures
            ? mockFuturesOrderBook(symbol: symbol)
            : mockOrderBook(symbol: symbol)
        let mockObs = delayedJust(mock, after: 0.15)
        guard useLiveREST else { return mockObs }
        let instId = VLTradeOKXMapper.instId(for: category, symbol: symbol)
        return fetchOKXBooks(instId: instId).catchError { _ in mockObs }
    }

    /// 拉取底部持仓/委托/资产 mock。
    func getAccountSnapshot(
        symbol: String,
        category: VLTradeCategory
    ) -> Observable<VLTradeAccountSnapshotModel> {
        let snap = category == .futures
            ? mockFuturesAccount(symbol: symbol)
            : mockSpotAccount(symbol: symbol)
        return delayedJust(snap, after: 0.12)
    }

    /// 延迟发射，便于 Rx 测试取消 in-flight。
    private func delayedJust<T>(_ value: T, after seconds: TimeInterval) -> Observable<T> {
        Observable.create { observer in
            let work = DispatchWorkItem {
                observer.onNext(value)
                observer.onCompleted()
            }
            DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + seconds, execute: work)
            return Disposables.create { work.cancel() }
        }
    }
}
