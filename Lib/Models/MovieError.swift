//
//  MovieError.swift
//  MovieQuiz
//
//  Created by Tim on 06.04.2023.
//

import Foundation

enum MovieError: Error {
    case net(desc: String)
    case noSelf
    case badMovieIndex
    case badUrl
    
    var description: String {
        switch self {
        case .net(let desc): return desc
        case .noSelf: return "no self"
        case .badMovieIndex: return "bad movie index"
        case .badUrl: return "bad URL"
            
        }
    }
}
