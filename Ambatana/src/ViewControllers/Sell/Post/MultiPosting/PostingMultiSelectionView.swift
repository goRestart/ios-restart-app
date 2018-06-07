final class PostingMultiSelectionView: UIView {
    
}

extension PostingMultiSelectionView: PostingViewConfigurable {
    
    func setupContainerView(view: UIView) {
        view.addSubviewForAutoLayout(self)
        layout(with: view).fill()
    }
    
    func setupView(viewModel: PostingDetailsViewModel) {
        // ABIOS-4184: Update TableView if needed
    }
    
}
