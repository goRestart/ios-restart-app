//
//  CryptoUtils.swift
//  LetGo
//
//  Created by Nacho on 25/2/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import Foundation

extension Int {
    func hexString() -> String {
        return NSString(format:"%02x", self)
    }
}

extension NSData {
    func hexString() -> String {
        var string = String()
        for i in UnsafeBufferPointer<UInt8>(start: UnsafeMutablePointer<UInt8>(bytes), count: length) {
            string += Int(i).hexString()
        }
        return string
    }
    
    func md5() -> NSData {
        let result = NSMutableData(length: Int(CC_MD5_DIGEST_LENGTH))!
        CC_MD5(bytes, CC_LONG(length), UnsafeMutablePointer<UInt8>(result.mutableBytes))
        return NSData(data: result)
    }
    
    func sha1() -> NSData {
        let result = NSMutableData(length: Int(CC_SHA1_DIGEST_LENGTH))!
        CC_SHA1(bytes, CC_LONG(length), UnsafeMutablePointer<UInt8>(result.mutableBytes))
        return NSData(data: result)
    }
}

extension String {
    func md5() -> String {
        return (self as NSString).dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!.md5().hexString()
    }
    
    func sha1() -> String {
        return (self as NSString).dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!.sha1().hexString()
    }
}