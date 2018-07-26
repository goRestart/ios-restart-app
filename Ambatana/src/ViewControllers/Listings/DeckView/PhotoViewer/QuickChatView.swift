import Foundation
import RxSwift
import RxCocoa
import LGCoreKit
import LGComponents


final class QuickChatView: UIView, UIGestureRecognizerDelegate {
    private struct Layout {
        static let buttonHeight: CGFloat = 50
    }
    private struct Duration {
        static let flashInTable: TimeInterval = TimeInterval(1)
        static let flashOutTable: TimeInterval = TimeInterval(3)
    }
    
    var isTableInteractionEnabled = false

    private var directAnswersViewBottom: NSLayoutConstraint?
    let directAnswersView = DirectAnswersHorizontalView(answers: [])
    let tableView = CustomTouchesTableView()

    private let chatButton: LetgoButton = {
        let button = LetgoButton(withStyle: .primary(fontSize: .medium))
        button.setTitle(R.Strings.listingChatButton, for: .normal)
        return button
    }()

    private var alphaAnimationHideTimer: Timer?

    init() {
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else { return }
        directAnswersViewBottom?.constant = -Metrics.margin
        backgroundColor = UIColor.clear
    }

    func setListingAs(interested: Bool) {
        chatButton.isHidden = !interested
        directAnswersView.isHidden = interested
    }

    func updateWith(bottomInset: CGFloat, animationTime: TimeInterval,
                    animationOptions: UIViewAnimationOptions, completion: ((Bool) -> Void)? = nil) {
        let color = (bottomInset <= 0) ? UIColor.clear : UIColor.black.withAlphaComponent(0.5)
        let animationFunc = (bottomInset <= 0) ? dissappearAnimation : revealAnimation

        if bottomInset <= 0 {
            directAnswersViewBottom?.constant = Metrics.margin
        } else {
            directAnswersViewBottom?.constant = -(bottomInset + Metrics.margin)
        }
        UIView.animate(withDuration: animationTime,
                       delay: 0,
                       options: animationOptions,
                       animations: { [weak self] in
                        animationFunc()
                        self?.backgroundColor = color
                        self?.layoutIfNeeded()
        }, completion: completion)
    }

    private func revealAnimation() {
        self.directAnswersView.alpha = 1
        self.tableView.alpha = 1
    }

    private func dissappearAnimation() {
        alphaAnimationHideTimer?.invalidate()
    }

    func updateDirectChatWith(answers: [QuickAnswer]) {
        directAnswersView.update(answers: answers)
    }

    func showDirectMessages() {
        fireHideAnimationTimer()
    }

    private func fireHideAnimationTimer() {
        if alphaAnimationHideTimer == nil {
            UIView.animate(withDuration: Duration.flashInTable,
                           animations: { [weak self] in
                            self?.tableView.alpha = 1
            }) { [weak self] (completion) in
                self?.alphaAnimationHideTimer?.fire()
            }
        }
        alphaAnimationHideTimer?.invalidate()
        alphaAnimationHideTimer = Timer.scheduledTimer(timeInterval: TimeInterval(3),
                                                       target: self,
                                                       selector: #selector(dismissTimer),
                                                       userInfo: nil, repeats: false)
    }

    @objc private func dismissTimer() {
        guard alphaAnimationHideTimer != nil else { return }
        UIView.animate(withDuration: Duration.flashOutTable,
                       animations: { [weak self] in
                        self?.tableView.alpha = 0
            }, completion: { [weak self] _ in
                self?.alphaAnimationHideTimer = nil
        })
    }

    func addDismissGestureRecognizer(_ gesture: UITapGestureRecognizer) {
        gesture.delegate = self
        gesture.cancelsTouchesInView = false
        gesture.delaysTouchesBegan = true
        addGestureRecognizer(gesture)
    }

    // MARK: UIGestureRecognizerDelegate

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard !gestureRecognizer.isKind(of: UISwipeGestureRecognizer.self) else { return true }
        guard let touchView = touch.view else { return false }
        let indexPath = tableView.indexPathForRow(at: touch.location(in: tableView))
        if touchView.isDescendant(of: tableView), let index = indexPath, let _ = tableView.cellForRow(at: index) {
            return false
        }
        return !touchView.isDescendant(of: directAnswersView)
    }

    // MARK: UI

    private func setupUI() {
        backgroundColor = .clear
        addSubviewsForAutoLayout([directAnswersView, chatButton, tableView])
        let directAnswersViewBottom = directAnswersView.bottomAnchor.constraint(equalTo: bottomAnchor)

        NSLayoutConstraint.activate([
            directAnswersView.leadingAnchor.constraint(equalTo: leadingAnchor),
            directAnswersView.trailingAnchor.constraint(equalTo: trailingAnchor),
            directAnswersViewBottom,

            chatButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight),
            chatButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            chatButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.margin),
            chatButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metrics.margin),

            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: directAnswersView.topAnchor, constant: -Metrics.shortMargin)
        ])
        setupDirectAnswers()
        setupTableView()

        self.directAnswersViewBottom = directAnswersViewBottom
    }

    private func setupDirectAnswers() {
        directAnswersView.backgroundColor = .clear
        directAnswersView.style = .light
        directAnswersView.sideMargin = Metrics.margin
    }

    private func setupTableView() {
        tableView.keyboardDismissMode = .onDrag
        tableView.backgroundColor = .clear
        setupDirectMessages()
    }

    func setupDirectMessages() {
        tableView.isCellHiddenBlock = { return $0.contentView.isHidden }
        ChatCellDrawerFactory.registerCells(tableView)

        tableView.transform = CGAffineTransform.invertedVertically
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = DirectAnswersHorizontalView.Layout.Height.estimatedRow
        tableView.separatorStyle = .none
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let insideTable = tableView.point(inside: convert(point, to: tableView),  with: event)
            && (alphaAnimationHideTimer != nil || isTableInteractionEnabled)

        let insideDirectAnswers = directAnswersView.point(inside: convert(point, to: directAnswersView), with: event)

        return insideTable || insideDirectAnswers
    }
}
