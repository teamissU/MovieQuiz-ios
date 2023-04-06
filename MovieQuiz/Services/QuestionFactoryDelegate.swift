import Foundation

protocol QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: Result<QuizQuestion, MovieError>)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: MovieError)
}
