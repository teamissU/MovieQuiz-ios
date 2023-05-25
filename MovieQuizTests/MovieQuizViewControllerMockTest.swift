//
//  MovieQuizViewControllerMockTest.swift
//  MovieQuizTests
//
//  Created by Tim on 25.05.2023.
//

import XCTest
@testable import MovieQuiz


final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let sut = MovieQuizPresenter()
        let etalonVM = QuizStepModel(
            image: UIImage(),
            question: "Question Text",
            questionNumber: "1/10")
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
         XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
        XCTAssert(viewModel == etalonVM)
    }
}
