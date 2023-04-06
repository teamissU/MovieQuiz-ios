import UIKit

final class MovieQuizViewController: UIViewController {
    
    
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    private lazy var activityIndicator = UIActivityIndicatorView ()
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    private lazy var questionsAmount: Int = questionFactory.getQuestionsCount()
    private lazy var questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
    private var currentQuestion: QuizQuestion?
    private var alert: AlertPresenterProtocol?
    private var statisticService: StatisticService?
    // MARK: LifeStyle
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        guard let gamesCount = statisticService?.gamesCount else { return }
        guard let bestGame = statisticService?.bestGame else { return }
        guard let totalAccuracy = statisticService?.totalAccuracy else { return }
        let textResult = "Ваш результат: \(correctAnswers)/\(questionsAmount)\nКоличество сыгранных квизов: \(gamesCount)\nРекорд: \(bestGame.correct)/\(bestGame.total) \(bestGame.date.dateTimeString) \nСредняя точность: \(String(format: "%.2f", totalAccuracy))%"
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
        self.currentQuestionIndex = 0
        self.correctAnswers = 0
        self.questionFactory.requestNextQuestion()
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
}
extension MovieQuizViewController: QuestionFactoryDelegate {
    
    func didReceiveNextQuestion(question: Result<QuizQuestion, MovieError>) {
        switch question {
        case .success(let quizQuestion):
            currentQuestion = quizQuestion
            let viewModel = convert(model: quizQuestion)
            DispatchQueue.main.async { [weak self] in
                self?.show(quiz: viewModel)
                self?.activityIndicator.stopAnimating()
            }
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


