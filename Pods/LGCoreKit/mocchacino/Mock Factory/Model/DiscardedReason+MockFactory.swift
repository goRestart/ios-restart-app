extension DiscardedReason: MockFactory {
    public static func makeMock() -> DiscardedReason {
        let allValues: [DiscardedReason] = [
            .badManners, .duplicated, .drugsAndMedicines, .gambling, .nonRealisticPrice, .poorAdQuality, .photoUnclear,
            .sexuallyRelated, .referenceToCompetitors, .usedCosmetics, .weaponsRelated, .illegalContent, .perishables,
            .animals, .services, .suspectedScam, .copyright, .others, .tobacco, .recall, .stockPhotoOnly
        ]
        return allValues.random()!
    }
}
