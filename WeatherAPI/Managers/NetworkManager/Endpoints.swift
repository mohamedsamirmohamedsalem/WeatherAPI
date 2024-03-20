//
//  Endpoints.swift
//  WeatherAPI
//
//  Created by Mohamed Samir on 19/03/2024.
//

class Endpoints {
    
    private static let apiKey = "db46c658909947a5902203242241803"
    static let baseURL = "https://api.weatherapi.com/v1"
    
    static func currentAndFutureWeatherURL(latitude: Double, longitude: Double) -> String {
        return "\(baseURL)/forecast.json?key=\(apiKey)&q=\(latitude),\(longitude)&days=7&aqi=no&alerts=no"
    }
    
}


