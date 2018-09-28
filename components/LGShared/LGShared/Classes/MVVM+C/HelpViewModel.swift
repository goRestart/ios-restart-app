import LGCoreKit

public class HelpViewModel: BaseViewModel {
    fileprivate let myUserRepository: MyUserRepository
    fileprivate let installationRepository: InstallationRepository

    var router: HelpWireframe?
    
    convenience override public init() {
        self.init(myUserRepository: Core.myUserRepository, installationRepository: Core.installationRepository)
    }
    
    public init(myUserRepository: MyUserRepository, installationRepository: InstallationRepository) {
        self.myUserRepository = myUserRepository
        self.installationRepository = installationRepository
    }
    
    override public func backButtonPressed() -> Bool {
        router?.closeHelp()
        return true
    }
    
    public var url: URL? {
        return LetgoURLHelper.buildHelpURL(myUserRepository.myUser, installation: installationRepository.installation)
    }
}
