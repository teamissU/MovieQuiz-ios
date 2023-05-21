import UIKit

final class MovieQuizViewController: UIViewController {
    
    
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    lazy var activityIndicator = UIActivityIndicatorView ()
    var alert: AlertPresenterProtocol?
    private let presenter = MovieQuizPresenter()
    // MARK: LifeStyle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewController = self
        setupView()
        imageView.layer.cornerRadius = 20
        alert = AlertPresenter(delegate: self)
        activityIndicator.hidesWhenStopped = true
        presenter.loadData()
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
        presenter.yesNoButtonClicked(givenAnswer: false)
    }
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesNoButtonClicked(givenAnswer: true)
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    func show(quiz: QuizResultsViewModel) {
        
        let model = AlertModel(
            textResult: quiz.text,
            title: quiz.title,
            buttonText: quiz.buttonText, alertAction: { [weak self] in
                guard let self = self else { return }
                self.presenter.requestNextQuestion()
            })
        alert?.requestAlertPresenter(model)
    }
    
}


extension MovieQuizViewController: AlertPresenterDelegate {
    func didRecieveAlert(alert: UIAlertController) {
        present(alert, animated: true)
    }
}


