//
//  ViewController.swift
//  WeatherAPI
//
//  Created by Mohamed Samir on 18/03/2024.
//

import UIKit
import CoreLocation
import Combine


class ViewController: BaseViewController {
   
    //MARK: Declare instance variables here ///////////////////////////////////////////////////////
    var viewModel = WeatherViewModel(networkService: NetworkService())
    var cancellables = Set<AnyCancellable>()
    
    //MARK: UI View instance variables here ///////////////////////////////////////////////////////
    
    lazy var mainView: UIView = {
        let view = UIView(frame: self.view.frame)
        view.backgroundColor = .white
        return view
    }()
    
    lazy var cityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 25)
        label.textColor = .black
        return label
    }()
    
    lazy var tempLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 50)
        label.textColor = .black
        return label
    }()
    
    lazy var tempStatusImage: UIImageView = {
        let tempStatusImage = UIImageView()
        tempStatusImage.translatesAutoresizingMaskIntoConstraints = false
        return tempStatusImage
    }()
    
    
    
    //MARK: View Lifecycle ///////////////////////////////////////////////////////
    override func loadView() {
        super.loadView()
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getCurrentLocation()
        bindViewModel()
    }
    
    //MARK: methods ///////////////////////////////////////////////////////
    
    private func getCurrentLocation(){
        LocationManager.shared.currentLocation
            .sink { [weak self] location in
                guard let self else { return }
                viewModel.fetchCurrentWeatherData(latitude: location?.coordinate.latitude, longitude: location?.coordinate.longitude)
            }.store(in: &cancellables)
    }
    
    private func bindViewModel(){
        
        viewModel.showLoader
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard let self = self else {return}
                isLoading ? self.showLoader() : self.hideLoader()
            }.store(in: &cancellables)
        
        viewModel.errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                guard let self = self else {return}
                self.showAlertView(title: "Error", message: message)
            }.store(in: &cancellables)
        
        viewModel.weatherData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] weatherData in
                guard let self else { return }
                self.tempLabel.text = "\(weatherData.current.tempC)"
                self.cityLabel.text = weatherData.location.region
                self.setImage(from: weatherData.current.condition.icon.rawValue)
            }.store(in: &cancellables)
    }
    
    private func setImage(from url: String) {
        guard let imageURL = URL(string: "https:\(url)") else { return }
        DispatchQueue.global().async {
            guard let imageData = try? Data(contentsOf: imageURL) else { return }
            let image = UIImage(data: imageData)
            DispatchQueue.main.async {
                self.tempStatusImage.image = image
            }
        }
    }
    
}

// MARK: Setup UI ///////////////////////////////////////////////////////
extension ViewController {
    
    private func setupUI(){
        view.addSubview(cityLabel)
        view.addSubview(tempLabel)
        view.addSubview(tempStatusImage)
        
        
        NSLayoutConstraint.activate([
            cityLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 70),
            cityLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            tempLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            tempLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            tempStatusImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 150),
            tempStatusImage.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
    }
}


