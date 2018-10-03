import LGComponents

protocol ChatViewModelDelegate: BaseViewModelDelegate {
    
    func vmDidFailRetrievingChatMessages()
    
    func vmDidPressReportUser(_ reportUserViewModel: ReportUsersViewModel)
    
    func vmDidRequestSafetyTips()
    
    func vmDidSendMessage()
    func vmDidEndEditing(animated: Bool)
    func vmDidBeginEditing()
    
    func vmDidRequestShowPrePermissions(_ type: PrePermissionType)
    func vmDidNotifyMessage(_ message: String, completion: (() -> ())?)
    
    func vmAskPhoneNumber()
}
