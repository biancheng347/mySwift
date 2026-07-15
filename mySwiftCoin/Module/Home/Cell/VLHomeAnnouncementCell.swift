import UIKit
import SnapKit
import Then

/// 公告列表分区（动态高度）。
final class VLHomeAnnouncementCell: BaseCVCell {

    private lazy var titleLabel = lazyTitleLabel()
    private lazy var entriesStack = lazyEntriesStack()

    /// 渲染公告标题与条目行。
    override func cell(model: ItemTypeProtocol) {
        guard let item = model as? ItemTypeModel<VLHomeAnnouncementModel> else { return }
        titleLabel.text = item.data.title
        rebuildEntries(item.data.announcements)
    }
}

fileprivate extension VLHomeAnnouncementCell {

    /// 分区标题标签。
    func lazyTitleLabel() -> UILabel {
        UILabel().then {
            $0.font = .systemFont(ofSize: 16, weight: .semibold)
            $0.textColor = VLHomeAppearance.textPrimary
        }.make(contentView) {
            $0.leading.equalToSuperview().offset(VLHomeLayout.horizontalInset)
            $0.top.equalToSuperview().offset(2.rpx)
        }
    }

    /// 公告条目垂直栈。
    func lazyEntriesStack() -> UIStackView {
        UIStackView().then {
            $0.axis = .vertical
            $0.spacing = 0
        }.make(contentView) {
            $0.leading.trailing.equalToSuperview().inset(VLHomeLayout.horizontalInset)
            $0.top.equalTo(titleLabel.snp.bottom).offset(8.rpx)
            $0.bottom.equalToSuperview().offset(-8.rpx)
        }
    }

    /// 根据模型重建条目行。
    func rebuildEntries(_ entries: [VLHomeAnnouncementEntryModel]) {
        entriesStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        entries.enumerated().forEach { index, entry in
            entriesStack.addArrangedSubview(makeEntryView(entry, index: index))
        }
    }

    /// 构建单条公告行（标题 + 时间戳）。
    func makeEntryView(_ entry: VLHomeAnnouncementEntryModel, index: Int) -> UIView {
        UIView().then { row in
            row.snp.makeConstraints { $0.height.equalTo(64.rpx) }
            row.isUserInteractionEnabled = true
            row.tag = index
            row.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(announcementTapped(_:)))
            )
            UILabel().then {
                $0.text = entry.title
                $0.font = .systemFont(ofSize: 13)
                $0.textColor = VLHomeAppearance.textPrimary
                $0.numberOfLines = 2
            }.make(row) {
                $0.leading.trailing.equalToSuperview()
                $0.top.equalToSuperview().offset(8.rpx)
            }
            UILabel().then {
                $0.text = entry.publishedAt
                $0.font = .systemFont(ofSize: 11)
                $0.textColor = VLHomeAppearance.textTertiary
            }.make(row) {
                $0.leading.equalToSuperview()
                $0.bottom.equalToSuperview().offset(-8.rpx)
            }
        }
    }

    /// 通过 VM 处理公告行点击。
    @objc func announcementTapped(_ gesture: UITapGestureRecognizer) {
        guard let index = gesture.view?.tag else { return }
        weakView(fetch: VLHomeExchangeView.self)?.vm.onAnnouncementTap(index: index)
    }
}
