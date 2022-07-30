//
//  FirstView.swift
//  watchConnectivitySample
//
//  Created by Ovidiu Moldovan on 29.07.2022.
//  Copyright © 2022 Ovidiu Moldovan. All rights reserved.
//

import SwiftUI
import CoreMotion

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
    
    private func sendToServer(){
        //SENDING DATA TO SERVER
        var request = URLRequest(url: userSettings.postUrl!)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        request.setValue("Bearer " + userSettings.token, forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        
        let json = [
            //"gpsCoordinates": (self.gpsCoords) as NSString,
            "steps": steps != nil ? steps! : 0 as NSNumber,
            "distance": distance != nil ? distance! : 0 as NSNumber,
            //"device": WKInterfaceDevice.current().model
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
    
    var body: some View {
        NavigationView{
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
                if #available(iOS 14.0, *) {
                    Text(steps != nil ? "\(steps!)" : "No steps available").padding()
                        .onChange(of: steps){ steps in
                            sendToServer()
                        }
                } else {
                    // Fallback on earlier versions
                }
                Text(distance != nil ? "\(distance!)" : "No distance available").padding()
            }
        }
        .environmentObject(viewController)
        .environmentObject(userSettings)
        .onAppear{
            initPedometer()
        }
    }
}

struct FirstView_Previews: PreviewProvider {
    static var previews: some View {
        FirstView()
    }
}
