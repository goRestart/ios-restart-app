import LGCoreKit

final class MeetingAssistantModalWireframe: MeetingAssistantNavigator, MeetingSafetyTipsNavigator {
    private let root: UIViewController
    private weak var nc: UINavigationController?
    private let assitantMeetingAssembly: AssistantMeetingAssembly

    init(root: UIViewController, nc: UINavigationController?) {
        self.root = root
        self.nc = nc
        self.assitantMeetingAssembly = AssistantMeetingBuilder.modal(root)
    }

    func openEditLocation(mode: EditLocationMode,
                          initialPlace: Place?,
                          locationDelegate: EditLocationDelegate) {
        guard let nc = nc else { return }
        let assembly =  QuickLocationFiltersBuilder.standard(nc)
        let vc = assembly.buildQuickLocationFilters(mode: mode,
                                                    initialPlace: initialPlace,
                                                    distanceRadius: nil,
                                                    locationDelegate: locationDelegate)
        nc.pushViewController(vc, animated: true)
    }

    func meetingCreationDidFinish() {
        root.dismissAllPresented(nil)
    }

    func openMeetingTipsWith(closeCompletion: (()->Void)?) {
        let vc = assitantMeetingAssembly.buildMeetingSafetyTips(with: closeCompletion)
        nc?.present(vc, animated: true, completion: nil)
    }

    func closeMeetingTipsWith(closeCompletion: (()->Void)?) {
        root.dismissAllPresented(closeCompletion)
    }
}
