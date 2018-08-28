import Foundation
import LGComponents
import RxSwift

final class UserAvatarViewController: BaseViewController {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .white
        return imageView
    }()

    private let viewModel: UserAvatarViewModel
    private let disposeBag = DisposeBag()

    init(viewModel: UserAvatarViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
        viewModel.delegate = self
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppearFromBackground(_ fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)
        setNavBarBackgroundStyle(.white)
        setNavBarBackButton(R.Asset.Icons.icArrowLeft.image, selector: nil)
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubviewForAutoLayout(imageView)
        if viewModel.isPrivate {
            setupNavBarActions()
        }
        setupRx()
        setupConstraints()
    }

    private func setupRx() {
        Observable
            .combineLatest(viewModel.userAvatarURL.asObservable(), viewModel.userAvatarPlaceholder.asObservable()) { ($0, $1) }
            .subscribeNext { [weak self] (url, placeholder) in
                if let url = url {
                    self?.imageView.af_setImage(withURL: url)
                } else {
                    self?.imageView.image = placeholder
                }
            }
            .disposed(by: disposeBag)
    }

    private func setupNavBarActions() {
        let editButton = UIButton(type: .system)
        editButton.setImage(R.Asset.Icons.icPen.image, for: .normal)
        editButton.addTarget(self, action: #selector(didTapEdit), for: .touchUpInside)
        self.setNavigationBarRightButtons([editButton])
    }

    private func setupConstraints() {
        let constraints = [
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ]
        constraints.activate()
    }

    @objc private func didTapEdit() {
        MediaPickerManager.showImagePickerIn(self)
    }
}

// MARK: - Image Picker Delegate

extension UserAvatarViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil { image = info[UIImagePickerControllerOriginalImage] as? UIImage }
        dismiss(animated: true, completion: nil)
        guard let theImage = image else { return }
        viewModel.updateAvatar(with: theImage)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
