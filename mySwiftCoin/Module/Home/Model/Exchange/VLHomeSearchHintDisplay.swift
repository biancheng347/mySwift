import Foundation
import Then

/// 首页搜索栏单条提示的纯展示快照（左侧固定搜索图标；右侧可为 icon+文字或纯文字）。
final class VLHomeSearchHintDisplay: Then {
    /// 左侧固定搜索 SF Symbol。
    static let leadingSearchIconName = "magnifyingglass"
    /// 无数据时的占位文案。
    static let fallbackText = "搜索币种/合约"

    var text: String = fallbackText
    var trailingIconName: String?

    /// 右侧是否展示伴随图标。
    var showsTrailingIcon: Bool { trailingIconName != nil }

    init() {}

    /// 从可选 hint 生成展示快照。
    static func make(from hint: VLHomeSearchHintModel?) -> VLHomeSearchHintDisplay {
        guard let hint else {
            return VLHomeSearchHintDisplay().then {
                $0.text = fallbackText
                $0.trailingIconName = nil
            }
        }
        let trimmedIcon = hint.iconName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedText = hint.text.trimmingCharacters(in: .whitespacesAndNewlines)
        return VLHomeSearchHintDisplay().then {
            $0.text = trimmedText.isEmpty ? fallbackText : trimmedText
            $0.trailingIconName = trimmedIcon.isEmpty ? nil : trimmedIcon
        }
    }
}
