import Foundation
import CoreText

public extension UnicodeScalar {
    var isEmoji: Bool {
        // Full emoji list http://unicode.org/emoji/charts/full-emoji-list.html
        // Emoji ranges https://en.wikipedia.org/wiki/Emoji#Unicode_blocks
        // Currently not handeling emojis that mixup normal characters like: 8️⃣*️⃣❗🅱🈶🈺◼🔴⬅◀🃏⏱
        // We would need to have stored all permutations with normal characters to fix this which is a bit overkill
        switch value {
        case
        0x1F600...0x1F64F,  // Emoticons
        0x1F300...0x1F5FF,  // Misc Symbols and Pictographs
        0x1F680...0x1F6FF,  // Transport and Map
        0x1F1E6...0x1F1FF,  // Regional country flags
        0x2600...0x26FF,    // Misc symbols
        0x2700...0x27BF,    // Dingbats
        0xFE00...0xFE0F,    // Variation Selectors
        0x1F900...0x1F9FF,  // Supplemental Symbols and Pictographs
        65024...65039,      // Variation selector
        8400...8447:        // Combining Diacritical Marks for Symbols
            return true
        default:
            return false
        }
    }
    
    // https://emojipedia.org/zero-width-joiner/
    var isZeroWidthJoiner: Bool {
        return value == 8205
    }
}

public extension String {
    var containsEmoji: Bool {
        return unicodeScalars.contains { $0.isEmoji }
    }
    
    var containsOnlyEmoji: Bool {
        return !isEmpty && !unicodeScalars.contains(where: { !$0.isEmoji && !$0.isZeroWidthJoiner })
    }
    
    var emojiOnlyCount: Int {
        return containsOnlyEmoji ? glyphCount : 0
    }
    
    func removingEmoji() -> String {
        return unicodeScalars
            .filter { !$0.isZeroWidthJoiner && !$0.isEmoji }
            .map { String($0) }
            .reduce("", +)
    }
    
    private var glyphCount: Int {
        let richText = NSAttributedString(string: self)
        let line = CTLineCreateWithAttributedString(richText)
        return CTLineGetGlyphCount(line)
    }
}
