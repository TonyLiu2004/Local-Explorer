//
//  LocationManager.swift
//  Local Explorer
//
//  Created by Tony Liu on 9/15/25.
//

import CoreLocation

class LocationManager: NSObject, ObservableObject{
    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    @Published var userLocation: CLLocation?
    @Published var locationName: String = "Unknown Location"
    
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
    
    private func reverseGeocode(location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            
            if let placemark = placemarks?.first {
                let name = placemark.name ?? ""
                let city = placemark.locality ?? ""
                let state = placemark.administrativeArea ?? ""
                
                let formatted = [name, city, state]
                    .filter { !$0.isEmpty }
                    .joined(separator: ", ")
                
                DispatchQueue.main.async {
                    self.locationName = formatted.isEmpty ? "Unknown Location" : formatted
                }
            } else if let error = error {
                print("Reverse geocode failed: \(error.localizedDescription)")
            }
        }
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
            print("Debug: Authorized when in use")
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        guard let location = locations.last else {return}
        self.userLocation = location
        reverseGeocode(location: location)
    }
}
	
