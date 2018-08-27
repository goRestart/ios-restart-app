import Foundation
import LGCoreKit

protocol UserAssembly {
    func buildUser(interlocutor: ChatInterlocutor,
                   hidesBottomBarWhenPushed: Bool) -> UserProfileViewController
    func buildUser(user: User, source: UserSource) -> UserProfileViewController
    func buildUserReport(source: EventParameterTypePage, userReportedId: String) -> ReportUsersViewController
}

enum LGUserBuilder {
    case standard(UINavigationController)
}

extension LGUserBuilder: UserAssembly {

    func buildUserReport(source: EventParameterTypePage, userReportedId: String) -> ReportUsersViewController {
        let vm = ReportUsersViewModel(origin: source, userReportedId: userReportedId)
        let vc = ReportUsersViewController(viewModel: vm)
        vm.delegate = vc

        return vc
    }

    func buildUser(user: User, source: UserSource) -> UserProfileViewController {
        switch self {
        case .standard(let nav):
            let vm = UserProfileViewModel.makePublicProfile(user: user, source: source)
            vm.navigator = UserWireframe(nc: nav)
            let vc = UserProfileViewController(viewModel: vm, hidesBottomBarWhenPushed: false)
            return vc
        }
    }

    func buildUser(interlocutor: ChatInterlocutor,
                   hidesBottomBarWhenPushed: Bool) -> UserProfileViewController {
        switch self {
        case .standard(let nav):
            let vm = UserProfileViewModel.makePublicProfile(chatInterlocutor: interlocutor, source: .chat)
            vm.navigator = UserWireframe(nc: nav)
            let vc = UserProfileViewController(viewModel: vm, hidesBottomBarWhenPushed: hidesBottomBarWhenPushed)
            return vc
        }
    }
}
