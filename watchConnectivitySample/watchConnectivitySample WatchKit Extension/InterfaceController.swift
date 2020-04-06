import WatchKit
import Foundation
import WatchConnectivity
import HealthKit
import CoreMotion

class InterfaceController: WKInterfaceController {
    
    @IBOutlet weak var label: WKInterfaceLabel!
    var filePath = InterfaceController.returnDocumentsDirectoryUrl().appendingPathComponent("output.txt")
    
    @IBAction func sendFileButton() {
    }
    
    @IBAction func startButton() {
        if hasPermissions{}
    }
    
    @IBOutlet var stepsCountLabel: WKInterfaceLabel!
    @IBOutlet var distanceLabel: WKInterfaceLabel!
    

    
    @IBOutlet var bpmLabel: WKInterfaceLabel!
    //HK
    var healthStore: HKHealthStore?

    
    var hasPermissions = false
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        //HealthKit authorization
        let sampleType: Set<HKSampleType> = [HKSampleType.quantityType(forIdentifier: .heartRate)!]
            
        healthStore = HKHealthStore()
            
        healthStore?.requestAuthorization(toShare: sampleType, read: sampleType, completion: { (success, error) in
            if success {
                self.hasPermissions = true
            }
        })
        
    }

    
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    
    static func returnDocumentsDirectoryUrl() -> URL {
        let urlPaths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urlPaths[0]
    }
    
}
