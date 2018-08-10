import Foundation

public enum Directory {
    case documents
    case caches
}

public enum DirectoryPath: String {
    case feed = "feed/old_feed"
}

private extension Directory {
    var searchPathDirectorty: FileManager.SearchPathDirectory {
        switch self {
        case .documents: return .documentDirectory
        case .caches: return .cachesDirectory
        }
    }
    
    var pathDescription: String {
        switch self {
        case .documents: return "<letgo>/Documents"
        case .caches: return "<letgo>/Cache"
        }
    }
}

public protocol Disk {
    func save<T: Encodable>(_ value: T, to directory: Directory, with path: DirectoryPath) throws
    func retrieve<T: Decodable>(_ path: DirectoryPath, from directory: Directory, as type: T.Type) throws -> T
}

public enum ErrorCode: Int {
    case buildPath
    case noFileFound
    case serialization
    case deserialization
    case invalidFileName
    case couldNotAccessUserDomainMask
}

public class FileManagerDisk: Disk {
    static let filePrefix = "file://"
    public static let domain = "com.letgo.filemanager"
    
    public init() {}
    
    public func save<T: Encodable>(_ value: T, to directory: Directory, with path: DirectoryPath) throws {
        do {
            let url = try buildURL(for: path.rawValue, in: directory)
            let encoder = JSONEncoder()
            let data = try encoder.encode(value)
            try buildSubfoldersBeforeCreatingFile(at: url)
            try data.write(to: url, options: .atomic)
        } catch {
            throw error
        }
    }
    
    public func retrieve<T: Decodable>(_ path: DirectoryPath, from directory: Directory, as type: T.Type) throws -> T {
        do {
            guard let url = try existingFileURL(for: path, in: directory) else {
                throw FileManagerDisk.buildError(.noFileFound,
                                        description: "Could not find the specified resource",
                                        failureReason: "There is nothing there",
                                        recoverySuggestion: "Make sure there is something before retrieving it")
            }
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let value = try decoder.decode(type, from: data)
            return value
        } catch {
            throw error
        }
    }
}

extension Disk {
    func existingFileURL(for path: DirectoryPath, in directory: Directory) throws -> URL? {
        let url = try buildURL(for: path.rawValue, in: directory)
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        return url
    }
    
    func buildURL(for path: String?, in directory: Directory) throws -> URL {
        let filePrefix = FileManagerDisk.filePrefix
        var validPath: String? = nil
        if let path = path {
            do {
                validPath = try buildValidFilePath(from: path)
            } catch {
                throw error
            }
        }
        let searchPathDirectory = directory.searchPathDirectorty
        
        if var url = FileManager.default.urls(for: searchPathDirectory, in: .userDomainMask).first {
            if let validPath = validPath {
                url = url.appendingPathComponent(validPath, isDirectory: false)
            }
            if url.absoluteString.lowercased().prefix(filePrefix.count) != filePrefix {
                let fixedUrlString = filePrefix + url.absoluteString
                if let appended = URL(string: fixedUrlString) {
                    return appended
                }
                throw FileManagerDisk.buildError(.buildPath,
                                        description: "Could not build url for the given encodable",
                                        failureReason: "Could not append file prefix due to URL implementations",
                                        recoverySuggestion: "File a Radar")
            }
            return url
        } else {
            throw FileManagerDisk
                .buildError(
                .couldNotAccessUserDomainMask,
                description: "Could not create URL for \(directory.pathDescription)/\(validPath ?? "")",
                failureReason: "Could not get access to the file system's user domain mask.",
                recoverySuggestion: "Use a different directory."
            )
        }
    }
    
    func buildValidFilePath(from originalString: String) throws -> String {
        var invalidCharacters = CharacterSet(charactersIn: ":")
        invalidCharacters.formUnion(.newlines)
        invalidCharacters.formUnion(.illegalCharacters)
        invalidCharacters.formUnion(.controlCharacters)
        let pathWithoutIllegalCharacters = originalString
            .components(separatedBy: invalidCharacters)
            .joined(separator: "")
        let validFileName = removeSlashesAtBeginning(of: pathWithoutIllegalCharacters)
        guard validFileName.count > 0  && validFileName != "." else {
            throw FileManagerDisk.buildError(
                .invalidFileName,
                description: "\(originalString) is an invalid file name.",
                failureReason: "Cannot write/read a file with the name \(originalString) on disk.",
                recoverySuggestion: "Use another file name with alphanumeric characters."
            )
        }
        return validFileName
    }
    
    func removeSlashesAtBeginning(of string: String) -> String {
        var string = string
        if string.prefix(1) == "/" {
            string.remove(at: string.startIndex)
        }
        if string.prefix(1) == "/" {
            string = removeSlashesAtBeginning(of: string)
        }
        return string
    }
    
    func buildSubfoldersBeforeCreatingFile(at url: URL) throws {
        do {
            let subfolderUrl = url.deletingLastPathComponent()
            var subfolderExists = false
            var isDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: subfolderUrl.path, isDirectory: &isDirectory) {
                if isDirectory.boolValue {
                    subfolderExists = true
                }
            }
            if !subfolderExists {
                try FileManager.default.createDirectory(at: subfolderUrl, withIntermediateDirectories: true, attributes: nil)
            }
        } catch {
            throw error
        }
    }
}

private extension URL {
    var isFolder: Bool {
        var isDirectory: ObjCBool = false // 😱
        guard FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory),
            isDirectory.boolValue else {
            return false
        }
        return true
    }
}

extension FileManagerDisk {
    static func buildError(_ errorCode: ErrorCode,
                           description: String?,
                           failureReason: String?,
                           recoverySuggestion: String?) -> Error {
        let errorInfo: [String: Any] = [NSLocalizedDescriptionKey : description ?? "",
                                        NSLocalizedRecoverySuggestionErrorKey: recoverySuggestion ?? "",
                                        NSLocalizedFailureReasonErrorKey: failureReason ?? ""]
        return NSError(domain: FileManagerDisk.domain, code: errorCode.rawValue, userInfo: errorInfo)
    }
}

