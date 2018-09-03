import UIKit
import RxSwift
import RxCocoa
import LGComponents

final class TourPostingViewController: BaseViewController {

    @IBOutlet weak var photoContainer: UIView!
    @IBOutlet var cameraCorners: [UIImageView]!

    @IBOutlet var internalMargins: [NSLayoutConstraint]!
    @IBOutlet weak var okButton: LetgoButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var cameraTour: UIImageView!
    
    private let viewModel: TourPostingViewModel
    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    init(viewModel: TourPostingViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "TourPostingViewController", statusBarStyle: .lightContent,
                   navBarBackgroundStyle: .transparent(substyle: .dark))
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setAccesibilityIds()
        setupRx()
    }


    // MARK: - Private

    private func setupUI() {
        view.backgroundColor = .clear
        titleLabel.text = viewModel.titleText
        subtitleLabel.text = viewModel.subtitleText
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        
        okButton.setStyle(.primary(fontSize: .medium))
        okButton.setTitle(viewModel.okButtonText, for: .normal)

        let tap = UITapGestureRecognizer(target: self, action: #selector(cameraContainerPressed))
        photoContainer.addGestureRecognizer(tap)

        for (index, view) in cameraCorners.enumerated() {
            view.image = R.Asset.IconsButtons.icPostCorner.image
            guard index > 0 else { continue }
            view.transform = CGAffineTransform(rotationAngle: CGFloat(Double(index) * Double.pi/2))
        }
        cameraTour.image = R.Asset.IconsButtons.icCameraTour.image

        let close = UIBarButtonItem.init(image: R.Asset.IconsButtons.icClose.image,
                                         style: .plain,
                                         target: self,
                                         action: #selector(closeButtonPressed))
        close.set(accessibilityId: .tourPostingCloseButton)
        navigationItem.leftBarButtonItem = close
    }

    private func setupRx() {
        okButton.rx.tap.bind { [weak self] in self?.viewModel.okButtonPressed() }.disposed(by: disposeBag)
    }

    @objc private func closeButtonPressed() {
        let actionOk = UIAction(interface: UIActionInterface.text(R.Strings.onboardingAlertYes),
                                action: { [weak self] in self?.viewModel.okButtonPressed() })
        let actionCancel = UIAction(interface: UIActionInterface.text(R.Strings.onboardingAlertNo),
                                    action: { [weak self] in self?.viewModel.cancelButtonPressed() })
        showAlert(R.Strings.onboardingPostingAlertTitle,
                  message: R.Strings.onboardingPostingAlertSubtitle,
                  actions: [actionCancel, actionOk])
    }

    @objc private func cameraContainerPressed() {
        viewModel.cameraButtonPressed()
    }
}

extension TourPostingViewController: TourPostingViewModelDelegate { }


// MARK: - Accesibility

fileprivate extension TourPostingViewController {
    func setAccesibilityIds() {
        okButton.set(accessibilityId: .tourPostingOkButton)
    }
}
