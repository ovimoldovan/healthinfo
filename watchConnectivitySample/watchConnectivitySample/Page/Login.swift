//
//  Post.swift
//  watchConnectivitySample
//
//  Created by Ovidiu Moldovan on 21/03/2020.
//  Copyright © 2020 Ovidiu Moldovan. All rights reserved.
//

import SwiftUI
import Alamofire
import SwiftyJSON

struct Login: View {
    @EnvironmentObject var userSettings: UserSettings
    @State var username = ""
    @State var password = ""
    @State var name = "not logged in"
    let url = URL(string: "http://healthinfo.azurewebsites.net/Api/User/login")
    var body: some View {
        NavigationView{
            Form{
                TextField("Username", text: $username)
                SecureField("Password", text: $password)
                Button(action: {
                    let loginRequest = [
                        "username" : self.username,
                        "password" : self.password
                    ]
                    let header: HTTPHeaders = [
                        "Content-Type": "application/json"
                    ]
                    AF.request(self.url!, method: .post, parameters: loginRequest, encoding: JSONEncoding.default, headers: header)
                        .responseJSON{
                            response in
                            if(response.response?.statusCode != 200) {
                                self.name = "login failed"
                            }
                            else {
                                if let value: Any = response.value{
                                    let post = JSON(value)
                                    self.name = "Welcome, " + (post["name"].stringValue)
                                    self.userSettings.token = post["token"].stringValue
                                    self.userSettings.name = post["name"].stringValue
                                    print(self.userSettings.token)
                                }
                            }
                        }
                }){
                    Text("Login")
                }
                Text(self.name)
                NavigationLink(destination: Post(token: self.userSettings.token))
                {
                    Text("post")
                }
            }
            
        }
        .navigationBarTitle("Login")
        .environmentObject(userSettings)
    }
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login()
    }
}
