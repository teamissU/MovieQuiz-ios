import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func didRecieveAlert(alert: UIAlertController)
}
