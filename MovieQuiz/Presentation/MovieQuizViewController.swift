import UIKit

final class MovieQuizViewController: UIViewController {
    
    
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    lazy var activityIndicator = UIActivityIndicatorView ()
    private lazy var questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
    private var currentQuestion: QuizQuestion?
    private var alert: AlertPresenterProtocol?
    private var statisticService: StatisticService?
    private let presenter = MovieQuizPresenter()
    // MARK: LifeStyle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewController = self
        setupView()
        imageView.layer.cornerRadius = 20
        statisticService = StatisticServiceImplementation()
        alert = AlertPresenter(delegate: self)
        activityIndicator.hidesWhenStopped = true
        questionFactory.loadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator.startAnimating()
    }
    private func setupView() {
            imageView.addSubview(activityIndicator)
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                activityIndicator.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
            ])
        }
    
    // MARK: - QuestionFactoryDelegate
    
    
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.yesNoButtonClicked(givenAnswer: false)
    }
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.yesNoButtonClicked(givenAnswer: true)
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    private func show() {
        statisticService?.store(correct: correctAnswers, total: presenter.questionsAmount)
        guard let gamesCount = statisticService?.gamesCount else { return }
        guard let bestGame = statisticService?.bestGame else { return }
        guard let totalAccuracy = statisticService?.totalAccuracy else { return }
        let textResult = "Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)\nКоличество сыгранных квизов: \(gamesCount)\nРекорд: \(bestGame.correct)/\(bestGame.total) \(bestGame.date.dateTimeString) \nСредняя точность: \(String(format: "%.2f", totalAccuracy))%"
        let model = AlertModel(
            textResult: textResult,
            title: "Этот раунд окончен!",
            buttonText: "Сыграть еще раз", alertAction: { [weak self] in
                guard let self = self else { return }
                self.requestNextQuestion()
            })
        alert?.requestAlertPresenter(model)
    }
    private func requestNextQuestion () {
        activityIndicator.startAnimating()
        self.presenter.resetQuestionIndex()
        self.correctAnswers = 0
        self.questionFactory.requestNextQuestion()
    }
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    guard let self = self else { return }
                    self.presenter.correctAnswers = self.correctAnswers
                    self.presenter.questionFactory = self.questionFactory
                    self.presenter.showNextQuestionOrResults()
                }
    }
    private func showNextQuestionOrResults() {
        imageView.layer.borderWidth = 0
        
        if presenter.isLastQuestion() {
            show()
        } else {
            presenter.switchToNextQuestion()
            questionFactory.requestNextQuestion()
        }
    }
}
extension MovieQuizViewController: QuestionFactoryDelegate {
    
    func didReceiveNextQuestion(question: Result<QuizQuestion, MovieError>) {
        switch question {
        case .success(let quizQuestion):
            presenter.didRecieveNextQuestion(question: quizQuestion)
        case .failure(let error):
            didFailToLoadData(with: error)
        }
    }
    
    func didLoadDataFromServer() {
        questionFactory.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: MovieError) {
        activityIndicator.stopAnimating()
        let model = AlertModel(
            textResult: error.description,
            title: "Ошибка",
            buttonText: "Попробовать еще раз", alertAction: { [weak self] in
                guard let self = self else { return }
                self.requestNextQuestion()
            })
        alert?.requestAlertPresenter(model)
    }
}

extension MovieQuizViewController: AlertPresenterDelegate {
    func didRecieveAlert(alert: UIAlertController) {
        present(alert, animated: true)
    }
}


