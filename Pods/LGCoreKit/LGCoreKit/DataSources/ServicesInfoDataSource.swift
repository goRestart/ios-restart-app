import Result

typealias ServicesInfoDataSourceResult = Result<[ServiceType], ApiError>
typealias ServicesInfoDataSourceCompletion = (ServicesInfoDataSourceResult) -> Void

protocol ServicesInfoDataSource {
    func index(locale: String?, completion: ServicesInfoDataSourceCompletion?)
}
