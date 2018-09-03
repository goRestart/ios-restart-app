import RxSwift

public struct Keyboard {
  public enum KeyboardEvent {
    case willShow
    case willHide
    case didShow
    case didHide
    case willChangeFrame
    case didChangeFrame
  }
  
  public struct KeyboardInfo {
    public let event: KeyboardEvent
    public let startFrame: CGRect
    public let endFrame: CGRect
    public let animationDuration: TimeInterval
    public let animationCurve: UIView.AnimationCurve?
  }
  
  private static let notificationCenter = NotificationCenter.default
  
  public static func subscribe(to events: [KeyboardEvent]) -> Observable<KeyboardInfo> {
    return Observable.from(
      events.map { event in
        notificationCenter.rx.notification(relation[event])
      }
    ).merge()
    .map(extract)
  }
  
  private static func extract(from notification: Notification) -> KeyboardInfo {
    let keyboardStartFrame = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect) ?? .zero
    let keyboardEndFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect) ?? .zero
    let animationDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval) ?? 0
    let animationCurve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UIView.AnimationCurve
    let event = relation.filter { $0.value == notification.name }.first!.key
    
    let keyboardInfo = KeyboardInfo(
      event: event,
      startFrame: keyboardStartFrame,
      endFrame: keyboardEndFrame,
      animationDuration: animationDuration,
      animationCurve: animationCurve
    )
    return keyboardInfo
  }
  
  private static let relation: [KeyboardEvent: NSNotification.Name] = [
    .willShow: UIResponder.keyboardWillShowNotification,
    .willHide: UIResponder.keyboardWillHideNotification,
    .didShow: UIResponder.keyboardDidShowNotification,
    .didHide: UIResponder.keyboardDidHideNotification,
    .willChangeFrame: UIResponder.keyboardWillChangeFrameNotification,
    .didChangeFrame: UIResponder.keyboardDidChangeFrameNotification
  ]
}
