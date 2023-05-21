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
    private var statisticService: StatisticService?
    private lazy var questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)

    
    init() {
        statisticService = StatisticServiceImplementation()
    }
    
    func loadData() {
        questionFactory.loadData()
    }
    func yesNoButtonClicked(givenAnswer: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
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
        viewController?.imageView.layer.borderWidth = 0
        if self.isLastQuestion() {
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
            guard let gamesCount = statisticService?.gamesCount else { return }
            guard let bestGame = statisticService?.bestGame else { return }
            guard let totalAccuracy = statisticService?.totalAccuracy else { return }
            let textResult = "Ваш результат: \(correctAnswers)/\(questionsAmount)\nКоличество сыгранных квизов: \(gamesCount)\nРекорд: \(bestGame.correct)/\(bestGame.total) \(bestGame.date.dateTimeString) \nСредняя точность: \(String(format: "%.2f", totalAccuracy))%"
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: textResult,
                buttonText: "Сыграть ещё раз")
            viewController?.show(quiz: viewModel)
        } else {
            self.switchToNextQuestion()
            questionFactory.requestNextQuestion()
        }
    }
    
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        viewController?.imageView.layer.borderWidth = 8
        viewController?.imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    guard let self = self else { return }
                    self.questionFactory = self.questionFactory
                    self.showNextQuestionOrResults()
                }
    }
    
    func requestNextQuestion () {
        viewController?.activityIndicator.startAnimating()
        resetQuestionIndex()
        correctAnswers = 0
        questionFactory.requestNextQuestion()
    }
    
}

extension MovieQuizPresenter: QuestionFactoryDelegate {
    
    func didReceiveNextQuestion(question: Result<QuizQuestion, MovieError>) {
        switch question {
        case .success(let quizQuestion):
            didRecieveNextQuestion(question: quizQuestion)
        case .failure(let error):
            didFailToLoadData(with: error)
        }
    }
    
    func didLoadDataFromServer() {
        questionFactory.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: MovieError) {
        viewController?.activityIndicator.stopAnimating()
        let model = AlertModel(
            textResult: error.description,
            title: "Ошибка",
            buttonText: "Попробовать еще раз", alertAction: { [weak self] in
                guard let self = self else { return }
                self.requestNextQuestion()
            })
        viewController?.alert?.requestAlertPresenter(model)
    }
}
