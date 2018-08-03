struct TooltipConfiguration {
    let title: NSAttributedString
    let style: TooltipStyle
    let peakOnTop: Bool
    let actionBlock: () -> ()
    let closeBlock: (() -> ())?
}
