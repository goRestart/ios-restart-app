public struct MockTaxonomy: Taxonomy {
    public var name: String
    public var icon: URL?
    public var children: [TaxonomyChild]
}
