//
//  WeatherService.swift
//  WeatherAPI
//
//  Created by Mohamed Samir on 18/03/2024.
//


import Foundation

protocol AppRequest {
    var urlRequest: URLRequest { get }
}


struct WeatherRequest: AppRequest {
    var url: URL
    var urlRequest: URLRequest {
        return URLRequest(url: url)
    }
}



protocol Service {
    func get(request: AppRequest, completion: @escaping (Result<Data, Error>) -> Void)
}

/// A concrete implementation of Service class responsible for getting a Network resource
final class NetworkService: Service {
    
    func get(request: AppRequest, completion: @escaping (Result<Data, Error>) -> Void) {
        URLSession.shared.dataTask(with: request.urlRequest) { (data, response, error) in
            if let response = response as? HTTPURLResponse {
                print("statusCode: \(response.statusCode)")
                switch (response.statusCode){
                case 400, 401, 404, 429, 500..<999:
                    completion(.failure(self.throwNetworkError(response.statusCode)))
                default:
                    completion(.failure(NetworkError.httpRequestFailed))
                }
            }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.httpRequestFailed))
                return
            }
            completion(.success(data))
        }.resume()
    }
    
    private func throwNetworkError(_ statusCode: Int) -> NetworkError {
        
        switch statusCode {
        case 400:
            return NetworkError.APIRequestUrlIsInvalid
        case 401:
            return NetworkError.APIKeyNotprovided
        case 403:
            return NetworkError.APIKeyHasExceededCallsPerMonthQuota
        default:
            return NetworkError.httpRequestFailed
        }
    }
}


enum NetworkError: Error {
    case APIRequestUrlIsInvalid
    case APIKeyNotprovided
    case APIKeyHasExceededCallsPerMonthQuota
    case httpRequestFailed
}

