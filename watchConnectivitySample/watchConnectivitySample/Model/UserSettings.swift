//
//  UserSettings.swift
//  watchConnectivitySample
//
//  Created by Crisan Alexandra on 30.07.2022.
//  Copyright © 2022 Ovidiu Moldovan. All rights reserved.
//

import Foundation

public class UserSettings: ObservableObject {
    @Published var token = ""
    @Published var name = "anonymous"
    @Published var postUrl = URL(string: "http://healthinfo.azurewebsites.net/Api/DataItem")
}
