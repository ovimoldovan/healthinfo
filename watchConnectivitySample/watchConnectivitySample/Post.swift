//
//  Post.swift
//  watchConnectivitySample
//
//  Created by Ovidiu Moldovan on 21/03/2020.
//  Copyright © 2020 Ovidiu Moldovan. All rights reserved.
//

import SwiftUI

struct Post: View {
    @State var bpm = ""
    let url = URL(string: "http://192.168.0.111:5000/Api/DataItem")
    var body: some View {
        Form{
            TextField("BPM",text: $bpm)
            Button(action: {
                var request = URLRequest(url: self.url!)
                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
                request.httpMethod = "POST"
                
                let json = [
                    "heartBpm": (self.bpm as NSString).integerValue,
                ]
                
                if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []){
                    URLSession.shared.uploadTask(with: request, from: jsonData){ data, response, error in
                        print("print action")
                        if let httpResponse = response as? HTTPURLResponse{
                            print(httpResponse.statusCode)
                            print(httpResponse.allHeaderFields)
                        }
                    }.resume()
                }
            }){
                Text("Send")
            }
        }
        .navigationBarTitle("Post")
    }
}

struct Post_Previews: PreviewProvider {
    static var previews: some View {
        Post()
    }
}
