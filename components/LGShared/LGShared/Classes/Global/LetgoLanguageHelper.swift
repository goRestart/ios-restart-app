import Foundation
import LGComponents

final public class LetgoLanguageHelper {

    private static let defaultLang = "en"

    public static func systemLanguage() -> String {
        let preferredLanguages = Locale.preferredLanguages
        guard !preferredLanguages.isEmpty else { return LetgoLanguageHelper.defaultLang }

        for preferredLanguage in preferredLanguages {
            // In case it's like es-ES, just take the first "es"
            let components = preferredLanguage.components(separatedBy: "-")
            guard let lang = components.first else { continue }
            return lang.lowercased()
        }
        return LetgoLanguageHelper.defaultLang
    }
}
