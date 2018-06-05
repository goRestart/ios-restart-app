final class LGImageMultiplierRepository: ImageMultiplierRepository {

    private let dataSource: ImageMultiplierDataSource
    private static let maxOfImages = 15
    
    // MARK: - Lifecycle
    
    init(dataSource: ImageMultiplierDataSource) {
        self.dataSource = dataSource
    }
    
    // MARK: - Public methods
    
    func imageMultiplier(_ parameters: ImageMultiplierParams, completion: ImageMultiplierCompletion?) {
        guard parameters.times <= LGImageMultiplierRepository.maxOfImages else {
            completion?(ImageMultiplierResult(error: RepositoryError.internalError(message:
                "ImageMultiplierRepository - Max of images to be created is \(LGImageMultiplierRepository.maxOfImages)")))
            return
        }
        dataSource.imageMultiplier(parameters.apiParams, completion: update(completion))
    }
    
    // MARK: - Private methods
    
    private func update(_ completion: ImageMultiplierCompletion?) -> ImageMultiplierDataSourceCompletion {
        return { result in
            if let error = result.error {
                completion?(ImageMultiplierResult(error: RepositoryError(apiError: error)))
            } else if let imageIds = result.value {
                let updatedValues: [String] = imageIds.filter { !$0.isEmpty }
                completion?(ImageMultiplierResult(value: updatedValues))
            }
        }
    }
}


