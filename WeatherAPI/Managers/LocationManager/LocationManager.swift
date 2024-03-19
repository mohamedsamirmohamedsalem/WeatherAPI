//
//  LocationManager.swift
//  WeatherAPI
//
//  Created by Mohamed Samir on 18/03/2024.
//


import Foundation
import CoreLocation
import Combine

//MARK: LocationManager
// Responsible for managing Location Services.

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    static var shared = LocationManager()
    var locationManager = CLLocationManager()
    var currentLocation = PassthroughSubject<CLLocation?,Never>()
    var latitude: Double?
    var longitude: Double?
    
    private override init() {
        super.init()
        self.setupLocationRequest()
    }
    
    private func setupLocationRequest() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation.send(locations.first)
        latitude = locations.first?.coordinate.latitude
        longitude = locations.first?.coordinate.longitude
        locationManager.stopUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
       debugPrint(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .authorizedAlways,.authorizedWhenInUse:
            print("Good to go and use location")
            
        case .denied:
            locationManager.requestWhenInUseAuthorization()
            print("DENIED to go and use location")
            
        case .restricted:
            print("DENIED to go and use location")
            
        case .notDetermined:
            print("DENIED to go and use location")
            
        default:
            print("Unable to read location :\(status)")
        }
    }
}

