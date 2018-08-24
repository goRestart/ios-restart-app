import LGCoreKit

protocol MeetingAssistantNavigator: class {
    func openEditLocation(mode: EditLocationMode,
                          initialPlace: Place?,
                          locationDelegate: EditLocationDelegate)
    func meetingCreationDidFinish()
    func openMeetingTipsWith(closeCompletion: (()->Void)?)
}
