import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    private lazy var activityIndicator = UIActivityIndicatorView ()
    private var alert: AlertPresenterProtocol?
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
    
    func show(quiz step: QuizStepModel) {
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
    
    func setAnimating(start: Bool) {
        start ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
    
    func setBorderWidth(border: Bool) {
        if border == true {
            imageView.layer.borderWidth = 0
        } else {
            imageView.layer.borderWidth = 8
        }
    }
    
    func setBorderColor(color: Bool) {
        imageView.layer.borderColor = color ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    func highlightImageBorder(isCorrectAnswer: Bool) {
        
    }
    
    func showLoadingIndicator() {
        
    }
    
    func hideLoadingIndicator() {
        
    }
    
    func showNetworkError(message: String) {
        
    }
    
    func show(alertModel: AlertModel) {
        alert?.requestAlertPresenter(alertModel)
    }
}


extension MovieQuizViewController: AlertPresenterDelegate {
    func didRecieveAlert(alert: UIAlertController) {
        present(alert, animated: true)
    }
}


