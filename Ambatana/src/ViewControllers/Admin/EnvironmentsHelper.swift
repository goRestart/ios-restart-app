import LGCoreKit
import LGComponents

final class EnvironmentsHelper {
    
    private enum LaunchArgument: String {
        case production = "-environment-prod"
        case staging = "-environment-dev"
        case escrow = "-environment-escrow"
        
        var environmentType: EnvironmentType {
            switch self {
            case .production: return .production
            case .staging: return .staging
            case .escrow: return .escrow
            }
        }
    }

    private let godmode: Bool

    /// Environment type that CoreKit should be initialized with.
    private(set) public var serverEnvironment: EnvironmentType
    
    /// Maps CoreKit's environment type to AppEnvironmentType
    var appEnvironment: AppEnvironmentType {
        switch serverEnvironment {
        case .staging: return .development
        case .production, .canary: return .production
        case .escrow: return .escrow
        }
    }

    init(godmode: Bool) {
        self.godmode = godmode
        serverEnvironment = .production
        if godmode {
            serverEnvironment = appLaunchArgumentEnvironment() ?? storedEnvironement() ?? .production
            let lastExecutionServerEnvironment = lastExecutionStoredEnvironement() ?? .production
            if serverEnvironment != lastExecutionServerEnvironment {
                removeInstallationAndUserKeys()
            }
            KeyValueStorage.sharedInstance[.serverEnvironment] = serverEnvironment.rawValue
            KeyValueStorage.sharedInstance[.lastServerEnvironment] = serverEnvironment.rawValue
        }
    }
    
    private func appLaunchArgumentEnvironment() -> EnvironmentType? {
        let envArgs = ProcessInfo.processInfo.environment
        return envArgs.keys.compactMap(LaunchArgument.init).first?.environmentType
    }
    
    private func storedEnvironement() -> EnvironmentType? {
        return EnvironmentType(rawValue: KeyValueStorage.sharedInstance[.serverEnvironment])
    }
    
    private func lastExecutionStoredEnvironement() -> EnvironmentType? {
        return EnvironmentType(rawValue: KeyValueStorage.sharedInstance[.lastServerEnvironment])
    }
    
    /// Deletes CoreKit "installation" and "MyUser" defaults to force a cleanup
    private func removeInstallationAndUserKeys() {
        guard godmode else { return }
        let userDefaults = UserDefaults()
        userDefaults.removeObject(forKey: "Installation")
        userDefaults.removeObject(forKey: "MyUser")
    }
}
