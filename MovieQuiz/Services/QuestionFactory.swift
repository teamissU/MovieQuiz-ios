import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    weak var delegate: QuestionFactoryDelegate?
    private let questions: [QuizQuestion] = [
        QuizQuestion(
            image: "The Godfather",
            text : "Рейтинг этого фильма больше чем 6?",
            correctAnswer : true),
        QuizQuestion(
                    image: "The Dark Knight",
                    text: "Рейтинг этого фильма больше чем 6?",
                    correctAnswer: true),
        QuizQuestion(
                    image: "Kill Bill",
                    text: "Рейтинг этого фильма больше чем 6?",
                    correctAnswer: true),
        QuizQuestion(
                    image: "The Avengers",
                    text: "Рейтинг этого фильма больше чем 6?",
                    correctAnswer: true),
        QuizQuestion(
                    image: "Deadpool",
                    text: "Рейтинг этого фильма больше чем 6?",
                    correctAnswer: true),
        QuizQuestion(
                    image: "The Green Knight",
                    text: "Рейтинг этого фильма больше чем 6?",
                    correctAnswer: true),
        QuizQuestion(
                    image: "Old",
                    text: "Рейтинг этого фильма больше чем 6?",
                    correctAnswer: false),
        QuizQuestion(
                    image: "The Ice Age Adventures of Buck Wild",
                    text: "Рейтинг этого фильма больше чем 6?",
                    correctAnswer: false),
        QuizQuestion(
                    image: "Tesla",
                    text: "Рейтинг этого фильма больше чем 6?",
                    correctAnswer: false),
        QuizQuestion(
                    image: "Vivarium",
                    text: "Рейтинг этого фильма больше чем 6?",
                    correctAnswer: false)
    ]
    private lazy var questionsCopy = questions
    func getQuestionsCount () -> Int {
        return questions.count
    }
    func requestNextQuestion() {
        guard let index = (0..<questionsCopy.count).randomElement() else {  // 2
             return
        }
        
        let question = questionsCopy[safe: index]
        questionsCopy.remove(at: index)
        delegate?.didRecieveNextQuestion(question: question)
    }
    func restart () {
        questionsCopy = questions
    }
}
