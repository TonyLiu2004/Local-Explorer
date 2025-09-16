//
//  LocationManager.swift
//  Local Explorer
//
//  Created by Tony Liu on 9/15/25.
//

import CoreLocation

class LocationManager: NSObject, ObservableObject{
    private let manager = CLLocationManager()
    @Published var userLocation: CLLocation?
    static let shared = LocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
    }
    
    func requestLocation() {
        manager.requestWhenInUseAuthorization()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        switch status {
        case .notDetermined:
            print("DEBUG: Not Determined")
        case .restricted:
            print("Debug: Restricted")
        case .denied:
            print("Debug: Denied")
        case .authorizedAlways:
            print("Debug: Authorized always")
        case .authorizedWhenInUse:
            print("Debug: Authroized when in use")
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        guard let location = locations.last else {return}
        self.userLocation = location
    }
}
