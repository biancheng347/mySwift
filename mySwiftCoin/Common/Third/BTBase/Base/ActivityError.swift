//
//  ActivityError.swift
//  vskit
//
//  Created by jackwang on 2025/4/27.
//

import Foundation
import RxSwift
import RxCocoa



public class ErrorWorker: ObservableConvertibleType, WeakHandleProtocol {
    public typealias Element = Error
    private  lazy var _subject = PublishSubject<Error>()
    
    public func asObservable() -> Observable<Error> {
        _subject
    }
    
    deinit { _subject.onCompleted() }
}

fileprivate extension ErrorWorker {
    func onError(error: Error) {
        _subject.onNext(error)
    }
}

extension ErrorWorker {
    public func trackErrorWorker<O: ObservableConvertibleType>(from source: O) -> Observable<O.Element> {
        return source.asObservable().do(onError: weakHandle { this, error in this?.onError(error: error) })
            }
}

extension ObservableConvertibleType {
    public func trackError(_ errorWorker: ErrorWorker) -> Observable<Element> {
        return errorWorker.trackErrorWorker(from: self)
    }
}
