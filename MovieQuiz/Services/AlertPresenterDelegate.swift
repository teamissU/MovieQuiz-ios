import Foundation

protocol AlertPresenterDelegate: AnyObject {
    func didRecieveAlert(alert: AlertModel)
}
