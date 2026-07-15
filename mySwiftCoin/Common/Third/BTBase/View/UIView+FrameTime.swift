import UIKit

private let aFrameTime = 0.01667
private let aFrameTimeMax = 120

public extension UIView {
    /// 等到自身有有效 frame 后再执行（用于 WeakView 注册等依赖层级的时机）。
    func frameTime(_ completed: @escaping (UIView) -> Void) {
        frame(isMain: true, delay: aFrameTime, condition: { [weak self] in
            guard let self else { return true }
            return self.frame.width > 0 && self.frame.height > 0
        }, completed: { [weak self] in
            guard let self else { return }
            completed(self)
        })
    }

    /// 带条件轮询的延迟执行。
    func frame(
        isMain: Bool,
        delay: Double,
        count: Int = 0,
        condition: @escaping () -> Bool,
        completed: @escaping () -> Void
    ) {
        guard count < aFrameTimeMax else { return }
        After(isMain: isMain, delay: delay) {
            guard !condition() else {
                completed()
                return
            }
            self.frame(
                isMain: isMain,
                delay: delay,
                count: count + 1,
                condition: condition,
                completed: completed
            )
        }
    }
}
