//
//  MovieError.swift
//  MovieQuiz
//
//  Created by Tim on 06.04.2023.
//

import Foundation

enum MovieError: Error {
    case net(desc: String)
    case nextQuestion(desc: String)
    
    var description: String {
        switch self {
        case .net(let desc): return desc
        case .nextQuestion(let desc): return desc
        }
    }
}
