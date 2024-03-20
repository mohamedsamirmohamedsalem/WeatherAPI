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
    
    lazy var futureWeatherLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .black
        label.text = "Next 7 days Weather forecast"
        return label
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
                viewModel.fetchWeatherData(latitude: location?.coordinate.latitude, longitude: location?.coordinate.longitude)
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
                self.setImage(from: weatherData.current.condition.icon,for: tempStatusImage)
                buildGridView(rows: 5, columns: 2, rootView: view)
                
            }.store(in: &cancellables)
    }
    
    private func setImage(from url: String,for webImage: UIImageView) {
        guard let imageURL = URL(string: "https:\(url)") else { return }
        DispatchQueue.global().async {
            guard let imageData = try? Data(contentsOf: imageURL) else { return }
            let image = UIImage(data: imageData)
            DispatchQueue.main.async {
                webImage.image = image
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
        view.addSubview(futureWeatherLabel)
        
        
        
        NSLayoutConstraint.activate([
            cityLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            cityLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            tempLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            tempLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            tempStatusImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 130),
            tempStatusImage.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            futureWeatherLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 200),
            futureWeatherLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
    }
    
    private func buildGridView(rows: Int, columns: Int, rootView: UIView){
        
        // Init StackView
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 5
        
        var index = 0
        for _ in 0 ..< viewModel.forecastList.value.count  {
            let horizontalSv = UIStackView()
            horizontalSv.axis = .horizontal
            horizontalSv.alignment = .center
            horizontalSv.distribution = .equalSpacing
            horizontalSv.spacing = 5
            
            index += 1
            let dateLabel: UILabel = {
                let label = UILabel()
                label.translatesAutoresizingMaskIntoConstraints = false
                label.font = UIFont.systemFont(ofSize: 14)
                label.textColor = .black
                label.text = viewModel.forecastList.value[index - 1].date
                return label
            }()
            
            let tempLabel: UILabel = {
                let label = UILabel()
                label.translatesAutoresizingMaskIntoConstraints = false
                label.font = UIFont.systemFont(ofSize: 14)
                label.textColor = .black
                label.text = "\(viewModel.forecastList.value[index - 1].day.avgtempC)"
                return label
            }()
            
            let tempStatusImage: UIImageView = {
                let tempStatusImage = UIImageView()
                tempStatusImage.translatesAutoresizingMaskIntoConstraints = false
                tempStatusImage.frame = CGRectMake(0, 0, 20, 20)
                
                
                return tempStatusImage
            }()
            
            horizontalSv.addArrangedSubview(dateLabel)
            horizontalSv.addArrangedSubview(tempLabel)
            horizontalSv.addArrangedSubview(tempStatusImage)
            self.setImage(from: viewModel.forecastList.value[index - 1].day.condition.icon,for: tempStatusImage)
            
            
            stackView.addArrangedSubview(horizontalSv)
        }
        
        rootView.addSubview(stackView)
        
        // add constraints
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 230),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
    }
}


