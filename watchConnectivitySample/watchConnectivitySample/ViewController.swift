import UIKit
import WatchConnectivity

class ViewController: UIViewController, ObservableObject {
    
    var filePath = returnDocumentsDirectoryUrl().appendingPathComponent("output.txt")

    var session: WCSession!
    @IBOutlet var label: UILabel!

    var fileURL = URL(fileURLWithPath: "")
    var fileURLstring: String = ""
    @Published var status: String = ""
    
    @Published var fileContents: String = "AAA"
    
    @IBOutlet var fileContentsLabel: UITextView!
    
    @IBAction func tapShowData(_ sender: Any) {
        do {
            print(fileContents)
            fileContentsLabel.text = fileContents
        }
    }
    
    public func getStatus() -> String{
        return status;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureWatchKitSesstion()
    }
    
    func configureWatchKitSesstion() {
        
        if WCSession.isSupported() {
            session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    @IBAction func tapSendData(_ sender: Any) {
        
        do{
            try self.fileContents.write(to: self.filePath, atomically: true, encoding: String.Encoding.utf8)
        }
        catch{
        }
        
        
        var filesToShare = [Any]()
        filesToShare.append(filePath)
        let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
        
    }
    
    static func returnDocumentsDirectoryUrl() -> URL {
        let urlPaths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urlPaths[0]
    }
}


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
