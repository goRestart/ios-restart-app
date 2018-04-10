
import UIKit
import LGModules

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(R.Strings.appShareEmailButton)
        //        L10n.accountPendingModeration
        
        let imageView = UIImageView(image: R.Asset.BackgroundsAndImages.icBlocked.image)
        
        view.addSubview(imageView)

    }

}

