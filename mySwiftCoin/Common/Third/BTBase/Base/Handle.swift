import ObjectiveC

public protocol WeakHandleProtocol: AnyObject {}
extension NSObject: WeakHandleProtocol {}


public extension WeakHandleProtocol  {
    func weakHandle(_ closure: @escaping (Self?) -> Void) -> () -> Void {
        weak var this = self
        return { closure(this) }
    }
    
    func weakHandle<T>(_ closure: @escaping (Self?, T) -> Void) -> (T) -> Void {
        weak var this = self
        return { closure(this,$0) }
    }
    
    func weakHandle<T, S>(_ closure: @escaping (Self?, T, S) -> Void) -> (T, S) -> Void {
        weak var this = self
        return { closure(this,$0,$1) }
    }
    
    func weakHandle<T, S, R>(_ closure: @escaping (Self?, T, S, R) -> Void) -> (T, S, R) -> Void {
        weak var this = self
        return { closure(this,$0,$1,$2) }
    }
    
    func weakHandle<T, S, R, Q>(_ closure: @escaping (Self?, T, S, R, Q) -> Void) -> (T, S, R, Q) -> Void {
        weak var this = self
        return { closure(this,$0,$1,$2,$3) }
    }
    
    func weakHandle<T, S, R, Q, P>(_ closure: @escaping (Self?, T, S, R, Q, P) -> Void) -> (T, S, R, Q, P) -> Void {
        weak var this = self
        return { closure(this,$0,$1,$2,$3,$4) }
    }
    
    func weakHandle<T, S, R, Q, P, O>(_ closure: @escaping (Self?, T, S, R, Q, P, O) -> Void) -> (T, S, R, Q, P, O) -> Void {
        weak var this = self
        return { closure(this,$0,$1,$2,$3,$4,$5) }
    }
}







public extension WeakHandleProtocol  {
    func weakHandle<T>(_ closure: @escaping (Self?) -> T) -> () -> T {
        base(closure)
    }
    
    func weakHandle<T, S>(_ closure: @escaping (Self?) -> (T, S)) -> () -> (T, S) {
        base(closure)
    }
    
    func weakHandle<T, S, R>(_ closure: @escaping (Self?) -> (T, S, R)) -> () -> (T, S, R) {
        base(closure)
    }
    
    func weakHandle<T, S, R, Q>(_ closure: @escaping (Self?) -> (T, S, R, Q)) -> () -> (T, S, R, Q) {
        base(closure)
    }
    
    func weakHandle<T, S, R, Q, P>(_ closure: @escaping (Self?) -> (T, S, R, Q, P)) -> () -> (T, S, R, Q, P) {
        base(closure)
    }
    
    func weakHandle<T, S, R, Q, P, O>(_ closure: @escaping (Self?) -> (T, S, R, Q, P, O)) -> () -> (T, S, R, Q, P, O) {
        base(closure)
    }
    
    fileprivate func base<T>(_ closure: @escaping (Self?) -> T) -> () -> T {
        weak var this = self
        return { closure(this) }
    }
}







public extension WeakHandleProtocol  {
    func weakHandle<T, S>(_ closure: @escaping (Self?, T) -> S) -> (T) -> S {
        base(closure)
    }
    
    func weakHandle<T, S, R>(_ closure: @escaping (Self?, T) -> (S, R)) -> (T) -> (S, R) {
        base(closure)
    }
    
    func weakHandle<T, S, R, Q>(_ closure: @escaping (Self?, T) -> (S, R, Q)) -> (T) -> (S, R, Q) {
        base(closure)
    }
    
    func weakHandle<T, S, R, Q, P>(_ closure: @escaping (Self?, T) -> (S, R, Q, P)) -> (T) -> (S, R, Q, P) {
        base(closure)
    }
    
    func weakHandle<T, S, R, Q, P, O>(_ closure: @escaping (Self?, T) -> (S, R, Q, P, O)) -> (T) -> (S, R, Q, P, O) {
        base(closure)
    }
    
    fileprivate func base<T, S>(_ closure: @escaping (Self?, T) -> S) -> (T) -> S {
        weak var this = self
        return { closure(this,$0) }
    }
}








public extension WeakHandleProtocol  {
    func weakHandle<T, S, R>(_ closure: @escaping (Self?, T, S) -> R) -> (T, S) -> R {
        base(closure)
    }
    
    func weakHandle<T, S, R, Q>(_ closure: @escaping (Self?, T, S) -> (R, Q)) -> (T, S) -> (R, Q) {
        base(closure)
    }
    
    func weakHandle<T, S, R, Q, P>(_ closure: @escaping (Self?, T, S) -> (R, Q, P)) -> (T, S) -> (R, Q, P) {
        base(closure)
    }
    
    func weakHandle<T, S, R, Q, P, O>(_ closure: @escaping (Self?, T, S) -> (R, Q, P, O)) -> (T, S) -> (R , Q, P, O) {
        base(closure)
    }
    
