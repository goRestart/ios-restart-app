
import LGComponents

enum CellAppearance {
    case dark(buttonTitle: String), light(buttonTitle: String)
    case backgroundImage(image: UIImage, titleColor: UIColor, buttonStyle: ButtonStyle, buttonTitle: String)
}
