import Foundation
import UIKit

struct AlertPresenter: AlertPresenterProtocol {
    func requestAlertPresenter(_ alert: AlertModel) {
        let alertController = UIAlertController(
                title: alert.title,
                message: alert.textResult,
                preferredStyle: .alert)
        alertController.view.accessibilityIdentifier = "Game results"
        let action = UIAlertAction(title: alert.buttonText, style: .default, handler: { _ in
            alert.alertAction?()
        })
        alertController.addAction(action)
        delegate?.didRecieveAlert(alert: alertController)
    }


    private weak var delegate: AlertPresenterDelegate?

    init(delegate: AlertPresenterDelegate? = nil) {
        self.delegate = delegate
    }

}
