//
//  FileError.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/5.
//

import UIKit

public enum FileError: Error {

    case underlying(Error)

}

extension FileError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .underlying(let error):
            return error.localizedDescription
        }
    }
}
