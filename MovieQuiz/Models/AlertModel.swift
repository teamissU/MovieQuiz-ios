import Foundation
import UIKit

struct AlertModel: AlertPresenterProtocol {
    func requestAlertPresenter(_ alert: AlertModel) {
        let alertController = UIAlertController(
                title: alert.title,
                message: alert.textResult,
                preferredStyle: .alert)
            
        let action = UIAlertAction(title: alert.buttonText, style: .default, handler: { _ in
        })
        alertController.addAction(action)
        _ = AlertModel()
        
    }
    
    
    static var countCurrentAnswer: Int = 0
    let textResult: String = "Ваш результат \(countCurrentAnswer) из 10!"
    let title: String = "Этот раун окончен!"
    let buttonText: String = "Сыграть еще раз"
    
}


