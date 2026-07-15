
import UIKit


//MARK:- GCD
public var Main: DispatchQueue {
    return DispatchQueue.main
}

public var Global: DispatchQueue {
    return DispatchQueue.global()
}

public extension String {
    var asyncQueue: DispatchQueue {
        return DispatchQueue(label: self, qos: .default, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
    }
}

public func After(isMain: Bool, delay: Double, _ closure: @escaping () -> Void) {
    let dispatchQueue = isMain ? Main : Global
    dispatchQueue.asyncAfter(deadline: .now() + delay, execute: closure)
}

public func MainAsync(_ closure: @escaping () -> Void) {
    if Thread.isMainThread { closure() }
    else { Main.async(execute: closure) }
}

public func GlobalAsync(_ closure: @escaping () -> Void) {
    if !Thread.isMainThread { closure() }
    else { Global.async(execute: closure) }
}

public func Group(_ closure: (DispatchGroup) ->(), isMain: Bool, notify: @escaping () -> Void) {
    let g = DispatchGroup()
    closure(g)
    g.notify(queue: isMain ? Main : Global, execute: notify)
}

public func Time(_ interval: TimeInterval, isMain: Bool, _ closure: @escaping () -> Bool) {
    let timer = DispatchSource.makeTimerSource(queue: isMain ? Main : Global)
    timer.schedule(deadline: .now() + interval, repeating: interval)
    timer.setEventHandler { if closure() { timer.cancel() } }
    timer.resume()
}

public func Apply(_ iterations: Int, _ closure: (Int) -> Void) {
    __dispatch_apply(iterations, DispatchQueue.global(), closure)
}

public func Barrier(_ label: String,
                    _ before: (DispatchQueue) -> Void,
                    barrier: @escaping () -> Void,
                    _ after: (DispatchQueue) -> Void) {
    let q = label.asyncQueue
    before(q)
    __dispatch_barrier_async(q, barrier) // 1-10 并发完成 barrier 执行  11-20 在并发执行() //要自定义并发 队列 才行
    after(q)
}





public extension Bool {
    func async(_ closure: @escaping () -> Void) {
        let dispatchQueue = self ? Main : Global
        dispatchQueue.async(execute: closure)
    }
}

