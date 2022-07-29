//
//  FirstView.swift
//  watchConnectivitySample
//
//  Created by Ovidiu Moldovan on 29.07.2022.
//  Copyright © 2022 Ovidiu Moldovan. All rights reserved.
//

import SwiftUI

struct FirstView: View {
    let viewController = WatchConnectivityProvider()
    @EnvironmentObject var userSettings: UserSettings
    var contentView = ContentView()
    
    
    var body: some View {
        NavigationView{
            VStack{
                Text("Logged in as: " + self.userSettings.name)
                NavigationLink(destination: contentView){
                    Text("Watch app")
                }
                NavigationLink(destination: Login().environmentObject(self.userSettings)){
                    Text(self.userSettings.token == "" ? "Login" : "Login as a different user")
                    .bold()
                }
            }
        }
        .environmentObject(viewController)
        .environmentObject(userSettings)
    }
}

struct FirstView_Previews: PreviewProvider {
    static var previews: some View {
        FirstView()
    }
}
