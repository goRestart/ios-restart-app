import Foundation

@testable import LetGoGodMode
import Quick
import Nimble

class HTMLBoldParserSepc: QuickSpec {
    override func spec() {
        describe("parse") {
            var chunks: [StyledString] = []
            
            beforeEach {
                chunks = HTMLBoldParser.parse(htmlBuffer: "BATMAN <b>SUPERMAN</b> <ACUAMAN> </b> BENJAMIN JOSEPH FRANKLIN <b>OBAMA</b> <>KICHNER</b> <b>LADRON</b> <<>> << < <>>")
            }
            
            it("should contain the correct amount of pieces") {
                expect(chunks.count) == 7
            }
            
            it("should contain the corret values") {
                expect(chunks[0] == StyledString.normal(text: "BATMAN ")) == true
                expect(chunks[1] == StyledString.bold(text: "SUPERMAN")) == true
                expect(chunks[2] == StyledString.normal(text: " <ACUAMAN> </b> BENJAMIN JOSEPH FRANKLIN ")) == true
                expect(chunks[3] == StyledString.bold(text: "OBAMA")) == true
                expect(chunks[4] == StyledString.normal(text: " <>KICHNER</b> ")) == true
                expect(chunks[5] == StyledString.bold(text: "LADRON")) == true
            }
        }
    }
}
