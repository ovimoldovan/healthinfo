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

struct UserStruct: Codable {
    let username: String
    let name: String
}


struct Login: View {
    @State var username = ""
    @State var password = ""
    @State var name = "not logged in"
    let url = URL(string: "http://192.168.0.111:5000/Api/User/login")
    var body: some View {
        Form{
            TextField("Username", text: $username)
            TextField("Password", text: $password)
//            Button(action: {
//                var request = URLRequest(url: self.url!)
//                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
//                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
//                request.httpMethod = "POST"
//
//                let json = [
//                    "username": self.username,
//                    "password": self.password
//                ]
//
//                if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []){
//                    URLSession.shared.uploadTask(with: request, from: jsonData){ data, response, error in
//                        print("print action")
//                        if let httpResponse = response as? HTTPURLResponse{
//                            print(httpResponse.statusCode)
//                            if(httpResponse.statusCode == 200) {
//                                let newUser: [String: Any] = ["username":"user", "name":"nume"]
//                                    let jsonUser: Data
//                                    do {
//                                        jsonUser = try JSONSerialization.data(withJSONObject: newUser, options: [])
//                                        request.httpBody = jsonUser
//                                        print(jsonUser)
//                                    self.name = "Welcome, "
//                                }catch {
//                                    print("Error decoding json")
//                                }
//                            }
//                            else {
//                                self.name = "invalid credentials"
//                            }
//                        }
//                    }.resume()
//                }
//            }){
//                Text("Send")
//            }
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
                            //debugPrint(response)
                        if(response.response?.statusCode != 200) {
                            self.name = "login failed"
                        }
                        else {
                            if let value: Any = response.value{
                                let post = JSON(value)
                                self.name = "Welcome, " + (post["name"].stringValue)
                            }
                        }
                }
            }){
            Text("Login")
            }
            Text(self.name)
        }
        .navigationBarTitle("Post")
    }
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login()
    }
}
