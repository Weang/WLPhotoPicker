//
//  MD5.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/5.
//

import CommonCrypto

extension String {
    /* ################################################################## */
    var md5: String {
        guard let str = cString(using: String.Encoding.utf8) else {
            return self
        }
        let strLen = CUnsignedInt(lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5(str, strLen, result)
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        result.deallocate()
        return hash as String
    }
    
}
