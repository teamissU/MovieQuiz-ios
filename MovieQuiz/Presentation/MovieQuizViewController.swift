import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    
    private let questionsAmount: Int = 10
    private lazy var questionFactory: QuestionFactory = {
        let questionFactory = QuestionFactory()
        questionFactory.delegate = self
        return questionFactory
    }()
    private var currentQuestion: QuizQuestion? //текущий вопрос, который видит пользователь.
    private var alertModel: AlertPresenterProtocol?
    // MARK: LifeStyle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionFactory.delegate = self
        
        questionFactory.requestNextQuestion()
        
        }
    
    // MARK: - QuestionFactoryDelegate
    
    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
                return
            }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    private func show(quiz result: AlertModel) {
            imageView.layer.cornerRadius = 20
            let alert = UIAlertController(
                title: result.title,
                message: result.textResult,
                preferredStyle: .alert)
            let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
            }
        questionFactory.requestNextQuestion()
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 6
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            show(quiz: AlertModel)
            imageView.layer.borderWidth = 0
        } else {
            currentQuestionIndex += 1
            imageView.layer.borderWidth = -1
            questionFactory.requestNextQuestion()
        }
    }
    func didReceiveAlert(alert: AlertModel) {
            let alert = UIAlertController(
                title: alert.title,
                message: alert.textResult,
                preferredStyle: .alert)
            
        }
}



