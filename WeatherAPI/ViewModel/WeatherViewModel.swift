//
//  WeatherViewModel.swift
//  Weathered
//
//  Created by Mohamed Samir on 18/03/2024.
//

import Foundation
import Combine

class WeatherViewModel {
    
    let networkService: Service
    var weatherData = PassthroughSubject<WeatherData,Never>()
    var showLoader = PassthroughSubject<Bool, Never>()
    var errorMessage = PassthroughSubject<String,Never>()
    
    
    init(networkService: Service) {
        self.networkService = networkService
    }
    
    func fetchCurrentWeatherData(latitude: Double?, longitude: Double?)  {
        guard let latitude, let longitude else { return }
        
        guard let  url = URL(string: Endpoints.currentForecastWeatherURL(latitude: latitude, longitude: longitude)) else {return}
        
        self.showLoader.send(true)
        
        let request = WeatherRequest(url: url)
        networkService.get(request: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                self.errorMessage.send(error.localizedDescription)
            case .success(let data):
                do {
                    let weatherData = try? JSONDecoder().decode(WeatherData.self, from: data)
                    self.weatherData.send(weatherData!)
                    self.showLoader.send(false)
                }catch {
                    self.showLoader.send(false)
                    errorMessage.send(error.localizedDescription)
                }
            }
        }
    }
}
