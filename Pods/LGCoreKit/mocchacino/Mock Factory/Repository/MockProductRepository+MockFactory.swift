
extension MockProductRepository: MockFactory {
    public static func makeMock() -> Self {
        let mockProductRepository = self.init()
        mockProductRepository.indexResult = ProductsResult(value: MockProduct.makeMocks(count: Int.makeRandom(min: 0, max: 10)))
        mockProductRepository.productResult = ProductResult(value: MockProduct.makeMock())
        mockProductRepository.deleteProductResult = ProductVoidResult(value: Void())
        mockProductRepository.markAsSoldVoidResult = ProductVoidResult(value: Void())
        mockProductRepository.userProductRelationResult = ProductUserRelationResult(value: MockUserProductRelation.makeMock())
        mockProductRepository.statsResult = ProductStatsResult(value: MockProductStats.makeMock())
        mockProductRepository.incrementViewsResult = ProductVoidResult(value: Void())
        mockProductRepository.productBuyersResult = ProductBuyersResult(value: MockUserProduct.makeMocks(count: Int.makeRandom(min: 0, max: 10)))
        return mockProductRepository
    }
}
