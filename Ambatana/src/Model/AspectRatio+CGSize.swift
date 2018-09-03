extension CGSize {
    
    func adaptSize(withWidthSize widthSize: CGFloat, maxHeight: CGFloat) -> CGSize {
        
        guard height > 0 && width > 0 else { return .zero }
        
        let originalAspectRatio = AspectRatio(size: self)
        let constrainedAspectRation = originalAspectRatio.constrainedAspectRatio(.portrait, to: .w1h2)
        let thumbHeight = round(constrainedAspectRation.size(setting: widthSize, in: .width).height)
        
        return CGSize(width: widthSize,
                      height: max(maxHeight,thumbHeight))
    }
    
}
