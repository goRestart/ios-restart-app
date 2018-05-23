import LGComponents

enum BlockingPostingHeaderStep: Int {
    case takePicture = 1
    case confirmPicture = 2
    case addPrice = 3
    
    var title: String {
        switch self {
        case .takePicture:
            return R.Strings.postHeaderStepTakePicture
        case .confirmPicture:
            return R.Strings.postHeaderStepConfirmPicture
        case .addPrice:
            return R.Strings.postHeaderStepAddPrice
        }
    }
}
