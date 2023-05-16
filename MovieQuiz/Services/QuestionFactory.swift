import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    
    private let moviesLoader: MoviesLoading
    private var movies: [MostPopularMovie] = []
        private var delegate: QuestionFactoryDelegate?

        init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
            self.moviesLoader = moviesLoader
            self.delegate = delegate
        }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    if mostPopularMovies.items.isEmpty {
                        let errorText = mostPopularMovies.errorMessage.isEmpty ? "Нет фильмов" : mostPopularMovies.errorMessage
                        self.delegate?.didFailToLoadData(with: .net(desc: errorText))
                    } else {
                        self.movies = Array(mostPopularMovies.items[...9])
                        self.delegate?.didLoadDataFromServer()
                    }
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: .net(desc: error.localizedDescription))
                }
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async {
                    self?.delegate?.didReceiveNextQuestion(question: .failure(.nextQuestion(desc: "no self")))
                }
                return
            }
            let index = (0..<self.movies.count).randomElement() ?? 0
            guard let movie = self.movies[safe: index] else { return }
                       
           do {
               let imageData = try Data(contentsOf: movie.imageURL)
               let rating = Float(movie.rating) ?? 0
               
               let text = "Рейтинг этого фильма больше чем 7?"
               let correctAnswer = rating > 7
               
               let question = QuizQuestion(image: imageData,
                                            text: text,
                                            correctAnswer: correctAnswer)
               
               DispatchQueue.main.async {
                   self.delegate?.didReceiveNextQuestion(question: .success(question))
               }
            } catch {
                DispatchQueue.main.async {
                    self.delegate?.didReceiveNextQuestion(question: .failure(.nextQuestion(desc: error.localizedDescription)))
                }
            }
        }
    }
    
    func getQuestionsCount () -> Int {
        return movies.count
    }
}

//private let questions: [QuizQuestion] = [
//    QuizQuestion(
//        image: "The Godfather",
//        text : "Рейтинг этого фильма больше чем 6?",
//        correctAnswer : true),
//    QuizQuestion(
//                image: "The Dark Knight",
//                text: "Рейтинг этого фильма больше чем 6?",
//                correctAnswer: true),
//    QuizQuestion(
//                image: "Kill Bill",
//                text: "Рейтинг этого фильма больше чем 6?",
//                correctAnswer: true),
//    QuizQuestion(
//                image: "The Avengers",
//                text: "Рейтинг этого фильма больше чем 6?",
//                correctAnswer: true),
//    QuizQuestion(
//                image: "Deadpool",
//                text: "Рейтинг этого фильма больше чем 6?",
//                correctAnswer: true),
//    QuizQuestion(
//                image: "The Green Knight",
//                text: "Рейтинг этого фильма больше чем 6?",
//                correctAnswer: true),
//    QuizQuestion(
//                image: "Old",
//                text: "Рейтинг этого фильма больше чем 6?",
//                correctAnswer: false),
//    QuizQuestion(
//                image: "The Ice Age Adventures of Buck Wild",
//                text: "Рейтинг этого фильма больше чем 6?",
//                correctAnswer: false),
//    QuizQuestion(
//                image: "Tesla",
//                text: "Рейтинг этого фильма больше чем 6?",
//                correctAnswer: false),
//    QuizQuestion(
//                image: "Vivarium",
//                text: "Рейтинг этого фильма больше чем 6?",
//                correctAnswer: false)
//]
