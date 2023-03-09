import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?) {
        <#code#>
    }
    
    
    
    
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    private lazy var questionsAmount: Int = questionFactory.getQuestionsCount()
    private lazy var questionFactory: QuestionFactory = {
        let questionFactory = QuestionFactory(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?)
        return questionFactory
    }()
    private var currentQuestion: QuizQuestion? //текущий вопрос, который видит пользователь.
    private var alertModel: AlertPresenterProtocol?
    private var statisticService: StatisticService?
    // MARK: LifeStyle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticServiceImplementation()
        
        showLoadingIndicator()
        questionFactory.loadData()
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(textResult: message, title: "Ошибка", buttonText: "Попробовать еще раз")
        
        self.currentQuestionIndex = 0
        self.correctAnswers = 0
        
        self.questionFactory.requestNextQuestion()
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
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    private func show() {
        statisticService?.store(correct: correctAnswers, total: questionsAmount)
        guard let gamesCount = statisticService?.gamesCount else {return}
        guard let bestGame = statisticService?.bestGame else {return}
        guard let totalAccuracy = statisticService?.totalAccuracy else {return}
        var model = AlertModel(textResult: "Ваш результат: \(correctAnswers)/\(questionsAmount)\nКоличество сыгранных квизов: \(gamesCount)\nРекорд: \(bestGame.correct)/\(bestGame.total) \(bestGame.date.dateTimeString) \nСредняя точность: \(String(format: "%.2f", totalAccuracy))%", title: "Этот раунд окончен!", buttonText: "Сыграть еще раз")
        model.delegate = self
        model.alertAction = {_ in
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            //self.questionFactory.restart()
            self.questionFactory.requestNextQuestion()
        }
        model.requestAlertPresenter()
    }
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    private func showNextQuestionOrResults() {
        imageView.layer.borderWidth = 0
        
        if currentQuestionIndex == questionsAmount - 1 {
            show()
        } else {
            currentQuestionIndex += 1
            questionFactory.requestNextQuestion()
        }
    }
    func didRecieveAlert(alert: UIAlertController) {
        present(alert, animated: true)
    }
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory.requestNextQuestion()
        
    }
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    //private extension MovieQuizViewController {
    //    enum FileManagerError: Error {
    //        case fileDoesntExist
    //        case parsingFailure
    //    }
    //}
}


