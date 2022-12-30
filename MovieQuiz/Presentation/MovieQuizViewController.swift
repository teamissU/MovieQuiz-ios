import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    
    

    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    private let model = AlertModel()
    private let questionsAmount: Int = 10
    private lazy var questionFactory: QuestionFactory = {
        let questionFactory = QuestionFactory()
        questionFactory.delegate = self
        return questionFactory
    }()
    private var currentQuestion: QuizQuestion? //текущий вопрос, который видит пользователь.
    private var alertModel: AlertPresenterProtocol?
    private var statisticService: StatisticService?
    // MARK: LifeStyle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionFactory.delegate = self
        
        questionFactory.requestNextQuestion()
        statisticService = StatisticServiceImplementation()
        //print(NSHomeDirectory())
        //UserDefaults.standard.set(true, forKey: "viewDidLoad")
        //print(Bundle.main.bundlePath)
        var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "text.swift"
        documentsURL.appendPathComponent(fileName)
        if !FileManager.default.fileExists(atPath: documentsURL.path) {
            let hello = "Hello world!"
            let data = hello.data(using: .utf8)
            FileManager.default.createFile(atPath: documentsURL.path, contents: data)
        }
        print(documentsURL)
        enum FileManagerError: Error {
            case fileDoesntExist
            case parsingFailure
        }
        func string(from documentsURL: URL) throws -> String {
            if !FileManager.default.fileExists(atPath: documentsURL.path) {
                throw FileManagerError.fileDoesntExist
            }
            return try String(contentsOf: documentsURL)
        }
        let inceptionPath = documentsURL.appendingPathComponent("inception.json")
        let jsonString = try? String(contentsOf: inceptionPath)
        struct Actor: Codable {
            let id: String
            let image: String
            let name: String
            let asCharacter: String
        }
        struct Movie: Codable {
          let id: String
          let rank: String
          let title: String
          let fullTitle: String
          let year: String
          let image: String
          let crew: String
          let imDbRating: String
          let imDbRatingCount: String
        }
        struct Top: Decodable {
            let items: [Movie]
        }
        func jsonObject(with data: Data, options opt: JSONSerialization.ReadingOptions = []) throws -> Any {
            _ = try? JSONDecoder().decode(Top.self, from: data)
            let data = jsonString!.data(using: .utf8)!
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

                  guard let json = json,
                        let id = json["id"] as? String,
                        let rank = json["rank"] as? String,
                        let title = json["title"] as? String,
                        let fullTitle = json["fullTitle"] as? String,
                        let crew = json["crew"] as? String,
                        let imDbRating = json["imDbRating"] as? String,
                        let imDbRatingCount = json["imDbRatingCount"] as? String,
                        let year = json["year"] as? String,
                        let image = json["image"] as? String,
                        //let releaseDate = json["releaseDate"] as? String,
                        //let runtimeMins = json["runtimeMins"] as? String,
                        //let directors = json["directors"] as? String,
                        let actorList = json["actorList"] as? [Any] else {
                      throw FileManagerError.parsingFailure
                }

                var actors: [Actor] = []

                for actor in actorList {
                    guard let actor = actor as? [String: Any],
                            let id = actor["id"] as? String,
                            let image = actor["image"] as? String,
                            let name = actor["name"] as? String,
                            let asCharacter = actor["asCharacter"] as? String else {
                        throw FileManagerError.parsingFailure
                    }
                    let mainActor = Actor(id: id,
                                            image: image,
                                            name: name,
                                            asCharacter: asCharacter)
                    actors.append(mainActor)
                }
                _ = Movie(id: id,
                                   rank: rank,
                                   title: title,
                                   fullTitle: fullTitle,
                                   year: year,
                                   image: image,
                                   crew: crew,
                                   imDbRating: imDbRating,
                                   imDbRatingCount: imDbRatingCount)
            } catch {
                print("Failed to parse: \(String(describing: jsonString))")
            }
            throw FileManagerError.parsingFailure
            
        }
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
    private func show(quiz result: QuizResultsViewModel) {
            imageView.layer.cornerRadius = 20
            let alert = UIAlertController(
                title: result.title,
                message: result.text,
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
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 0

            if currentQuestionIndex == questionsAmount - 1 {

                statisticService?.store(correct: correctAnswers, total: questionsAmount)
                guard let gamesCount = statisticService?.gamesCount else {return}
                guard let bestGame = statisticService?.bestGame else {return}
                guard let totalAccuracy = statisticService?.totalAccuracy else {return}

                let viewModel = QuizResultsViewModel(
                    title: "Этот раунд окончен!",
                    text: "Ваш результат: \(correctAnswers)/\(questionsAmount)\nКоличество сыгранных квизов: \(gamesCount)\nРекорд: \(bestGame.correct)/\(bestGame.total) \(bestGame.date.dateTimeString) \nСредняя точность: \(String(format: "%.2f", totalAccuracy))%",
                    buttonText: "Сыграть еще раз")
                show(quiz: viewModel)
            } else {
                currentQuestionIndex += 1
                questionFactory.requestNextQuestion()
            }
    }
    func didRecieveAlert(alert: AlertModel) {
        _ = UIAlertController(
            title: alert.title,
            message: alert.textResult,
            preferredStyle: .alert)
    }
    
}



