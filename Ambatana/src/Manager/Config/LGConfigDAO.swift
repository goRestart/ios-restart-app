import LGComponents

class LGConfigDAO : ConfigDAO {
    let fileCachePath : String

    // MARK: - Lifecycle

    init(bundle: Bundle, configFileName: String) {
        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0] as NSString
        fileCachePath = cachePath.appending("/\(configFileName).json")

        // If it's not in cache directory, then copy it from bundle
        let fm = FileManager.default

        if !fm.fileExists(atPath: fileCachePath) {
            let path = bundle.path(forResource: configFileName, ofType: "json")

            if let fileBundlePath = path {
                do {
                    try fm.copyItem(atPath: fileBundlePath, toPath: fileCachePath)
                } catch _ {}
            }
        }
    }

    // MARK: - Public methods

    func retrieve() -> Config? {

        let fm = FileManager.default

        // Cached in cache directory
        var path: String? = nil
        if fm.fileExists(atPath: fileCachePath) {
            path = fileCachePath
        }

        // If we don't have a path or the data cannot be loaded, then exit
        guard let actualPath = path, let data = try? Data(contentsOf: URL(fileURLWithPath: actualPath)) else {
            return nil
        }

        do {
            let config = try Config.decode(jsonData: data)
            return config
        } catch {
            logMessage(.debug, type: .parsing, message: "Could not parse config \(data)")
        }
        return nil
    }

    func save(_ configFile: Config) {
        do {
            let configData = try configFile.encodeJSON()
            // save into cache
            let fm = FileManager.default
            if !fm.fileExists(atPath: fileCachePath) {
                fm.createFile(atPath: fileCachePath, contents: configData, attributes: nil)
            }
            else {
                do {
                    try fm.removeItem(atPath: fileCachePath)
                } catch _ {}
                fm.createFile(atPath: fileCachePath, contents: configData, attributes: nil)
            }
        } catch {
            logMessage(.debug, type: .parsing, message: "Could not encode config \(configFile)")
        }
    }
}
