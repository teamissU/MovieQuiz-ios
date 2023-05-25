//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Tim on 25.05.2023.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepModel)
    func show(quiz result: QuizResultsViewModel)
    func setBorderWidth(border: Bool)
    func highlightImageBorder(isCorrectAnswer: Bool)
    func setAnimating(start: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func show(alertModel: AlertModel)
    func showNetworkError(message: String)
    func setBorderColor(color: Bool)
}
