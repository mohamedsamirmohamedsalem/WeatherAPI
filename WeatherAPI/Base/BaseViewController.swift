//
//  BaseViewController.swift
//  WeatherAPI
//
//  Created by Mohamed Samir on 19/03/2024.
//


import Foundation
import UIKit

class BaseViewController: UIViewController {

    func showLoader() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
            
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.style = UIActivityIndicatorView.Style.medium
            loadingIndicator.startAnimating()
            
            alert.view.addSubview(loadingIndicator)
            self.present(alert, animated: true, completion: nil)        }
    }
    
    func hideLoader() {
        dismiss(animated: false, completion: nil)
    }
    
    func showAlertView(title: String, message: String,
                       firstButtonTitle: String = "OK",
                       secondButtonTitle: String = "Cancel",
                       firstButtonHandler: @escaping ()-> Void = {},
                       secondButtonHandler: @escaping ()-> Void = {}) {
        // Instantiating UIAlertController
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: firstButtonTitle, style: .default) { _ in
            firstButtonHandler()
        }
        let cancelAction = UIAlertAction(title: secondButtonTitle, style: .cancel) { _ in
            secondButtonHandler()
        }
        
        // Adding action buttons to the alert controller
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        // Presenting alert controller
        self.present(alertController, animated: true, completion:nil)
    }
    
    func dismissAlertView(){
        dismiss(animated: false, completion: nil)
    }
}

