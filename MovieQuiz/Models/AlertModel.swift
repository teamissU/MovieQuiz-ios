
import UIKit

protocol AlertPresenterProtocol {
    func requestAlertPresenter()
}

struct AlertModel: AlertPresenterProtocol {
    var delegate: AlertPresenterDelegate?
    var alertAction: ((UIAlertAction) -> ())?

    let textResult: String
    let title: String
    let buttonText: String
    func requestAlertPresenter() {
        let alertController = UIAlertController(
                title: title,
                message: textResult,
                preferredStyle: .alert)
            
        let action = UIAlertAction(title: buttonText, style: .default, handler: alertAction)
        alertController.addAction(action)
        delegate?.didRecieveAlert(alert: alertController)
    }
    
}


