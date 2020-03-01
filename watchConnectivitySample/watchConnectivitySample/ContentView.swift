//
//  ContentView.swift
//  watchConnectivitySample
//
//  Created by Ovidiu Moldovan on 01/03/2020.
//  Copyright © 2020 Ovidiu Moldovan. All rights reserved.
//

import SwiftUI
import WatchConnectivity

var status: String = "not received"

let viewController = ViewController()

var filePath = returnDocumentsDirectoryUrl().appendingPathComponent("output.txt")
var fileContents: String = "empty"


struct ContentView: View {
    var body: some View {
        VStack{
            Text(status)
            Button(action: {
                print("button tapped")
            }){
                Text("press")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

func tapShowData() {
    print(fileContents)
    //fileContentsLabel.text = fileContents
}

func returnDocumentsDirectoryUrl() -> URL {
    let urlPaths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return urlPaths[0]
}

