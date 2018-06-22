import LGCoreKit
import LGComponents

enum HelpURLType {
    case terms
    case privacy
}

class HelpViewModel: BaseViewModel {
    fileprivate let myUserRepository: MyUserRepository
    fileprivate let installationRepository: InstallationRepository

    weak var navigator: HelpNavigator?
    
    convenience override init() {
        self.init(myUserRepository: Core.myUserRepository, installationRepository: Core.installationRepository)
    }
    
    init(myUserRepository: MyUserRepository, installationRepository: InstallationRepository) {
        self.myUserRepository = myUserRepository
        self.installationRepository = installationRepository
    }
    
    override func backButtonPressed() -> Bool {
        navigator?.closeHelp()
        return true
    }
    
    var url: URL? {
        return LetgoURLHelper.buildHelpURL(myUserRepository.myUser, installation: installationRepository.installation)
    }
}
