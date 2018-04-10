import GoogleSignIn

public class Login: NSObject, GIDSignInUIDelegate {
    
    public override init() {}
    
    public func go() {
        GIDSignIn.sharedInstance().uiDelegate = self
        print("go: \(R.Strings.appShareEmailButton)")
    }
}

