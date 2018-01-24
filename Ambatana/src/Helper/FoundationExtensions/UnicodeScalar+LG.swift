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
     #>  cat emoji.html | grep "<td class='code'>" | grep -hoe 'U[+][A-Z0-9]*' | sed 's/U+/0x/g' | awk '!seen[$0]++' | awk '{print "addScalar"$0")"}' > final.txt
     */
    static let emojiScalars: Set<UnicodeScalar> = {
        var scalars: Set<UnicodeScalar> = []

        func addScalar(_ value: UInt32) {
            if let unicode = UnicodeScalar(value) {
                scalars.insert(unicode)
            }
        }

        addScalar(0x1F004)
        addScalar(0x1F0CF)
        addScalar(0x1F170)
        addScalar(0x1F171)
        addScalar(0x1F17E)
        addScalar(0x1F17F)
        addScalar(0x1F18E)
        addScalar(0x1F191)
        addScalar(0x1F192)
        addScalar(0x1F193)
        addScalar(0x1F194)
        addScalar(0x1F195)
        addScalar(0x1F196)
        addScalar(0x1F197)
        addScalar(0x1F198)
        addScalar(0x1F199)
        addScalar(0x1F19A)
        addScalar(0x1F1E6)
        addScalar(0x1F1E7)
        addScalar(0x1F1E8)
        addScalar(0x1F1E9)
        addScalar(0x1F1EA)
        addScalar(0x1F1EB)
        addScalar(0x1F1EC)
        addScalar(0x1F1ED)
        addScalar(0x1F1EE)
        addScalar(0x1F1EF)
        addScalar(0x1F1F0)
        addScalar(0x1F1F1)
        addScalar(0x1F1F2)
        addScalar(0x1F1F3)
        addScalar(0x1F1F4)
        addScalar(0x1F1F5)
        addScalar(0x1F1F6)
        addScalar(0x1F1F7)
        addScalar(0x1F1F8)
        addScalar(0x1F1F9)
        addScalar(0x1F1FA)
        addScalar(0x1F1FB)
        addScalar(0x1F1FC)
        addScalar(0x1F1FD)
        addScalar(0x1F1FE)
        addScalar(0x1F1FF)
        addScalar(0x1F201)
        addScalar(0x1F202)
        addScalar(0x1F21A)
        addScalar(0x1F22F)
        addScalar(0x1F232)
        addScalar(0x1F233)
        addScalar(0x1F234)
        addScalar(0x1F235)
        addScalar(0x1F236)
        addScalar(0x1F237)
        addScalar(0x1F238)
        addScalar(0x1F239)
        addScalar(0x1F23A)
        addScalar(0x1F250)
        addScalar(0x1F251)
        addScalar(0x1F300)
        addScalar(0x1F301)
        addScalar(0x1F302)
        addScalar(0x1F303)
        addScalar(0x1F304)
        addScalar(0x1F305)
        addScalar(0x1F306)
        addScalar(0x1F307)
        addScalar(0x1F308)
        addScalar(0x1F309)
        addScalar(0x1F30A)
        addScalar(0x1F30B)
        addScalar(0x1F30C)
        addScalar(0x1F30D)
        addScalar(0x1F30E)
        addScalar(0x1F30F)
        addScalar(0x1F310)
        addScalar(0x1F311)
        addScalar(0x1F312)
        addScalar(0x1F313)
        addScalar(0x1F314)
        addScalar(0x1F315)
        addScalar(0x1F316)
        addScalar(0x1F317)
        addScalar(0x1F318)
        addScalar(0x1F319)
        addScalar(0x1F31A)
        addScalar(0x1F31B)
        addScalar(0x1F31C)
        addScalar(0x1F31D)
        addScalar(0x1F31E)
        addScalar(0x1F31F)
        addScalar(0x1F320)
        addScalar(0x1F321)
        addScalar(0x1F324)
        addScalar(0x1F325)
        addScalar(0x1F326)
        addScalar(0x1F327)
        addScalar(0x1F328)
        addScalar(0x1F329)
        addScalar(0x1F32A)
        addScalar(0x1F32B)
        addScalar(0x1F32C)
        addScalar(0x1F32D)
        addScalar(0x1F32E)
        addScalar(0x1F32F)
        addScalar(0x1F330)
        addScalar(0x1F331)
        addScalar(0x1F332)
        addScalar(0x1F333)
        addScalar(0x1F334)
        addScalar(0x1F335)
        addScalar(0x1F336)
        addScalar(0x1F337)
        addScalar(0x1F338)
        addScalar(0x1F339)
        addScalar(0x1F33A)
        addScalar(0x1F33B)
        addScalar(0x1F33C)
        addScalar(0x1F33D)
        addScalar(0x1F33E)
        addScalar(0x1F33F)
        addScalar(0x1F340)
        addScalar(0x1F341)
        addScalar(0x1F342)
        addScalar(0x1F343)
        addScalar(0x1F344)
        addScalar(0x1F345)
        addScalar(0x1F346)
        addScalar(0x1F347)
        addScalar(0x1F348)
        addScalar(0x1F349)
        addScalar(0x1F34A)
        addScalar(0x1F34B)
        addScalar(0x1F34C)
        addScalar(0x1F34D)
        addScalar(0x1F34E)
        addScalar(0x1F34F)
        addScalar(0x1F350)
        addScalar(0x1F351)
        addScalar(0x1F352)
        addScalar(0x1F353)
        addScalar(0x1F354)
        addScalar(0x1F355)
        addScalar(0x1F356)
        addScalar(0x1F357)
        addScalar(0x1F358)
        addScalar(0x1F359)
        addScalar(0x1F35A)
        addScalar(0x1F35B)
        addScalar(0x1F35C)
        addScalar(0x1F35D)
        addScalar(0x1F35E)
        addScalar(0x1F35F)
        addScalar(0x1F360)
        addScalar(0x1F361)
        addScalar(0x1F362)
        addScalar(0x1F363)
        addScalar(0x1F364)
        addScalar(0x1F365)
        addScalar(0x1F366)
        addScalar(0x1F367)
        addScalar(0x1F368)
        addScalar(0x1F369)
        addScalar(0x1F36A)
        addScalar(0x1F36B)
        addScalar(0x1F36C)
        addScalar(0x1F36D)
        addScalar(0x1F36E)
        addScalar(0x1F36F)
        addScalar(0x1F370)
        addScalar(0x1F371)
        addScalar(0x1F372)
        addScalar(0x1F373)
        addScalar(0x1F374)
        addScalar(0x1F375)
        addScalar(0x1F376)
        addScalar(0x1F377)
        addScalar(0x1F378)
        addScalar(0x1F379)
        addScalar(0x1F37A)
        addScalar(0x1F37B)
        addScalar(0x1F37C)
        addScalar(0x1F37D)
        addScalar(0x1F37E)
        addScalar(0x1F37F)
        addScalar(0x1F380)
        addScalar(0x1F381)
        addScalar(0x1F382)
        addScalar(0x1F383)
        addScalar(0x1F384)
        addScalar(0x1F385)
        addScalar(0x1F386)
        addScalar(0x1F387)
        addScalar(0x1F388)
        addScalar(0x1F389)
        addScalar(0x1F38A)
        addScalar(0x1F38B)
        addScalar(0x1F38C)
        addScalar(0x1F38D)
        addScalar(0x1F38E)
        addScalar(0x1F38F)
        addScalar(0x1F390)
        addScalar(0x1F391)
        addScalar(0x1F392)
        addScalar(0x1F393)
        addScalar(0x1F396)
        addScalar(0x1F397)
        addScalar(0x1F399)
        addScalar(0x1F39A)
        addScalar(0x1F39B)
        addScalar(0x1F39E)
        addScalar(0x1F39F)
        addScalar(0x1F3A0)
        addScalar(0x1F3A1)
        addScalar(0x1F3A2)
        addScalar(0x1F3A3)
        addScalar(0x1F3A4)
        addScalar(0x1F3A5)
        addScalar(0x1F3A6)
        addScalar(0x1F3A7)
        addScalar(0x1F3A8)
        addScalar(0x1F3A9)
        addScalar(0x1F3AA)
        addScalar(0x1F3AB)
        addScalar(0x1F3AC)
        addScalar(0x1F3AD)
        addScalar(0x1F3AE)
        addScalar(0x1F3AF)
        addScalar(0x1F3B0)
        addScalar(0x1F3B1)
        addScalar(0x1F3B2)
        addScalar(0x1F3B3)
        addScalar(0x1F3B4)
        addScalar(0x1F3B5)
        addScalar(0x1F3B6)
        addScalar(0x1F3B7)
        addScalar(0x1F3B8)
        addScalar(0x1F3B9)
        addScalar(0x1F3BA)
        addScalar(0x1F3BB)
        addScalar(0x1F3BC)
        addScalar(0x1F3BD)
        addScalar(0x1F3BE)
        addScalar(0x1F3BF)
        addScalar(0x1F3C0)
        addScalar(0x1F3C1)
        addScalar(0x1F3C2)
        addScalar(0x1F3C3)
        addScalar(0x1F3C4)
        addScalar(0x1F3C5)
        addScalar(0x1F3C6)
        addScalar(0x1F3C7)
        addScalar(0x1F3C8)
        addScalar(0x1F3C9)
        addScalar(0x1F3CA)
        addScalar(0x1F3CB)
        addScalar(0x1F3CC)
        addScalar(0x1F3CD)
        addScalar(0x1F3CE)
        addScalar(0x1F3CF)
        addScalar(0x1F3D0)
        addScalar(0x1F3D1)
        addScalar(0x1F3D2)
        addScalar(0x1F3D3)
        addScalar(0x1F3D4)
        addScalar(0x1F3D5)
        addScalar(0x1F3D6)
        addScalar(0x1F3D7)
        addScalar(0x1F3D8)
        addScalar(0x1F3D9)
        addScalar(0x1F3DA)
        addScalar(0x1F3DB)
        addScalar(0x1F3DC)
        addScalar(0x1F3DD)
        addScalar(0x1F3DE)
        addScalar(0x1F3DF)
        addScalar(0x1F3E0)
        addScalar(0x1F3E1)
        addScalar(0x1F3E2)
        addScalar(0x1F3E3)
        addScalar(0x1F3E4)
        addScalar(0x1F3E5)
        addScalar(0x1F3E6)
        addScalar(0x1F3E7)
        addScalar(0x1F3E8)
        addScalar(0x1F3E9)
        addScalar(0x1F3EA)
        addScalar(0x1F3EB)
        addScalar(0x1F3EC)
        addScalar(0x1F3ED)
        addScalar(0x1F3EE)
        addScalar(0x1F3EF)
        addScalar(0x1F3F0)
        addScalar(0x1F3F3)
        addScalar(0x1F3F4)
        addScalar(0x1F3F5)
        addScalar(0x1F3F7)
        addScalar(0x1F3F8)
        addScalar(0x1F3F9)
        addScalar(0x1F3FA)
        addScalar(0x1F3FB)
        addScalar(0x1F3FC)
        addScalar(0x1F3FD)
        addScalar(0x1F3FE)
        addScalar(0x1F3FF)
        addScalar(0x1F400)
        addScalar(0x1F401)
        addScalar(0x1F402)
        addScalar(0x1F403)
        addScalar(0x1F404)
        addScalar(0x1F405)
        addScalar(0x1F406)
        addScalar(0x1F407)
        addScalar(0x1F408)
        addScalar(0x1F409)
        addScalar(0x1F40A)
        addScalar(0x1F40B)
        addScalar(0x1F40C)
        addScalar(0x1F40D)
        addScalar(0x1F40E)
        addScalar(0x1F40F)
        addScalar(0x1F410)
        addScalar(0x1F411)
        addScalar(0x1F412)
        addScalar(0x1F413)
        addScalar(0x1F414)
        addScalar(0x1F415)
        addScalar(0x1F416)
        addScalar(0x1F417)
        addScalar(0x1F418)
        addScalar(0x1F419)
        addScalar(0x1F41A)
        addScalar(0x1F41B)
        addScalar(0x1F41C)
        addScalar(0x1F41D)
        addScalar(0x1F41E)
        addScalar(0x1F41F)
        addScalar(0x1F420)
        addScalar(0x1F421)
        addScalar(0x1F422)
        addScalar(0x1F423)
        addScalar(0x1F424)
        addScalar(0x1F425)
        addScalar(0x1F426)
        addScalar(0x1F427)
        addScalar(0x1F428)
        addScalar(0x1F429)
        addScalar(0x1F42A)
        addScalar(0x1F42B)
        addScalar(0x1F42C)
        addScalar(0x1F42D)
        addScalar(0x1F42E)
        addScalar(0x1F42F)
        addScalar(0x1F430)
        addScalar(0x1F431)
        addScalar(0x1F432)
        addScalar(0x1F433)
        addScalar(0x1F434)
        addScalar(0x1F435)
        addScalar(0x1F436)
        addScalar(0x1F437)
        addScalar(0x1F438)
        addScalar(0x1F439)
        addScalar(0x1F43A)
        addScalar(0x1F43B)
        addScalar(0x1F43C)
        addScalar(0x1F43D)
        addScalar(0x1F43E)
        addScalar(0x1F43F)
        addScalar(0x1F440)
        addScalar(0x1F441)
        addScalar(0x1F442)
        addScalar(0x1F443)
        addScalar(0x1F444)
        addScalar(0x1F445)
        addScalar(0x1F446)
        addScalar(0x1F447)
        addScalar(0x1F448)
        addScalar(0x1F449)
        addScalar(0x1F44A)
        addScalar(0x1F44B)
        addScalar(0x1F44C)
        addScalar(0x1F44D)
        addScalar(0x1F44E)
        addScalar(0x1F44F)
        addScalar(0x1F450)
        addScalar(0x1F451)
        addScalar(0x1F452)
        addScalar(0x1F453)
        addScalar(0x1F454)
        addScalar(0x1F455)
        addScalar(0x1F456)
        addScalar(0x1F457)
        addScalar(0x1F458)
        addScalar(0x1F459)
        addScalar(0x1F45A)
        addScalar(0x1F45B)
        addScalar(0x1F45C)
        addScalar(0x1F45D)
        addScalar(0x1F45E)
        addScalar(0x1F45F)
        addScalar(0x1F460)
        addScalar(0x1F461)
        addScalar(0x1F462)
        addScalar(0x1F463)
        addScalar(0x1F464)
        addScalar(0x1F465)
        addScalar(0x1F466)
        addScalar(0x1F467)
        addScalar(0x1F468)
        addScalar(0x1F469)
        addScalar(0x1F46A)
        addScalar(0x1F46B)
        addScalar(0x1F46C)
        addScalar(0x1F46D)
        addScalar(0x1F46E)
        addScalar(0x1F46F)
        addScalar(0x1F470)
        addScalar(0x1F471)
        addScalar(0x1F472)
        addScalar(0x1F473)
        addScalar(0x1F474)
        addScalar(0x1F475)
        addScalar(0x1F476)
        addScalar(0x1F477)
        addScalar(0x1F478)
        addScalar(0x1F479)
        addScalar(0x1F47A)
        addScalar(0x1F47B)
        addScalar(0x1F47C)
        addScalar(0x1F47D)
        addScalar(0x1F47E)
        addScalar(0x1F47F)
        addScalar(0x1F480)
        addScalar(0x1F481)
        addScalar(0x1F482)
        addScalar(0x1F483)
        addScalar(0x1F484)
        addScalar(0x1F485)
        addScalar(0x1F486)
        addScalar(0x1F487)
        addScalar(0x1F488)
        addScalar(0x1F489)
        addScalar(0x1F48A)
        addScalar(0x1F48B)
        addScalar(0x1F48C)
        addScalar(0x1F48D)
        addScalar(0x1F48E)
        addScalar(0x1F48F)
        addScalar(0x1F490)
        addScalar(0x1F491)
        addScalar(0x1F492)
        addScalar(0x1F493)
        addScalar(0x1F494)
        addScalar(0x1F495)
        addScalar(0x1F496)
        addScalar(0x1F497)
        addScalar(0x1F498)
        addScalar(0x1F499)
        addScalar(0x1F49A)
        addScalar(0x1F49B)
        addScalar(0x1F49C)
        addScalar(0x1F49D)
        addScalar(0x1F49E)
        addScalar(0x1F49F)
        addScalar(0x1F4A0)
        addScalar(0x1F4A1)
        addScalar(0x1F4A2)
        addScalar(0x1F4A3)
        addScalar(0x1F4A4)
        addScalar(0x1F4A5)
        addScalar(0x1F4A6)
        addScalar(0x1F4A7)
        addScalar(0x1F4A8)
        addScalar(0x1F4A9)
        addScalar(0x1F4AA)
        addScalar(0x1F4AB)
        addScalar(0x1F4AC)
        addScalar(0x1F4AD)
        addScalar(0x1F4AE)
        addScalar(0x1F4AF)
        addScalar(0x1F4B0)
        addScalar(0x1F4B1)
        addScalar(0x1F4B2)
        addScalar(0x1F4B3)
        addScalar(0x1F4B4)
        addScalar(0x1F4B5)
        addScalar(0x1F4B6)
        addScalar(0x1F4B7)
        addScalar(0x1F4B8)
        addScalar(0x1F4B9)
        addScalar(0x1F4BA)
        addScalar(0x1F4BB)
        addScalar(0x1F4BC)
        addScalar(0x1F4BD)
        addScalar(0x1F4BE)
        addScalar(0x1F4BF)
        addScalar(0x1F4C0)
        addScalar(0x1F4C1)
        addScalar(0x1F4C2)
        addScalar(0x1F4C3)
        addScalar(0x1F4C4)
        addScalar(0x1F4C5)
        addScalar(0x1F4C6)
        addScalar(0x1F4C7)
        addScalar(0x1F4C8)
        addScalar(0x1F4C9)
        addScalar(0x1F4CA)
        addScalar(0x1F4CB)
        addScalar(0x1F4CC)
        addScalar(0x1F4CD)
        addScalar(0x1F4CE)
        addScalar(0x1F4CF)
        addScalar(0x1F4D0)
        addScalar(0x1F4D1)
        addScalar(0x1F4D2)
        addScalar(0x1F4D3)
        addScalar(0x1F4D4)
        addScalar(0x1F4D5)
        addScalar(0x1F4D6)
        addScalar(0x1F4D7)
        addScalar(0x1F4D8)
        addScalar(0x1F4D9)
        addScalar(0x1F4DA)
        addScalar(0x1F4DB)
        addScalar(0x1F4DC)
        addScalar(0x1F4DD)
        addScalar(0x1F4DE)
        addScalar(0x1F4DF)
        addScalar(0x1F4E0)
        addScalar(0x1F4E1)
        addScalar(0x1F4E2)
        addScalar(0x1F4E3)
        addScalar(0x1F4E4)
        addScalar(0x1F4E5)
        addScalar(0x1F4E6)
        addScalar(0x1F4E7)
        addScalar(0x1F4E8)
        addScalar(0x1F4E9)
        addScalar(0x1F4EA)
        addScalar(0x1F4EB)
        addScalar(0x1F4EC)
        addScalar(0x1F4ED)
        addScalar(0x1F4EE)
        addScalar(0x1F4EF)
        addScalar(0x1F4F0)
        addScalar(0x1F4F1)
        addScalar(0x1F4F2)
        addScalar(0x1F4F3)
        addScalar(0x1F4F4)
        addScalar(0x1F4F5)
        addScalar(0x1F4F6)
        addScalar(0x1F4F7)
        addScalar(0x1F4F8)
        addScalar(0x1F4F9)
        addScalar(0x1F4FA)
        addScalar(0x1F4FB)
        addScalar(0x1F4FC)
        addScalar(0x1F4FD)
        addScalar(0x1F4FF)
        addScalar(0x1F500)
        addScalar(0x1F501)
        addScalar(0x1F502)
        addScalar(0x1F503)
        addScalar(0x1F504)
        addScalar(0x1F505)
        addScalar(0x1F506)
        addScalar(0x1F507)
        addScalar(0x1F508)
        addScalar(0x1F509)
        addScalar(0x1F50A)
        addScalar(0x1F50B)
        addScalar(0x1F50C)
        addScalar(0x1F50D)
        addScalar(0x1F50E)
        addScalar(0x1F50F)
        addScalar(0x1F510)
        addScalar(0x1F511)
        addScalar(0x1F512)
        addScalar(0x1F513)
        addScalar(0x1F514)
        addScalar(0x1F515)
        addScalar(0x1F516)
        addScalar(0x1F517)
        addScalar(0x1F518)
        addScalar(0x1F519)
        addScalar(0x1F51A)
        addScalar(0x1F51B)
        addScalar(0x1F51C)
        addScalar(0x1F51D)
        addScalar(0x1F51E)
        addScalar(0x1F51F)
        addScalar(0x1F520)
        addScalar(0x1F521)
        addScalar(0x1F522)
        addScalar(0x1F523)
        addScalar(0x1F524)
        addScalar(0x1F525)
        addScalar(0x1F526)
        addScalar(0x1F527)
        addScalar(0x1F528)
        addScalar(0x1F529)
        addScalar(0x1F52A)
        addScalar(0x1F52B)
        addScalar(0x1F52C)
        addScalar(0x1F52D)
        addScalar(0x1F52E)
        addScalar(0x1F52F)
        addScalar(0x1F530)
        addScalar(0x1F531)
        addScalar(0x1F532)
        addScalar(0x1F533)
        addScalar(0x1F534)
        addScalar(0x1F535)
        addScalar(0x1F536)
        addScalar(0x1F537)
        addScalar(0x1F538)
        addScalar(0x1F539)
        addScalar(0x1F53A)
        addScalar(0x1F53B)
        addScalar(0x1F53C)
        addScalar(0x1F53D)
        addScalar(0x1F549)
        addScalar(0x1F54A)
        addScalar(0x1F54B)
        addScalar(0x1F54C)
        addScalar(0x1F54D)
        addScalar(0x1F54E)
        addScalar(0x1F550)
        addScalar(0x1F551)
        addScalar(0x1F552)
        addScalar(0x1F553)
        addScalar(0x1F554)
        addScalar(0x1F555)
        addScalar(0x1F556)
        addScalar(0x1F557)
        addScalar(0x1F558)
        addScalar(0x1F559)
        addScalar(0x1F55A)
        addScalar(0x1F55B)
        addScalar(0x1F55C)
        addScalar(0x1F55D)
        addScalar(0x1F55E)
        addScalar(0x1F55F)
        addScalar(0x1F560)
        addScalar(0x1F561)
        addScalar(0x1F562)
        addScalar(0x1F563)
        addScalar(0x1F564)
        addScalar(0x1F565)
        addScalar(0x1F566)
        addScalar(0x1F567)
        addScalar(0x1F56F)
        addScalar(0x1F570)
        addScalar(0x1F573)
        addScalar(0x1F574)
        addScalar(0x1F575)
        addScalar(0x1F576)
        addScalar(0x1F577)
        addScalar(0x1F578)
        addScalar(0x1F579)
        addScalar(0x1F57A)
        addScalar(0x1F587)
        addScalar(0x1F58A)
        addScalar(0x1F58B)
        addScalar(0x1F58C)
        addScalar(0x1F58D)
        addScalar(0x1F590)
        addScalar(0x1F595)
        addScalar(0x1F596)
        addScalar(0x1F5A4)
        addScalar(0x1F5A5)
        addScalar(0x1F5A8)
        addScalar(0x1F5B1)
        addScalar(0x1F5B2)
        addScalar(0x1F5BC)
        addScalar(0x1F5C2)
        addScalar(0x1F5C3)
        addScalar(0x1F5C4)
        addScalar(0x1F5D1)
        addScalar(0x1F5D2)
        addScalar(0x1F5D3)
        addScalar(0x1F5DC)
        addScalar(0x1F5DD)
        addScalar(0x1F5DE)
        addScalar(0x1F5E1)
        addScalar(0x1F5E3)
        addScalar(0x1F5E8)
        addScalar(0x1F5EF)
        addScalar(0x1F5F3)
        addScalar(0x1F5FA)
        addScalar(0x1F5FB)
        addScalar(0x1F5FC)
        addScalar(0x1F5FD)
        addScalar(0x1F5FE)
        addScalar(0x1F5FF)
        addScalar(0x1F600)
        addScalar(0x1F601)
        addScalar(0x1F602)
        addScalar(0x1F603)
        addScalar(0x1F604)
        addScalar(0x1F605)
        addScalar(0x1F606)
        addScalar(0x1F607)
        addScalar(0x1F608)
        addScalar(0x1F609)
        addScalar(0x1F60A)
        addScalar(0x1F60B)
        addScalar(0x1F60C)
        addScalar(0x1F60D)
        addScalar(0x1F60E)
        addScalar(0x1F60F)
        addScalar(0x1F610)
        addScalar(0x1F611)
        addScalar(0x1F612)
        addScalar(0x1F613)
        addScalar(0x1F614)
        addScalar(0x1F615)
        addScalar(0x1F616)
        addScalar(0x1F617)
        addScalar(0x1F618)
        addScalar(0x1F619)
        addScalar(0x1F61A)
        addScalar(0x1F61B)
        addScalar(0x1F61C)
        addScalar(0x1F61D)
        addScalar(0x1F61E)
        addScalar(0x1F61F)
        addScalar(0x1F620)
        addScalar(0x1F621)
        addScalar(0x1F622)
        addScalar(0x1F623)
        addScalar(0x1F624)
        addScalar(0x1F625)
        addScalar(0x1F626)
        addScalar(0x1F627)
        addScalar(0x1F628)
        addScalar(0x1F629)
        addScalar(0x1F62A)
        addScalar(0x1F62B)
        addScalar(0x1F62C)
        addScalar(0x1F62D)
        addScalar(0x1F62E)
        addScalar(0x1F62F)
        addScalar(0x1F630)
        addScalar(0x1F631)
        addScalar(0x1F632)
        addScalar(0x1F633)
        addScalar(0x1F634)
        addScalar(0x1F635)
        addScalar(0x1F636)
        addScalar(0x1F637)
        addScalar(0x1F638)
        addScalar(0x1F639)
        addScalar(0x1F63A)
        addScalar(0x1F63B)
        addScalar(0x1F63C)
        addScalar(0x1F63D)
        addScalar(0x1F63E)
        addScalar(0x1F63F)
        addScalar(0x1F640)
        addScalar(0x1F641)
        addScalar(0x1F642)
        addScalar(0x1F643)
        addScalar(0x1F644)
        addScalar(0x1F645)
        addScalar(0x1F646)
        addScalar(0x1F647)
        addScalar(0x1F648)
        addScalar(0x1F649)
        addScalar(0x1F64A)
        addScalar(0x1F64B)
        addScalar(0x1F64C)
        addScalar(0x1F64D)
        addScalar(0x1F64E)
        addScalar(0x1F64F)
        addScalar(0x1F680)
        addScalar(0x1F681)
        addScalar(0x1F682)
        addScalar(0x1F683)
        addScalar(0x1F684)
        addScalar(0x1F685)
        addScalar(0x1F686)
        addScalar(0x1F687)
        addScalar(0x1F688)
        addScalar(0x1F689)
        addScalar(0x1F68A)
        addScalar(0x1F68B)
        addScalar(0x1F68C)
        addScalar(0x1F68D)
        addScalar(0x1F68E)
        addScalar(0x1F68F)
        addScalar(0x1F690)
        addScalar(0x1F691)
        addScalar(0x1F692)
        addScalar(0x1F693)
        addScalar(0x1F694)
        addScalar(0x1F695)
        addScalar(0x1F696)
        addScalar(0x1F697)
        addScalar(0x1F698)
        addScalar(0x1F699)
        addScalar(0x1F69A)
        addScalar(0x1F69B)
        addScalar(0x1F69C)
        addScalar(0x1F69D)
        addScalar(0x1F69E)
        addScalar(0x1F69F)
        addScalar(0x1F6A0)
        addScalar(0x1F6A1)
        addScalar(0x1F6A2)
        addScalar(0x1F6A3)
        addScalar(0x1F6A4)
        addScalar(0x1F6A5)
        addScalar(0x1F6A6)
        addScalar(0x1F6A7)
        addScalar(0x1F6A8)
        addScalar(0x1F6A9)
        addScalar(0x1F6AA)
        addScalar(0x1F6AB)
        addScalar(0x1F6AC)
        addScalar(0x1F6AD)
        addScalar(0x1F6AE)
        addScalar(0x1F6AF)
        addScalar(0x1F6B0)
        addScalar(0x1F6B1)
        addScalar(0x1F6B2)
        addScalar(0x1F6B3)
        addScalar(0x1F6B4)
        addScalar(0x1F6B5)
        addScalar(0x1F6B6)
        addScalar(0x1F6B7)
        addScalar(0x1F6B8)
        addScalar(0x1F6B9)
        addScalar(0x1F6BA)
        addScalar(0x1F6BB)
        addScalar(0x1F6BC)
        addScalar(0x1F6BD)
        addScalar(0x1F6BE)
        addScalar(0x1F6BF)
        addScalar(0x1F6C0)
        addScalar(0x1F6C1)
        addScalar(0x1F6C2)
        addScalar(0x1F6C3)
        addScalar(0x1F6C4)
        addScalar(0x1F6C5)
        addScalar(0x1F6CB)
        addScalar(0x1F6CC)
        addScalar(0x1F6CD)
        addScalar(0x1F6CE)
        addScalar(0x1F6CF)
        addScalar(0x1F6D0)
        addScalar(0x1F6D1)
        addScalar(0x1F6D2)
        addScalar(0x1F6E0)
        addScalar(0x1F6E1)
        addScalar(0x1F6E2)
        addScalar(0x1F6E3)
        addScalar(0x1F6E4)
        addScalar(0x1F6E5)
        addScalar(0x1F6E9)
        addScalar(0x1F6EB)
        addScalar(0x1F6EC)
        addScalar(0x1F6F0)
        addScalar(0x1F6F3)
        addScalar(0x1F6F4)
        addScalar(0x1F6F5)
        addScalar(0x1F6F6)
        addScalar(0x1F910)
        addScalar(0x1F911)
        addScalar(0x1F912)
        addScalar(0x1F913)
        addScalar(0x1F914)
        addScalar(0x1F915)
        addScalar(0x1F916)
        addScalar(0x1F917)
        addScalar(0x1F918)
        addScalar(0x1F919)
        addScalar(0x1F91A)
        addScalar(0x1F91B)
        addScalar(0x1F91C)
        addScalar(0x1F91D)
        addScalar(0x1F91E)
        addScalar(0x1F920)
        addScalar(0x1F921)
        addScalar(0x1F922)
        addScalar(0x1F923)
        addScalar(0x1F924)
        addScalar(0x1F925)
        addScalar(0x1F926)
        addScalar(0x1F927)
        addScalar(0x1F930)
        addScalar(0x1F933)
        addScalar(0x1F934)
        addScalar(0x1F935)
        addScalar(0x1F936)
        addScalar(0x1F937)
        addScalar(0x1F938)
        addScalar(0x1F939)
        addScalar(0x1F93A)
        addScalar(0x1F93C)
        addScalar(0x1F93D)
        addScalar(0x1F93E)
        addScalar(0x1F940)
        addScalar(0x1F941)
        addScalar(0x1F942)
        addScalar(0x1F943)
        addScalar(0x1F944)
        addScalar(0x1F945)
        addScalar(0x1F947)
        addScalar(0x1F948)
        addScalar(0x1F949)
        addScalar(0x1F94A)
        addScalar(0x1F94B)
        addScalar(0x1F950)
        addScalar(0x1F951)
        addScalar(0x1F952)
        addScalar(0x1F953)
        addScalar(0x1F954)
        addScalar(0x1F955)
        addScalar(0x1F956)
        addScalar(0x1F957)
        addScalar(0x1F958)
        addScalar(0x1F959)
        addScalar(0x1F95A)
        addScalar(0x1F95B)
        addScalar(0x1F95C)
        addScalar(0x1F95D)
        addScalar(0x1F95E)
        addScalar(0x1F980)
        addScalar(0x1F981)
        addScalar(0x1F982)
        addScalar(0x1F983)
        addScalar(0x1F984)
        addScalar(0x1F985)
        addScalar(0x1F986)
        addScalar(0x1F987)
        addScalar(0x1F988)
        addScalar(0x1F989)
        addScalar(0x1F98A)
        addScalar(0x1F98B)
        addScalar(0x1F98C)
        addScalar(0x1F98D)
        addScalar(0x1F98E)
        addScalar(0x1F98F)
        addScalar(0x1F990)
        addScalar(0x1F991)
        addScalar(0x1F9C0)
        addScalar(0x200D)
        addScalar(0x203C)
        addScalar(0x2049)
        addScalar(0x20E3)
        addScalar(0x2122)
        addScalar(0x2139)
        addScalar(0x2194)
        addScalar(0x2195)
        addScalar(0x2196)
        addScalar(0x2197)
        addScalar(0x2198)
        addScalar(0x2199)
        addScalar(0x21A9)
        addScalar(0x21AA)
        addScalar(0x231A)
        addScalar(0x231B)
        addScalar(0x2328)
        addScalar(0x23CF)
        addScalar(0x23E9)
        addScalar(0x23EA)
        addScalar(0x23EB)
        addScalar(0x23EC)
        addScalar(0x23ED)
        addScalar(0x23EE)
        addScalar(0x23EF)
        addScalar(0x23F0)
        addScalar(0x23F1)
        addScalar(0x23F2)
        addScalar(0x23F3)
        addScalar(0x23F8)
        addScalar(0x23F9)
        addScalar(0x23FA)
        addScalar(0x24C2)
        addScalar(0x25AA)
        addScalar(0x25AB)
        addScalar(0x25B6)
        addScalar(0x25C0)
        addScalar(0x25FB)
        addScalar(0x25FC)
        addScalar(0x25FD)
        addScalar(0x25FE)
        addScalar(0x2600)
        addScalar(0x2601)
        addScalar(0x2602)
        addScalar(0x2603)
        addScalar(0x2604)
        addScalar(0x260E)
        addScalar(0x2611)
        addScalar(0x2614)
        addScalar(0x2615)
        addScalar(0x2618)
        addScalar(0x261D)
        addScalar(0x2620)
        addScalar(0x2622)
        addScalar(0x2623)
        addScalar(0x2626)
        addScalar(0x262A)
        addScalar(0x262E)
        addScalar(0x262F)
        addScalar(0x2638)
        addScalar(0x2639)
        addScalar(0x263A)
        addScalar(0x2648)
        addScalar(0x2649)
        addScalar(0x264A)
        addScalar(0x264B)
        addScalar(0x264C)
        addScalar(0x264D)
        addScalar(0x264E)
        addScalar(0x264F)
        addScalar(0x2650)
        addScalar(0x2651)
        addScalar(0x2652)
        addScalar(0x2653)
        addScalar(0x2660)
        addScalar(0x2663)
        addScalar(0x2665)
        addScalar(0x2666)
        addScalar(0x2668)
        addScalar(0x267B)
        addScalar(0x267F)
        addScalar(0x2692)
        addScalar(0x2693)
        addScalar(0x2694)
        addScalar(0x2696)
        addScalar(0x2697)
        addScalar(0x2699)
        addScalar(0x269B)
        addScalar(0x269C)
        addScalar(0x26A0)
        addScalar(0x26A1)
        addScalar(0x26AA)
        addScalar(0x26AB)
        addScalar(0x26B0)
        addScalar(0x26B1)
        addScalar(0x26BD)
        addScalar(0x26BE)
        addScalar(0x26C4)
        addScalar(0x26C5)
        addScalar(0x26C8)
        addScalar(0x26CE)
        addScalar(0x26CF)
        addScalar(0x26D1)
        addScalar(0x26D3)
        addScalar(0x26D4)
        addScalar(0x26E9)
        addScalar(0x26EA)
        addScalar(0x26F0)
        addScalar(0x26F1)
        addScalar(0x26F2)
        addScalar(0x26F3)
        addScalar(0x26F4)
        addScalar(0x26F5)
        addScalar(0x26F7)
        addScalar(0x26F8)
        addScalar(0x26F9)
        addScalar(0x26FA)
        addScalar(0x26FD)
        addScalar(0x2702)
        addScalar(0x2705)
        addScalar(0x2708)
        addScalar(0x2709)
        addScalar(0x270A)
        addScalar(0x270B)
        addScalar(0x270C)
        addScalar(0x270D)
        addScalar(0x270F)
        addScalar(0x2712)
        addScalar(0x2714)
        addScalar(0x2716)
        addScalar(0x271D)
        addScalar(0x2721)
        addScalar(0x2728)
        addScalar(0x2733)
        addScalar(0x2734)
        addScalar(0x2744)
        addScalar(0x2747)
        addScalar(0x274C)
        addScalar(0x274E)
        addScalar(0x2753)
        addScalar(0x2754)
        addScalar(0x2755)
        addScalar(0x2757)
        addScalar(0x2763)
        addScalar(0x2764)
        addScalar(0x2795)
        addScalar(0x2796)
        addScalar(0x2797)
        addScalar(0x27A1)
        addScalar(0x27B0)
        addScalar(0x27BF)
        addScalar(0x2934)
        addScalar(0x2935)
        addScalar(0x2B05)
        addScalar(0x2B06)
        addScalar(0x2B07)
        addScalar(0x2B1B)
        addScalar(0x2B1C)
        addScalar(0x2B50)
        addScalar(0x2B55)
        addScalar(0x3030)
        addScalar(0x303D)
        addScalar(0x3297)
        addScalar(0x3299)
        addScalar(0xFE0F)

        return scalars
    }()
}