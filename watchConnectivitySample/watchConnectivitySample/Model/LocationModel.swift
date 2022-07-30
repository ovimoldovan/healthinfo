//
//  LocationModel.swift
//  watchConnectivitySample
//
//  Created by Ovidiu Moldovan on 30.07.2022.
//  Copyright © 2022 Ovidiu Moldovan. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

@available(iOS 14.0, *)
public final class LocationModel : NSObject, ObservableObject, CLLocationManagerDelegate{
    
    
    var locationManager: CLLocationManager?
    
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 46.75, longitude: 23.55), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    
    @Published var latitude = 0.0
    @Published var longitude = 0.0
    
    func updateLatLong(){
        guard let locationManager = locationManager else {
            return
        }
        self.latitude = locationManager.location?.coordinate.latitude ?? 0.0
        self.longitude = locationManager.location?.coordinate.longitude ?? 0.0
    }
    
    func checkIfLocationIsEnabled(){
        if CLLocationManager.locationServicesEnabled(){
            locationManager = CLLocationManager()
            //checkIfLocationIsAuthorized()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.delegate = self
        }
    }
    
    private func checkIfLocationIsAuthorized(){
        guard let locationManager = locationManager else {
            return
        }
        switch locationManager.authorizationStatus{
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("location restricted")
        case .denied:
            print("location denied")
        case .authorizedAlways, .authorizedWhenInUse:
            region = MKCoordinateRegion(center: locationManager.location!.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        @unknown default:
            break
        }
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkIfLocationIsAuthorized()
    }
}
