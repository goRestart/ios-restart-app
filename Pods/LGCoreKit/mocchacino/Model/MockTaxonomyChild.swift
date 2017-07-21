public struct MockTaxonomyChild: TaxonomyChild {
    public var id: Int
    public var type: TaxonomyChildType
    public var name: String
    public var highlightOrder: Int?
    public var highlightIcon: URL?
    public var image: URL?
}
