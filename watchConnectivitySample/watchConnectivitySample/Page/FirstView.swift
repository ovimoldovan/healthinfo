//
//  FirstView.swift
//  watchConnectivitySample
//
//  Created by Ovidiu Moldovan on 29.07.2022.
//  Copyright © 2022 Ovidiu Moldovan. All rights reserved.
//

import SwiftUI
import CoreMotion
import MapKit
import SensorKit

@available(iOS 14.0, *)
struct FirstView: View {
    //Environment variables
    let viewController = WatchConnectivityProvider()
    @EnvironmentObject var userSettings: UserSettings
    var contentView = ContentView()
    
    //CMPedometer data
    private let pedometer: CMPedometer = CMPedometer()
    @State private var steps: Int?
    @State private var distance: Double?
    
    private var isPedometerAvailable: Bool{
        return CMPedometer.isPedometerEventTrackingAvailable() &&
        CMPedometer.isStepCountingAvailable() &&
        CMPedometer.isDistanceAvailable()
    }
    
    private func initPedometer(){
        if(isPedometerAvailable){
            pedometer.startUpdates(from: Date()) { (data, error) in
                guard let data = data, error == nil else {return}
                
                steps = data.numberOfSteps.intValue
                distance = data.distance?.doubleValue
                
            }
        }
    }
    
    //CMAltimeter data
    private let altimeter = CMAltimeter()
    private let motionManager = CMMotionManager()
    let queue = OperationQueue()
    
    @State private var relativeAltitude = 0.0
    @State private var absoluteAltitude = 0.0
    @State private var pressure = 0.0
    
    func initAltimeter(){
        if #available(iOS 15.0, *) {
            if(CMAltimeter.isRelativeAltitudeAvailable()){
                switch(CMAltimeter.authorizationStatus()){
                    
                case .notDetermined:
                    print("waiting approval for altimeter")
                case .restricted, .denied:
                    print("altimeter restricted or denied")
                case .authorized:
                    self.altimeter.startRelativeAltitudeUpdates(to: OperationQueue.main) {(data,error) in DispatchQueue.main.async {
                        relativeAltitude = Double(data?.relativeAltitude ?? 0.0)
                        pressure = Double(data?.pressure ?? 0.0)
                        //print("\(relativeAltitude)")
                    }
                    }
                    self.altimeter.startAbsoluteAltitudeUpdates(to: OperationQueue.main){
                        (data,error) in DispatchQueue.main.async {
                            absoluteAltitude = Double(data?.altitude ?? 0.0)
                    }
                    }
                @unknown default:
                    break
                    
                    
                    if(CMAltimeter.isAbsoluteAltitudeAvailable()){
                        switch(CMAltimeter.authorizationStatus()){
                            
                        case .notDetermined:
                            print("waiting approval for altimeter")
                        case .restricted, .denied:
                            print("altimeter restricted or denied")
                        case .authorized:
                            self.altimeter.startAbsoluteAltitudeUpdates(to: OperationQueue.main) {(data,error) in DispatchQueue.main.async {
                                absoluteAltitude = Double(data?.altitude ?? 0.0)
                                //print("\(absoluteAltitude)")
                            }}
                        @unknown default:
                            break
                        }
                    }
                }
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    private func sendToServer(){
        //Check for the latest lat + long
        locationModel.updateLatLong()
        //SENDING DATA TO SERVER
        var request = URLRequest(url: userSettings.postUrl!)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        request.setValue("Bearer " + userSettings.token, forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        
        let json = [
            "gpsCoordinates": (String(locationModel.latitude) + " " + String(locationModel.longitude)) as NSString,
            "steps": steps != nil ? steps! : 0 as NSNumber,
            "distance": distance != nil ? distance! : 0 as NSNumber,
            "relativeAltitude": relativeAltitude as NSNumber,
            "absoluteAltitude": absoluteAltitude as NSNumber,
            "pressure": pressure as NSNumber,
            "device": UIDevice.modelName
        ] as [String : Any]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []){
            URLSession.shared.uploadTask(with: request, from: jsonData){ data, response, error in
                print("print action")
                if let httpResponse = response as? HTTPURLResponse{
                    print(httpResponse.statusCode)
                    print(httpResponse.allHeaderFields)
                }
            }.resume()
        }
    }
    
    //Map Data
    
    @StateObject private var locationModel: LocationModel = LocationModel()
    
    var body: some View {
        NavigationView{
            GeometryReader
            { proxy in
                VStack(spacing: 0.0){
                    ZStack{
                        Map(coordinateRegion: $locationModel.region, showsUserLocation: true)
                    }
                    .frame(height: proxy.size.height/3)
                    .navigationTitle("Health Info")
                    .onAppear{
                        locationModel.checkIfLocationIsEnabled()
                    }
                    ZStack{
                        VStack{
                            Text("Logged in as: " + self.userSettings.name)
                                .padding()
                            NavigationLink(destination: contentView){
                                Text("Watch app")
                            }
                            .padding()
                            NavigationLink(destination: Login().environmentObject(self.userSettings)){
                                Text(self.userSettings.token == "" ? "Login" : "Login as a different user")
                                    .bold()
                                    .padding()
                            }
                            Text(steps != nil ? "Steps: \(steps!)" : "No steps available").padding()
                                .onChange(of: steps){ steps in
                                    sendToServer()
                                }
                            Text(distance != nil ? "Distance: \(distance!) (m)" : "No distance available").padding()
                            Text("Relative Altitude: " + String(relativeAltitude) + "(m)")
                            Text("Absolute Altitude: " + String(absoluteAltitude) + "(m)")
                            Text("Pressure: " + String(pressure) + "(kPa)")
                        }
                    }
                }
            }
        }
        .environmentObject(viewController)
        .environmentObject(userSettings)
        .onAppear{
            initPedometer()
            initAltimeter()
        }
        .ignoresSafeArea()
    }
}

struct FirstView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 14.0, *) {
            FirstView()
        } else {
            // Fallback on earlier versions
        }
    }
}
