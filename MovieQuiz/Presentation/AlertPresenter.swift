import Foundation
import UIKit

struct AlertPresenter: AlertPresenterProtocol {
    
    private var delegate: AlertPresenterDelegate?
    
    init(delegate: AlertPresenterDelegate? = nil) {
        self.delegate = delegate
    }
    
    private func requestAlertPresenter(result: AlertModel) {
        let alert = UIAlertController(
                title: result.title,
                message: result.textResult,
                preferredStyle: .alert)
            
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            guard let self = self else { return }
            }
    }
}
