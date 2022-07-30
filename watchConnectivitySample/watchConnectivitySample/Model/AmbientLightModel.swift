//
//  AmbientLightModel.swift
//  watchConnectivitySample
//
//  Created by Ovidiu Moldovan on 30.07.2022.
//  Copyright © 2022 Ovidiu Moldovan. All rights reserved.
//

// A sensor for ambient light information.

import SensorKit

class SensorKitDelegate: NSObject {
    
}
@available(iOS 14.0, *)
var device:SRDevice?;
@available(iOS 14.0, *)
extension SensorKitDelegate: SRSensorReaderDelegate {
    
    func sensorReaderDidStopRecording(_ reader: SRSensorReader) {
        print("----sensorReaderDidStopRecording");
    }
    func sensorReaderWillStartRecording(_ reader: SRSensorReader) {
        print("----sensorReaderWillStartRecording");
    }
    func sensorReader(_ reader: SRSensorReader, fetching fetchRequest: SRFetchRequest, didFetchResult result: SRFetchResult<AnyObject>) -> Bool {
        print("++++++++++sensorReader fetch");
        print(result.sample)
        return true;
    }
    
    func sensorReader(_ reader: SRSensorReader, didChange authorizationStatus: SRAuthorizationStatus) {
        print("----0000 sensorReader authorizationStatus: ");
    }
    
    func sensorReader(_ reader: SRSensorReader, fetchDevicesDidFailWithError error: Error) {
        print("----00000 sensorReader fetchDevicesDidFailWithError: ");
    }
    func sensorReader(_ reader: SRSensorReader, didFetch devices: [SRDevice]) {
        print("----sensorReader didFetch devices: ");
        device = devices[0]
        print("device ", device)
    }
    func sensorReader(_ reader: SRSensorReader, didCompleteFetch fetchRequest: SRFetchRequest) {
        print("----sensorReader didCompleteFetch: ");
    }
    func sensorReader(_ reader: SRSensorReader, stopRecordingFailedWithError error: Error) {
        print("----sensorReader stopRecordingFailedWithError: ");
    }
    func sensorReader(_ reader: SRSensorReader, startRecordingFailedWithError error: Error) {
        print("----sensorReader startRecordingFailedWithError: ");
    }
    func sensorReader(_ reader: SRSensorReader, fetching fetchRequest: SRFetchRequest, failedWithError error: Error) {
        print("----00000 sensorReader fetching failedWithError: ");
    }
    
}

let toSecondsOffset:Double = -1 * 24 * 60 * 60;
let minute:Double = 60;
let hour:Double = minute * 60;
let fromDate = NSDate().addingTimeInterval(toSecondsOffset - 48*hour);
let toDate = NSDate().addingTimeInterval(toSecondsOffset - hour);

@available(iOS 14.0, *)
public class AmbientLightModel: NSObject, SRSensorReaderDelegate, ObservableObject{
    
    @Published var reader = SRSensorReader(sensor:  .ambientLightSensor)
    let sensorKitDelegate = SensorKitDelegate();
    
    func startRecording() {
        self.checkToSetDelegate();
        self.reader.startRecording();
    }
    
    func stopRecording() {
        self.checkToSetDelegate();
        self.reader.stopRecording();
    }
        
        func checkToSetDelegate() {
            if (self.reader.delegate == nil) {
                print("setting delegate")
                self.reader.delegate = self.sensorKitDelegate;
             }
        }
    
    func fetchDevices() {
        self.reader.fetchDevices();
        
    }
    func fetch() {
           self.checkToSetDelegate();
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
           
           let request = SRFetchRequest();
           request.from = fromDate.srAbsoluteTime;
           request.to = toDate.srAbsoluteTime;
           if let value = device {
               request.device = value;
           } else {
               print("fetching devices")
               self.fetchDevices();
           }
           print("authorizationStatus: \(self.reader.authorizationStatus.rawValue)");
           print("3 from: \(dateFormatter.string(from: NSDate(srAbsoluteTime: request.from) as Date)) to: \(dateFormatter.string(from: NSDate(srAbsoluteTime: request.to) as Date))) device: \(request.device.name)")

           self.reader.fetch(request)
       }
    

    // Displays the authorization approval prompt.
    func requestAuthorization() {
        
        self.checkToSetDelegate();
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                print("from: \(dateFormatter.string(from: fromDate as Date))")
        
        SRSensorReader.requestAuthorization(
                                                sensors: [.ambientLightSensor]) { (error: Error?) in
            if let error = error {
                fatalError("Sensor authorization failed due to: \(error)")
            } else {
                print("""
                    User dismissed the authorization prompt.
                    Awaiting authorization status changes.
                """)
            } }
        reader.delegate = self
    }
}
