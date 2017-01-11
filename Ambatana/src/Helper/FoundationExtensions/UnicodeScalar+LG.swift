//
//  UnicodeScalar+LG.swift
//  LetGo
//
//  Created by Eli Kohen on 09/06/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

extension Character {
    var isEmoji: Bool {
        return String(self).unicodeScalars.reduce(false) { $0 || $1.isEmoji }
    }
}

extension UnicodeScalar {

    var isEmoji: Bool {
        return UnicodeScalar.emojiScalars.contains(self)
    }

    /*List from http://unicode.org/emoji/charts/full-emoji-list.html
     download the page into a file emoji.html an then:
     #>  cat emoji.html | grep "<td class='code'>" | grep -hoe 'U[+][A-Z0-9]*' | sed 's/U+/0x/g' | awk '!seen[$0]++' | awk '{print "if let value = UnicodeScalar(UInt32("$0")) {\n\tscalars.insert(value)\n}"}' > final.txt
     */
    static let emojiScalars: Set<UnicodeScalar> = {
        var scalars: Set<UnicodeScalar> = []
        if let value = UnicodeScalar(UInt32(0x1F004)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F0CF)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F170)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F171)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F17E)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F17F)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F18E)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F191)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F192)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F193)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F194)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F195)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F196)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F197)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F198)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F199)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F19A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F1E6)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F1E7)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F1E8)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F1E9)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F1EA)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F1EB)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F1EC)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F1ED)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F1EE)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F1EF)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F1F0)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F1F1)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F1F2)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F1F3)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F1F4)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F1F5)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F1F6)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F1F7)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F1F8)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F1F9)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F1FA)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F1FB)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F1FC)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F1FD)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F1FE)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F1FF)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F201)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F202)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F21A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F22F)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F232)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F233)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F234)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F235)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F236)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F237)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F238)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F239)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F23A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F250)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F251)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F300)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F301)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F302)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F303)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F304)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F305)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F306)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F307)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F308)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F309)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F30A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F30B)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F30C)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F30D)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F30E)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F30F)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F310)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F311)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F312)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F313)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F314)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F315)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F316)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F317)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F318)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F319)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F31A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F31B)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F31C)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F31D)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F31E)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F31F)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F320)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F321)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F324)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F325)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F326)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F327)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F328)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F329)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F32A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F32B)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F32C)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F32D)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F32E)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F32F)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F330)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F331)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F332)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F333)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F334)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F335)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F336)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F337)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F338)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F339)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F33A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F33B)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F33C)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F33D)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F33E)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F33F)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F340)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F341)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F342)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F343)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F344)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F345)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F346)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F347)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F348)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F349)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F34A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F34B)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F34C)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F34D)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F34E)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F34F)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F350)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F351)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F352)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F353)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F354)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F355)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F356)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F357)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F358)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F359)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F35A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F35B)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F35C)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F35D)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F35E)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F35F)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F360)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F361)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F362)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F363)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F364)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F365)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F366)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F367)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F368)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F369)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F36A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F36B)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F36C)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F36D)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F36E)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F36F)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F370)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F371)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F372)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F373)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F374)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F375)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F376)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F377)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F378)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F379)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F37A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F37B)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F37C)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F37D)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F37E)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F37F)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F380)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F381)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F382)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F383)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F384)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F385)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F386)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F387)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F388)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F389)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F38A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F38B)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F38C)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F38D)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F38E)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F38F)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F390)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F391)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F392)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F393)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F396)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F397)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F399)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F39A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F39B)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F39E)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F39F)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3A0)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3A1)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3A2)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3A3)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3A4)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3A5)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3A6)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3A7)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3A8)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3A9)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3AA)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3AB)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3AC)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3AD)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3AE)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3AF)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3B0)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3B1)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3B2)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3B3)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3B4)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3B5)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3B6)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3B7)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3B8)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3B9)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3BA)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3BB)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3BC)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3BD)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3BE)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3BF)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3C0)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3C1)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3C2)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3C3)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3C4)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3C5)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3C6)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3C7)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3C8)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3C9)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3CA)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3CB)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3CC)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3CD)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3CE)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3CF)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3D0)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3D1)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3D2)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3D3)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3D4)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3D5)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3D6)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3D7)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3D8)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3D9)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3DA)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3DB)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3DC)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3DD)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3DE)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3DF)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3E0)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3E1)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3E2)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3E3)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3E4)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3E5)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3E6)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3E7)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3E8)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3E9)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3EA)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3EB)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3EC)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3ED)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3EE)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3EF)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3F0)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3F3)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3F4)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3F5)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3F7)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3F8)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3F9)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3FA)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3FB)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3FC)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3FD)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3FE)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F3FF)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F400)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F401)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F402)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F403)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F404)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F405)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F406)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F407)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F408)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F409)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F40A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F40B)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F40C)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F40D)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F40E)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F40F)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F410)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F411)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F412)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F413)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F414)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F415)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F416)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F417)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F418)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F419)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F41A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F41B)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F41C)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F41D)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F41E)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F41F)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F420)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F421)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F422)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F423)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F424)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F425)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F426)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F427)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F428)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F429)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F42A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F42B)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F42C)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F42D)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F42E)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F42F)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F430)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F431)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F432)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F433)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F434)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F435)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F436)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F437)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F438)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F439)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F43A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F43B)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F43C)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F43D)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F43E)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F43F)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F440)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F441)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F442)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F443)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F444)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F445)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F446)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F447)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F448)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F449)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F44A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F44B)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F44C)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F44D)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F44E)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F44F)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F450)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F451)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F452)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F453)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F454)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F455)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F456)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F457)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F458)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F459)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F45A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F45B)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F45C)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F45D)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F45E)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F45F)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F460)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F461)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F462)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F463)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F464)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F465)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F466)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F467)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F468)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F469)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F46A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F46B)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F46C)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F46D)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F46E)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F46F)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F470)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F471)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F472)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F473)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F474)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F475)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F476)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F477)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F478)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F479)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F47A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F47B)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F47C)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F47D)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F47E)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F47F)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F480)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F481)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F482)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F483)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F484)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F485)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F486)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F487)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F488)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F489)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F48A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F48B)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F48C)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F48D)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F48E)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F48F)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F490)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F491)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F492)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F493)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F494)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F495)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F496)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F497)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F498)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F499)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F49A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F49B)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F49C)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F49D)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F49E)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F49F)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4A0)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4A1)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4A2)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4A3)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4A4)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4A5)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4A6)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4A7)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4A8)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4A9)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4AA)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4AB)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4AC)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4AD)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4AE)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4AF)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4B0)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4B1)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4B2)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4B3)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4B4)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4B5)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4B6)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4B7)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4B8)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4B9)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4BA)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4BB)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4BC)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4BD)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4BE)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4BF)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4C0)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4C1)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4C2)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4C3)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4C4)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4C5)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4C6)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4C7)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4C8)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4C9)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4CA)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4CB)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4CC)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4CD)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4CE)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4CF)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4D0)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4D1)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4D2)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4D3)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4D4)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4D5)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4D6)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4D7)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4D8)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4D9)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4DA)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4DB)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4DC)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4DD)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4DE)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4DF)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4E0)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4E1)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4E2)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4E3)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4E4)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4E5)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4E6)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4E7)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4E8)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4E9)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4EA)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4EB)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4EC)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4ED)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4EE)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4EF)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4F0)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4F1)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4F2)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4F3)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4F4)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4F5)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4F6)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4F7)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4F8)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4F9)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4FA)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4FB)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4FC)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4FD)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F4FF)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F500)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F501)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F502)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F503)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F504)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F505)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F506)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F507)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F508)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F509)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F50A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F50B)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F50C)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F50D)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F50E)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F50F)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F510)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F511)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F512)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F513)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F514)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F515)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F516)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F517)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F518)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F519)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F51A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F51B)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F51C)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F51D)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F51E)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F51F)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F520)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F521)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F522)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F523)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F524)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F525)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F526)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F527)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F528)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F529)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F52A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F52B)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F52C)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F52D)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F52E)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F52F)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F530)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F531)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F532)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F533)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F534)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F535)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F536)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F537)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F538)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F539)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F53A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F53B)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F53C)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F53D)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F549)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F54A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F54B)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F54C)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F54D)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F54E)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F550)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F551)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F552)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F553)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F554)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F555)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F556)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F557)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F558)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F559)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F55A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F55B)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F55C)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F55D)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F55E)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F55F)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F560)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F561)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F562)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F563)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F564)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F565)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F566)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F567)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F56F)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F570)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F573)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F574)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F575)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F576)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F577)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F578)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F579)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F57A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F587)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F58A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F58B)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F58C)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F58D)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F590)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F595)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F596)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F5A4)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F5A5)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F5A8)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F5B1)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F5B2)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F5BC)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F5C2)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F5C3)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F5C4)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F5D1)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F5D2)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F5D3)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F5DC)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F5DD)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F5DE)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F5E1)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F5E3)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F5E8)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F5EF)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F5F3)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F5FA)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F5FB)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F5FC)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F5FD)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F5FE)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F5FF)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F600)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F601)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F602)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F603)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F604)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F605)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F606)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F607)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F608)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F609)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F60A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F60B)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F60C)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F60D)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F60E)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F60F)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F610)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F611)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F612)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F613)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F614)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F615)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F616)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F617)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F618)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F619)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F61A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F61B)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F61C)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F61D)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F61E)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F61F)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F620)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F621)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F622)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F623)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F624)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F625)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F626)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F627)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F628)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F629)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F62A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F62B)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F62C)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F62D)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F62E)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F62F)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F630)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F631)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F632)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F633)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F634)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F635)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F636)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F637)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F638)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F639)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F63A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F63B)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F63C)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F63D)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F63E)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F63F)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F640)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F641)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F642)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F643)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F644)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F645)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F646)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F647)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F648)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F649)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F64A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F64B)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F64C)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F64D)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F64E)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F64F)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F680)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F681)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F682)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F683)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F684)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F685)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F686)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F687)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F688)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F689)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F68A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F68B)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F68C)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F68D)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F68E)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F68F)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F690)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F691)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F692)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F693)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F694)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F695)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F696)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F697)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F698)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F699)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F69A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F69B)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F69C)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F69D)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F69E)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F69F)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6A0)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6A1)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6A2)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6A3)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6A4)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6A5)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6A6)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6A7)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6A8)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6A9)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6AA)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6AB)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6AC)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6AD)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6AE)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6AF)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6B0)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6B1)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6B2)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6B3)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6B4)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6B5)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6B6)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6B7)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6B8)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6B9)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6BA)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6BB)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6BC)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6BD)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6BE)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6BF)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6C0)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6C1)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6C2)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6C3)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6C4)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6C5)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6CB)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6CC)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6CD)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6CE)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6CF)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6D0)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6D1)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6D2)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6E0)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6E1)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6E2)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6E3)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6E4)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6E5)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6E9)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6EB)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6EC)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6F0)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6F3)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6F4)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6F5)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F6F6)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F910)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F911)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F912)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F913)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F914)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F915)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F916)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F917)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F918)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F919)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F91A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F91B)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F91C)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F91D)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F91E)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F920)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F921)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F922)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F923)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F924)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F925)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F926)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F927)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F930)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F933)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F934)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F935)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F936)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F937)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F938)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F939)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F93A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F93C)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F93D)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F93E)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F940)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F941)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F942)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F943)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F944)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F945)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F947)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F948)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F949)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F94A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F94B)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F950)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F951)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F952)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F953)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F954)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F955)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F956)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F957)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F958)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F959)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F95A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F95B)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F95C)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F95D)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F95E)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F980)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F981)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F982)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F983)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F984)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F985)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F986)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F987)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F988)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F989)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F98A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F98B)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F98C)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F98D)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F98E)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F98F)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F990)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F991)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x1F9C0)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x200D)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x203C)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2049)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x20E3)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2122)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2139)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2194)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2195)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2196)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2197)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2198)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2199)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x21A9)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x21AA)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x231A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x231B)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2328)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x23CF)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x23E9)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x23EA)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x23EB)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x23EC)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x23ED)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x23EE)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x23EF)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x23F0)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x23F1)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x23F2)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x23F3)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x23F8)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x23F9)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x23FA)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x24C2)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x25AA)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x25AB)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x25B6)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x25C0)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x25FB)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x25FC)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x25FD)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x25FE)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2600)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2601)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2602)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2603)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2604)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x260E)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2611)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2614)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2615)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2618)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x261D)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2620)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2622)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2623)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2626)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x262A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x262E)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x262F)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2638)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2639)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x263A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2648)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2649)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x264A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x264B)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x264C)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x264D)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x264E)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x264F)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2650)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2651)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2652)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2653)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2660)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2663)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2665)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2666)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2668)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x267B)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x267F)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2692)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2693)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2694)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2696)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2697)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2699)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x269B)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x269C)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x26A0)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x26A1)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x26AA)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x26AB)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x26B0)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x26B1)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x26BD)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x26BE)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x26C4)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x26C5)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x26C8)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x26CE)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x26CF)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x26D1)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x26D3)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x26D4)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x26E9)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x26EA)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x26F0)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x26F1)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x26F2)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x26F3)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x26F4)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x26F5)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x26F7)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x26F8)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x26F9)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x26FA)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x26FD)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2702)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2705)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2708)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2709)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x270A)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x270B)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x270C)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x270D)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x270F)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2712)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2714)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2716)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x271D)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2721)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2728)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2733)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2734)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2744)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2747)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x274C)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x274E)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2753)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2754)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2755)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2757)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2763)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2764)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2795)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2796)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2797)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x27A1)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x27B0)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x27BF)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2934)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2935)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2B05)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2B06)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2B07)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2B1B)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2B1C)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2B50)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x2B55)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x3030)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x303D)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x3297)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0x3299)) {
            scalars.insert(value)
        }
        if let value = UnicodeScalar(UInt32(0xFE0F)) {
            scalars.insert(value)
        }
        return scalars
    }()
}
