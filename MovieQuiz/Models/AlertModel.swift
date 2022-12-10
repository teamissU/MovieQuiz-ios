import Foundation

struct AlertModel {
    var countCurrentAnswer: Int = 0
    let textResult: String = "Ваш результат \(countCurrentAnswer) из 10!"
    let title: String = "Этот раун окончен!"
    let buttonText: String = "Сыграть еще раз"
}
