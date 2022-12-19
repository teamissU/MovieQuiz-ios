import Foundation
import UIKit

struct AlertPresenter: AlertPresenterProtocol {
    func requestAlertPresenter(_ alert: AlertModel) {
        let alertController = UIAlertController(
                title: alert.title,
                message: alert.textResult,
                preferredStyle: .alert)
            
        let action = UIAlertAction(title: alert.buttonText, style: .default, handler: { _ in
        })
        alertController.addAction(action)
        let model = AlertModel()
        delegate?.didRecieveAlert(alert: model)
    }
    
    
    private weak var delegate: AlertPresenterDelegate?
    
    init(delegate: AlertPresenterDelegate? = nil) {
        self.delegate = delegate
    }
    
}