    func weakHandle<T, S, R, Q, P, O, N>(_ closure: @escaping (Self?, T, S) -> (R, Q, P, O, N)) -> (T, S) -> (R, Q, P, O, N) {
        base(closure)
    }
    
    fileprivate func base<T, S, R>(_ closure: @escaping (Self?, T, S) -> R) -> (T, S) -> R {
        weak var this = self
        return { closure(this,$0,$1) }
    }
}









public extension WeakHandleProtocol  {
    func weakHandle<T, S, R, Q>(_ closure: @escaping (Self?, T, S, R) -> Q) -> (T, S, R) -> Q {
        base(closure)
    }
    
    func weakHandle<T, S, R, Q, P>(_ closure: @escaping (Self?, T, S, R) -> (Q, P)) -> (T, S, R) -> (Q, P) {
        base(closure)
    }
    
    func weakHandle<T, S, R, Q, P, O>(_ closure: @escaping (Self?, T, S, R) -> (Q, P, O)) -> (T, S, R) -> (Q, P, O) {
        base(closure)
    }
    
    func weakHandle<T, S, R, Q, P, O, N>(_ closure: @escaping (Self?, T, S, R) -> (Q, P, O, N)) -> (T, S, R) -> (Q, P, O, N) {
        base(closure)
    }
    
    func weakHandle<T, S, R, Q, P, O, N, M>(_ closure: @escaping (Self?, T, S, R) -> (Q, P, O, N, M)) -> (T, S, R) -> (Q, P, O, N, M) {
        base(closure)
    }
    
    fileprivate func base<T, S, R, Q>(_ closure: @escaping (Self?, T, S, R) -> Q) -> (T, S, R) -> Q {
        weak var this = self
        return { closure(this,$0,$1,$2) }
    }
}








public extension WeakHandleProtocol  {
    func weakHandle<T, S, R, Q, P>(_ closure: @escaping (Self?, T, S, R, Q) -> P) -> (T, S, R, Q) -> P {
        base(closure)
    }
    
    func weakHandle<T, S, R, Q, P, O>(_ closure: @escaping (Self?, T, S, R, Q) -> (P, O)) -> (T, S, R, Q) -> (P, O) {
        base(closure)
    }
    
    func weakHandle<T, S, R, Q, P, O, N>(_ closure: @escaping (Self?, T, S, R, Q) -> (P, O, N)) -> (T, S, R, Q) -> (P, O, N) {
        base(closure)
    }
    
    func weakHandle<T, S, R, Q, P, O, N, M>(_ closure: @escaping (Self?, T, S, R, Q) -> (P, O, N, M)) -> (T, S, R, Q) -> (P, O, N, M) {
        base(closure)
    }
    
    func weakHandle<T, S, R, Q, P, O, N, M, L>(_ closure: @escaping (Self?, T, S, R, Q) -> (P, O, N, M, L)) -> (T, S, R, Q) -> (P, O, N, M, L) {
        base(closure)
    }
    
    fileprivate func base<T, S, R, Q, P>(_ closure: @escaping (Self?, T, S, R, Q) -> P) -> (T, S, R, Q) -> P {
        weak var this = self
        return { closure(this,$0,$1,$2,$3) }
    }
}







public extension WeakHandleProtocol  {
    func weakHandle<T, S, R, Q, P, O>(_ closure: @escaping (Self?, T, S, R, Q, P) -> O) -> (T, S, R, Q, P) -> O {
        base(closure)
    }
    
    func weakHandle<T, S, R, Q, P, O, N>(_ closure: @escaping (Self?, T, S, R, Q, P) -> (O, N)) -> (T, S, R, Q, P) -> (O,  N) {
        base(closure)
    }
    
    func weakHandle<T, S, R, Q, P, O, N, M>(_ closure: @escaping (Self?, T, S, R, Q, P) -> (O, N, M)) -> (T, S, R, Q, P) -> (O, N, M) {
        base(closure)
    }
    
    func weakHandle<T, S, R, Q, P, O, N, M, L>(_ closure: @escaping (Self?, T, S, R, Q, P) -> (O, N, M, L)) -> (T, S, R, Q, P) -> (O, N, M, L) {
        base(closure)
    }
    
    func weakHandle<T, S, R, Q, P, O, N, M, L, K>(_ closure: @escaping (Self?, T, S, R, Q, P) -> (O, N, M, L, K)) -> (T, S, R, Q, P) -> (O, N, M, L, K) {
        base(closure)
    }
    
    fileprivate func base<T, S, R, Q, P, O>(_ closure: @escaping (Self?, T, S, R, Q, P) -> O) -> (T, S, R, Q, P) -> O {
        weak var this = self
        return { closure(this,$0,$1,$2,$3,$4) }
    }
}
