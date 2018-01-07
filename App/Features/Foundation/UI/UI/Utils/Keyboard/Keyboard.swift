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
    public let animationCurve: UIViewAnimationCurve?
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
    let keyboardStartFrame = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? CGRect) ?? .zero
    let keyboardEndFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect) ?? .zero
    let animationDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval) ?? 0
    let animationCurve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UIViewAnimationCurve
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
    .willShow: NSNotification.Name.UIKeyboardWillShow,
    .willHide: NSNotification.Name.UIKeyboardWillHide,
    .didShow: NSNotification.Name.UIKeyboardDidShow,
    .didHide: NSNotification.Name.UIKeyboardDidHide,
    .willChangeFrame: NSNotification.Name.UIKeyboardWillChangeFrame,
    .didChangeFrame: NSNotification.Name.UIKeyboardDidChangeFrame
  ]
}
