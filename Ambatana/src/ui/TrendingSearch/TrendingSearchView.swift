import LGComponents

protocol TrendingSearchViewDelegate: class {
    func trendingSearchBackgroundTapped(_ view: TrendingSearchView)
    func trendingSearchCleanButtonPressed(_ view: TrendingSearchView)
    func trendingSearch(_ view: TrendingSearchView, numberOfRowsIn section: Int) -> Int
    func trendingSearch(_ view: TrendingSearchView, cellSelectedAt indexPath: IndexPath)
    func trendingSearch(_ view: TrendingSearchView, cellContentAt  indexPath: IndexPath) -> SuggestionSearchCellContent?
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
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(trendingSearchesBckgPressed))
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
        delegate?.trendingSearchBackgroundTapped(self)
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
        return delegate?.trendingSearch(self, numberOfRowsIn: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return numberOfRows(section) > 0 ? sectionHeight : 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionType = SearchSuggestionType.sectionType(index: section) else { return UIView() }
        return TrendingSearchTableHeader(target: self, sectionType)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SearchSuggestionType.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellData = delegate?.trendingSearch(self, cellContentAt: indexPath),
            let cell = tableView.dequeueReusableCell(withIdentifier: SuggestionSearchCell.reusableID,
                                                     for: indexPath) as? SuggestionSearchCell else {
                                                        return UITableViewCell()
        }
        cell.set(cellData)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.trendingSearch(self, cellSelectedAt: indexPath)
    }
    
    @objc fileprivate func cleanSearchesButtonPressed() {
        delegate?.trendingSearchCleanButtonPressed(self)
    }
}

private final class TrendingSearchTableHeader: UIView {
    
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
        button.setTitle(R.Strings.suggestionsLastSearchesClearButton.localizedUppercase, for: .normal)
        return button
    }()
    
    init(target: Any?, _ sectionType: SearchSuggestionType) {
        super.init(frame: .zero)
        clipsToBounds = true
        backgroundColor = .white
        clearButton.addTarget(target, action: #selector(TrendingSearchView.cleanSearchesButtonPressed), for: .touchUpInside)
        setupViews()
        setupConstraints()
        setTitle(sectionType)
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
            .fillHorizontal(by: Metrics.margin)
            .top(by: Metrics.bigMargin)
            .bottom(by: -Metrics.veryShortMargin)
    }
    
    private func setTitle(_ sectionType: SearchSuggestionType) {
        switch sectionType {
        case .suggestive:
            clearButton.isHidden = true
            suggestionTitleLabel.text = R.Strings.suggestedSearchesTitle.localizedUppercase
        case .lastSearch:
            clearButton.isHidden = false
            suggestionTitleLabel.text = R.Strings.suggestionsLastSearchesTitle.localizedUppercase
        case .trending:
            clearButton.isHidden = true
            suggestionTitleLabel.text = R.Strings.trendingSearchesTitle.localizedUppercase
        }
    }
}
