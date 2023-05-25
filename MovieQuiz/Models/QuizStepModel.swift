import Foundation
import UIKit

struct QuizStepModel {
  let image: UIImage
  let question: String
  let questionNumber: String
}
extension QuizStepModel: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.image == rhs.image &&
        lhs.question == rhs.question &&
        lhs.questionNumber == rhs.questionNumber
    }
}
