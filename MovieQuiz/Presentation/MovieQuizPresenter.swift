//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Tim on 16.05.2023.
//

import UIKit

final class MovieQuizPresenter {
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    weak var viewController: MovieQuizViewController?
    var currentQuestion: QuizQuestion?
    var correctAnswers: Int = 0
        
    func yesNoButtonClicked(givenAnswer: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func isLastQuestion() -> Bool {
            currentQuestionIndex == questionsAmount - 1
    }
        
    func resetQuestionIndex() {
            currentQuestionIndex = 0
    }
        
    func switchToNextQuestion() {
            currentQuestionIndex += 1
    }
    
    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
                return
        }
            
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
            self?.viewController?.activityIndicator.stopAnimating()

        }
    }
    
    func showNextQuestionOrResults() {
            if self.isLastQuestion() {
                let text = "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
                
                let viewModel = QuizResultsViewModel(
                    title: "Этот раунд окончен!",
                    text: text,
                    buttonText: "Сыграть ещё раз")
                viewController?.show(quiz: viewModel)
            } else {
                self.switchToNextQuestion()
                questionFactory?.requestNextQuestion()
            }
        }
}
