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
                Text(steps != nil ? "\(steps!)" : "No steps available").padding()
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
