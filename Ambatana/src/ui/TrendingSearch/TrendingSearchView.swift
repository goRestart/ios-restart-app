//
//  TrendingSearchView.swift
//  LetGo
//
//  Created by Tomas Cobo on 27/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

protocol TrendingSearchViewDelegate: class {
    func trendingSearchViewBackgroundTapped()
    func trendingSearchCleanButtonPressed()
    func trendingSearch(numberOfRowsIn section: Int) -> Int
    func trendingSearch(cellSelectedAt indexPath: IndexPath)
    func trendingSearch(cellDataAt  indexPath: IndexPath) -> SuggestionCellData?
}

final class TrendingSearchView: UIView {
    
    private let sectionHeight: CGFloat = 40
    
    weak var delegate: TrendingSearchViewDelegate?
    
    //  MARK: - Subviews
    
    private let blurBackground: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .extraLight)
        return UIVisualEffectView(effect: blurEffect)
    }()
    
    private let searchesTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = SuggestionSearchCell.estimatedHeight
        tableView.register(SuggestionSearchCell.self, forCellReuseIdentifier: SuggestionSearchCell.reusableID)
        tableView.set(accessibilityId: .mainListingsSuggestionSearchesTable)
        return tableView
    }()
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        clipsToBounds = true
        searchesTableView.delegate = self
        searchesTableView.dataSource = self
        addGestureRecognizers()
        setupViews()
        setupConstraints()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //  MARK: - Private methods
    
    private func addGestureRecognizers() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TrendingSearchView.trendingSearchesBckgPressed))
        searchesTableView.backgroundView = UIView()
        searchesTableView.backgroundView?.addGestureRecognizer(gestureRecognizer)
    }
    
    private func setupViews() {
        addSubviewsForAutoLayout([blurBackground, searchesTableView])
    }
    
    private func setupConstraints() {
        blurBackground.layout(with: self).fill()
        searchesTableView.layout(with: self).fill()
    }
    
    @objc private func trendingSearchesBckgPressed(_ sender: AnyObject) {
        delegate?.trendingSearchViewBackgroundTapped()
    }
    
    //  MARK: - Public methods
    
    func updateBottomTableView(contentInset: CGFloat) {
        searchesTableView.contentInset.bottom = contentInset
    }
    
    func reloadTrendingSearchTableView() {
        searchesTableView.reloadData()
    }
    
    func updateTrendingSearchTableView(hidden: Bool) {
        searchesTableView.isHidden = hidden
    }

}

//  MARK: - TableView Delegates

extension TrendingSearchView: UITableViewDelegate, UITableViewDataSource {
    
    private func numberOfRows(_ section: Int) -> Int {
        return delegate?.trendingSearch(numberOfRowsIn: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return numberOfRows(section) > 0 ? sectionHeight : 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = TrendingSearchTableHeader(target: self,
                                               frameRect: CGRect(origin: .zero, size: CGSize(width: 0, height: sectionHeight)))
        guard let sectionType = SearchSuggestionType.sectionType(index: section) else { return UIView() }
        header.setTitle(sectionType)
        return header
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SearchSuggestionType.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellData = delegate?.trendingSearch(cellDataAt: indexPath),
            let cell = tableView.dequeueReusableCell(withIdentifier: SuggestionSearchCell.reusableID,
                                                     for: indexPath) as? SuggestionSearchCell else {
                                                        return UITableViewCell()
        }
        cell.set(cellData)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.trendingSearch(cellSelectedAt: indexPath)
    }
    @objc fileprivate func cleanSearchesButtonPressed() {
        delegate?.trendingSearchCleanButtonPressed()
    }
}

private class TrendingSearchTableHeader: UIView {
    
    //  MARK: - Subviews
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .leading
        return stackView
    }()
    
    private let suggestionTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .sectionTitleFont
        label.textColor = .darkGrayText
        return label
    }()
    
    private let clearButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.textAlignment = .right
        button.titleLabel?.font = .sectionTitleFont
        button.setTitleColor(.darkGrayText, for: .normal)
        button.setTitle(LGLocalizedString.suggestionsLastSearchesClearButton.localizedUppercase, for: .normal)
        return button
    }()
    
    init(target: Any?, frameRect: CGRect) {
        super.init(frame: frameRect)
        clipsToBounds = true
        backgroundColor = .white
        clearButton.addTarget(target, action: #selector(TrendingSearchView.cleanSearchesButtonPressed), for: .touchUpInside)
        setupViews()
        setupConstraints()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //  MARK: - Private methods
    
    private func setupViews() {
        addSubviewForAutoLayout(stackView)
        stackView.addArrangedSubview(suggestionTitleLabel)
        stackView.addArrangedSubview(clearButton)
    }
    
    private func setupConstraints() {
        stackView.layout(with: self)
            .leading(by: Metrics.margin)
            .trailing(by: -Metrics.margin)
            .top(by: Metrics.bigMargin)
            .bottom(by: -Metrics.veryShortMargin)
    }
    
    //  MARK: - Public methods
    
    func setTitle(_ sectionType: SearchSuggestionType) {
        switch sectionType {
        case .suggestive:
            clearButton.isHidden = true
            suggestionTitleLabel.text = LGLocalizedString.suggestedSearchesTitle.localizedUppercase
        case .lastSearch:
            clearButton.isHidden = false
            suggestionTitleLabel.text = LGLocalizedString.suggestionsLastSearchesTitle.localizedUppercase
        case .trending:
            clearButton.isHidden = true
            suggestionTitleLabel.text = LGLocalizedString.trendingSearchesTitle.localizedUppercase
        }
    }
}
