//
//  ContentView.swift
//  watchConnectivitySample
//
//  Created by Ovidiu Moldovan on 01/03/2020.
//  Copyright © 2020 Ovidiu Moldovan. All rights reserved.
//

import SwiftUI
import WatchConnectivity


var fileContents: String = "empty"


struct ContentView: View {
    //@State var status: String = "not received"
    @EnvironmentObject var wcProvider: WatchConnectivityProvider
    
    @State var status = "not received"
    @State var fileContents = "empty file"
    
    
    @State private var showShareSheet = false
    //var activityViewController: UIActivityViewController
    @State var filesToShare = [Any]()
    var body: some View {
        NavigationView{
        VStack{
            Text("Status: " + self.status)
            
            NavigationLink(destination: Post())
            {
              Text("post")
            }
            
            Button(action: {
                self.status = self.wcProvider.status
                self.fileContents = self.wcProvider.fileContents
                print(self.status)
                print(self.fileContents)
            }){
                Text("Check for data")
            }
            
            Button(action: {

                let filePath = returnDocumentsDirectoryUrl().appendingPathComponent("output.txt")
                do{
                    try self.fileContents.write(to: filePath, atomically: true, encoding: String.Encoding.utf8)
                }
                catch{
                }
                              
                //var filesToShare = [Any]()
                self.filesToShare.append(filePath)
//                self.activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
                self.showShareSheet = true
            }){
                Text("Share file")
            }
            
            NavigationLink(destination: Login()){
                Text("Login")
                .bold()
            }
            
            List{
                Text("File contents: " + self.fileContents)
            }
            
        }
            
          
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: self.filesToShare)
        }
        .navigationBarTitle(Text("Home"))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
    
    

    struct ShareSheet: UIViewControllerRepresentable {
        typealias Callback = (_ activityType: UIActivity.ActivityType?, _ completed: Bool, _ returnedItems: [Any]?, _ error: Error?) -> Void
          
        let activityItems: [Any]
        let applicationActivities: [UIActivity]? = nil
        let excludedActivityTypes: [UIActivity.ActivityType]? = nil
        let callback: Callback? = nil
          
        func makeUIViewController(context: Context) -> UIActivityViewController {
            let controller = UIActivityViewController(
                activityItems: activityItems,
                applicationActivities: applicationActivities)
            controller.excludedActivityTypes = excludedActivityTypes
            controller.completionWithItemsHandler = callback
            return controller
        }
          
        func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
            // nothing to do here
        }
    }
    


func returnDocumentsDirectoryUrl() -> URL {
    let urlPaths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return urlPaths[0]
}

final class WatchConnectivityProvider: NSObject, WCSessionDelegate, ObservableObject {
    var session: WCSession!
    @Published public var status: String = ""
    @Published public var fileContents: String = ""
    public var fileURLstring: String = ""
 
    init(session: WCSession = .default) {
        super.init()
        configureWatchKitSesstion()
        print(session.isPaired)
    }
    
    func configureWatchKitSesstion() {
        if WCSession.isSupported() {
            print("supported")
            session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
    }

    func sessionDidDeactivate(_ session: WCSession) {
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        print("received data: \(userInfo)")
        DispatchQueue.main.async {
            if let value = userInfo["watch"] as? String {
                //self.label.text = value
                print(value)
            }
        }
    }
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        print("Am terminat de primit")
    }

    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        print("Am primit")
        do {
            let text2 = try String(contentsOf: file.fileURL, encoding: .utf8)

            print(text2)
            
            
        }
        catch {/* error handling here */}
        
        DispatchQueue.main.async {
            do {
                let text2 = try String(contentsOf: file.fileURL, encoding: .utf8)

                print(text2)

                if let value = "received" as? String {
                    self.status = value
                    self.fileURLstring = file.fileURL.relativeString
                    self.fileContents = text2
                    print(value)
                    }
                
            }
            catch {/* error handling here */}
        }
    }
}

