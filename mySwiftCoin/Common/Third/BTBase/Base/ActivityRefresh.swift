//
//  ActivityRefresh.swift
//  vanlink
//
//  Created by jackwang on 2025/6/19.
//

import Foundation
import RxSwift
import RxCocoa

public class RefreshWorker: ObservableConvertibleType, WeakHandleProtocol {
    public typealias Element = Void
    private lazy var _subject = PublishSubject<Void>()
    
    public func asObservable() -> Observable<Void> {
        _subject
    }
    
    deinit { _subject.onCompleted() }
}

extension RefreshWorker {
    func onRefresh() {
        _subject.onNext(())
    }
}

extension RefreshWorker {
    /// 追踪刷新事件：无论 onNext/onError 都发出信号
    public func trackRefreshWorker<O: ObservableConvertibleType>(from source: O) -> Observable<O.Element> {
        return source.asObservable()
            .do(
                onNext: weakHandle { this, _ in this?.onRefresh() },
                onError: weakHandle { this, _ in this?.onRefresh() },
                onCompleted: weakHandle { this in this?.onRefresh() }
            )
    }
}

extension ObservableConvertibleType {
    /// 用于上层链式调用
    public func trackRefresh(_ refreshWorker: RefreshWorker) -> Observable<Element> {
        return refreshWorker.trackRefreshWorker(from: self)
    }
}
