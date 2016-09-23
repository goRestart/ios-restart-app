//
//  BumperFlags.swift
//  Letgo
//
//  GENERATED - DO NOT MODIFY - use flags_generator instead.
// 
//  Copyright © 2016 Letgo. All rights reserved.
//

import Foundation
import bumper

extension Bumper  {
    static func initialize() {
        Bumper.initialize([XcodeRealTest.self, PacoTest.self, JuanTest.self, ABoolTest.self, ABoolTest2.self, ABoolTest3.self])
    } 

    var xcodeRealTest: XcodeRealTest {
        guard let value = Bumper.valueForKey(XcodeRealTest.key) else { return .First }
        return XcodeRealTest(rawValue: value) ?? .First 
    }

    var pacoTest: PacoTest {
        guard let value = Bumper.valueForKey(PacoTest.key) else { return .First }
        return PacoTest(rawValue: value) ?? .First 
    }

    var juanTest: JuanTest {
        guard let value = Bumper.valueForKey(JuanTest.key) else { return .First }
        return JuanTest(rawValue: value) ?? .First 
    }

    var aBoolTest: Bool {
        guard let value = Bumper.valueForKey(ABoolTest.key) else { return true }
        return ABoolTest(rawValue: value)?.asBool ?? true
    }

    var aBoolTest2: Bool {
        guard let value = Bumper.valueForKey(ABoolTest2.key) else { return true }
        return ABoolTest2(rawValue: value)?.asBool ?? true
    }

    var aBoolTest3: Bool {
        guard let value = Bumper.valueForKey(ABoolTest3.key) else { return false }
        return ABoolTest3(rawValue: value)?.asBool ?? false
    } 
}


enum XcodeRealTest: String, BumperFlag  {
    case First, Second, Third
    static var defaultValue: String { return XcodeRealTest.First.rawValue }
    static var enumValues: [XcodeRealTest] { return [.First, .Second, .Third]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Ajan Gramenawer" } 
    static func fromPosition(position: Int) -> XcodeRealTest {
        switch position { 
            case 0: return .First
            case 1: return .Second
            case 2: return .Third
            default: return .First
        }
    }
}

enum PacoTest: String, BumperFlag  {
    case First, Second, Third
    static var defaultValue: String { return PacoTest.First.rawValue }
    static var enumValues: [PacoTest] { return [.First, .Second, .Third]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Hola que tal paco " } 
    static func fromPosition(position: Int) -> PacoTest {
        switch position { 
            case 0: return .First
            case 1: return .Second
            case 2: return .Third
            default: return .First
        }
    }
}

enum JuanTest: String, BumperFlag  {
    case First, Second, Third
    static var defaultValue: String { return JuanTest.First.rawValue }
    static var enumValues: [JuanTest] { return [.First, .Second, .Third]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Hola que tal juan" } 
    static func fromPosition(position: Int) -> JuanTest {
        switch position { 
            case 0: return .First
            case 1: return .Second
            case 2: return .Third
            default: return .First
        }
    }
}

enum ABoolTest: String, BumperFlag  {
    case Yes, No
    static var defaultValue: String { return ABoolTest.Yes.rawValue }
    static var enumValues: [ABoolTest] { return [.Yes, .No]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Hola que tal juan modo bool" } 
    var asBool: Bool { return self == .Yes }
}

enum ABoolTest2: String, BumperFlag  {
    case Yes, No
    static var defaultValue: String { return ABoolTest2.Yes.rawValue }
    static var enumValues: [ABoolTest2] { return [.Yes, .No]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Hola que tal juan modo bool" } 
    var asBool: Bool { return self == .Yes }
}

enum ABoolTest3: String, BumperFlag  {
    case No, Yes
    static var defaultValue: String { return ABoolTest3.No.rawValue }
    static var enumValues: [ABoolTest3] { return [.No, .Yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Hola que tal juan modo bool" } 
    var asBool: Bool { return self == .Yes }
}

