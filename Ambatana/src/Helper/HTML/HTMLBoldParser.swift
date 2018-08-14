
private enum Tags {
    static let openTag: Character = "<"
    static let closeTag: Character = ">"
    static let bold: String = "<b>"
    static let closeBold: String = "</b>"
}

enum StyledString: Equatable {
    case normal(text: String)
    case bold(text: String)
}

final class HTMLBoldParser {

    /// This method takes a html buffer and convert all the bold
    /// tags into attrb str slices.
    /// WARNING: This method does not support nested bold tags.
    /// - parameter htmlBuffer: Buffer to parse.
    /// - returns: A list of styled text.
    static func parse(htmlBuffer: String) -> [StyledString] {
        var chunks: [StyledString] = []
        
        var i = 0
        var boldOpened = false
        var tempBuffer = ""
        
        while i < htmlBuffer.count {
            defer { i += 1 }
            
            let currentIndex = htmlBuffer.index(htmlBuffer.startIndex, offsetBy: i)
            guard htmlBuffer[currentIndex] == Tags.openTag else {
                tempBuffer.append(htmlBuffer[currentIndex])
                continue
            }
            
            let j = findCloseCharacter(buffer: htmlBuffer, startIndex: i)
            
            let tag = htmlBuffer[
                currentIndex...htmlBuffer.index(htmlBuffer.startIndex, offsetBy: j)
            ]
            
            if tag != Tags.bold && tag != Tags.closeBold {
                tempBuffer.append(htmlBuffer[currentIndex])
                continue
            }
            
            // Check tag type.
            if tag == Tags.bold && !boldOpened {
                chunks.append(.normal(text: tempBuffer))
                boldOpened = true
                tempBuffer = ""
                i += tag.count - 1
            } else if tag == Tags.bold && boldOpened || tag == Tags.closeBold && !boldOpened {
                tempBuffer.append(Tags.openTag)
            } else if tag == Tags.closeBold && boldOpened {
                chunks.append(.bold(text: tempBuffer))
                boldOpened = false
                tempBuffer = ""
                i += tag.count - 1
            }
        }
        
        if tempBuffer != "" { chunks.append(.normal(text: tempBuffer)) }
        
        return chunks
    }
    
    static private func findCloseCharacter(buffer: String, startIndex: Int) -> Int {
        var j = startIndex
        while j < buffer.count {
            let endIndex = buffer.index(buffer.startIndex, offsetBy: j)
            if buffer[endIndex] == Tags.closeTag { break }
            j += 1
        }
        return j
    }
}
