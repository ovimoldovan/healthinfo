import UIKit
import WatchConnectivity

class ViewController: UIViewController {
    
    var filePath = returnDocumentsDirectoryUrl().appendingPathComponent("output.txt")

    var session: WCSession!
    @IBOutlet var label: UILabel!

    var fileURL = URL(fileURLWithPath: "")
    var fileURLstring: String = ""
    var status: String = ""
    
    var fileContents: String = "AAA"
    
    @IBOutlet var fileContentsLabel: UITextView!
    
    @IBAction func tapShowData(_ sender: Any) {
        do {
            //let text2 = try String(contentsOf: URL(fileURLWithPath: fileURLstring), encoding: .utf8)
            print(fileContents)
            fileContentsLabel.text = fileContents
        }
        catch {/* error handling here */}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()        // Do any additional setup after loading the view.
        self.configureWatchKitSesstion()//4
    }
    
    func configureWatchKitSesstion() {
        
        if WCSession.isSupported() {
            session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    //5
    @IBAction func tapSendData(_ sender: Any) {
//        if let validSession = self.session {
//            let data: [String: Any] = ["iPhone": "Data from iPhone" as Any] // Create your Dictionay as per uses
//            validSession.transferUserInfo(data)
//        }
        // Create the Array which includes the files you want to share
        
        do{
            try self.fileContents.write(to: self.filePath, atomically: true, encoding: String.Encoding.utf8)
        }
        catch{
        }
        
        
        var filesToShare = [Any]()

        // Add the path of the file to the Array
        filesToShare.append(filePath)

        // Make the activityViewContoller which shows the share-view
        let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)

        // Show the share-view
        self.present(activityViewController, animated: true, completion: nil)
        
    }
    
    static func returnDocumentsDirectoryUrl() -> URL {
        let urlPaths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urlPaths[0]
    }
}

// WCSession delegate functions
extension ViewController: WCSessionDelegate {
    
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
                self.label.text = value
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
            self.fileURLstring = file.fileURL.relativeString
            self.fileContents = text2
            
        }
        catch {/* error handling here */}
        
        DispatchQueue.main.async {
        if let value = "status: received" as? String {
            self.label.text = value
            print(value)
            }
        }
    }
}
