//
//  NetworkError.swift
//  Journal
//
//  Created by Dominique Strachan on 2/28/23.
//

import Foundation

enum NetworkError: Error {
    
    case baseURLError
    case builtURLError
    case invalidData(String)
    case noData
    case statusCode
    case unableToDecode
    
    var errorDescription: String? {
        switch self {
        case .baseURLError:
            return "Unable to reach the server due to invalid URL"
        case .builtURLError:
           return "Unable to reach the server due to invalid built URL"
        case .invalidData:
            return "Data error from API call"
        case .noData:
            return "The server responded with no data"
        case .statusCode:
           return "Status code error"
        case .unableToDecode:
            return "Unable to decode data"
        }
        
    }
    
}

