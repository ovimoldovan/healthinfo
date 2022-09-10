import WatchKit
import Foundation
import HealthKit
import WatchConnectivity
import CoreMotion
import CoreLocation

class WorkoutInterfaceController: WKInterfaceController, HKWorkoutSessionDelegate, HKLiveWorkoutBuilderDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var hourLabel: WKInterfaceLabel!
    
    var filePath = InterfaceController.returnDocumentsDirectoryUrl().appendingPathComponent("output.txt")
    
    let url = URL(string: "https://healthinfo.azurewebsites.net/Api/DataItem")
    
    //Location related
    let locationManager = CLLocationManager()
    var gpsCoords: String = ""
    
    func setupLocation() {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.first else { return }
        
        self.gpsCoords = String(currentLocation.coordinate.latitude) + " " + String(currentLocation.coordinate.longitude)
        
        gpsLabel.setText("GPS: " + gpsCoords)
        print(gpsCoords)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("LOCATION MANAGER DID FAIL ERROR : \(error)")
    }
    
    
    @IBOutlet var timer: WKInterfaceTimer!
    
    @IBOutlet weak var activeCaloriesLabel: WKInterfaceLabel!
    @IBOutlet var heartRateLabel: WKInterfaceLabel!
    @IBOutlet var stepsLabel: WKInterfaceLabel!
    @IBOutlet var gpsLabel: WKInterfaceLabel!
    
    @IBOutlet var statusLabel: WKInterfaceLabel!
    private var status: String = ""
    
    private var lastHeartRate: Int = 0
    let session = WCSession.default
    private var distance: String = "0"
    private var steps: String = "0"
    @IBOutlet weak var distanceLabel: WKInterfaceLabel!
    var token: String = ""
    
    @IBAction func startLogging() {
        if(status == "stopped") {
            resumeWorkout()
        }
        
        self.distance = "0"
        self.steps = "0"
        
        status = "running"
        
        do{
            if let fileUpdater = try? FileHandle(forUpdating: self.filePath){
                fileUpdater.seekToEndOfFile()
                let string = "\n\nStart new session, device: " + getWatchModel()
                print(string)
                fileUpdater.write(string.data(using: .utf8)!)
                fileUpdater.write("\n".data(using: .utf8)!)
                fileUpdater.closeFile()
            }
        }
        
        statusLabel.setText("Status: running")
        timer.start()
        
        startPedometerUpdating()
        
        setupLocation()
    }
    
    
    @IBAction func endLogging() {
        pauseWorkout()
        
        setDurationTimerDate(.paused)
        statusLabel.setText("Status: stopped")
        status = "stopped"
        
        stopPedometerUpdating()
        
        do{
            if let fileUpdater = try? FileHandle(forUpdating: self.filePath){
                fileUpdater.seekToEndOfFile()
                let string = "\n\nTotal steps: " + steps + "\nTotal distance (m):  " + distance + " recorded on " + getWatchModel()
                print(string)
                fileUpdater.write(string.data(using: .utf8)!)
                fileUpdater.write("\n".data(using: .utf8)!)
                fileUpdater.closeFile()
            }
        }
    }
    
    @IBAction func sendLogging() {
        session.transferFile(self.filePath, metadata: nil)
    }
    
    
    var healthStore = HKHealthStore()
    var configuration = HKWorkoutConfiguration()
    
    var workoutSession: HKWorkoutSession!
    var builder: HKLiveWorkoutBuilder!
    var dateString: String = ""
    
    
    //Pedometer and distance
    private let activityManager = CMMotionActivityManager()
    
    private let pedometer = CMPedometer()
    private func countSteps() {
        pedometer.startUpdates(from: Date()) {
            [weak self] pedometerData, error in
            guard let pedometerData = pedometerData, error == nil else { return }
            
            DispatchQueue.main.async {
                self?.stepsLabel.setText(pedometerData.numberOfSteps.stringValue)
                print(pedometerData.numberOfSteps.stringValue)
                self?.distanceLabel.setText(pedometerData.distance?.stringValue)
                self?.distance = pedometerData.distance?.stringValue ?? "0"
                self?.steps = pedometerData.numberOfSteps.stringValue
            }
        }
    }
    
    private func startPedometerUpdating(){
        if CMPedometer.isStepCountingAvailable() {
            countSteps()
        }
        else{
            self.stepsLabel.setText("Pedometer error")
        }
    }
    
    private func stopPedometerUpdating() {
        activityManager.stopActivityUpdates()
        pedometer.stopUpdates()
        pedometer.stopEventUpdates()
    }
    
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        setupWorkoutSessionInterface(with: context)
        
        session.delegate = self
        session.activate()
        
        //Workout session
        do {
            workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = workoutSession.associatedWorkoutBuilder()
        } catch {
            dismiss()
            return
        }
        
        
        workoutSession.delegate = self
        builder.delegate = self
        
        builder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore,
                                                     workoutConfiguration: configuration)
        
        workoutSession.startActivity(with: Date())
        builder.beginCollection(withStart: Date()) { (success, error) in
            self.setDurationTimerDate(.running)
        }
        
    }
    
    
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        // Retreive the workout event.
        guard let workoutEventType = workoutBuilder.workoutEvents.last?.type else { return }
        switch workoutEventType {
        case .pause:
            setDurationTimerDate(.paused)
        case .resume:
            setDurationTimerDate(.running)
        default:
            return
            
        }
    }
    
    func setDurationTimerDate(_ sessionState: HKWorkoutSessionState) {
        let timerDate = Date(timeInterval: -self.builder.elapsedTime, since: Date())
        
        DispatchQueue.main.async {
            self.timer.setDate(timerDate)
        }
        
        DispatchQueue.main.async {
            sessionState == .running ? self.timer.start() : self.timer.stop()
        }
    }
    
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else {
                return
            }
            
            let statistics = workoutBuilder.statistics(for: quantityType)
            let label = labelForQuantityType(quantityType)
            
            updateLabel(label, withStatistics: statistics)
        }
    }
    
    func pauseWorkout() {
        workoutSession.pause()
    }
    
    func resumeWorkout() {
        workoutSession.resume()
    }
    
    func endWorkout() {
        workoutSession.end()
        builder.endCollection(withEnd: Date()) { (success, error) in
            self.builder.finishWorkout { (workout, error) in
                DispatchQueue.main.async() {
                    self.dismiss()
                }
            }
        }
    }
    
    func setupWorkoutSessionInterface(with context: Any?) {
        guard let context = context as? WorkoutSessionContext else {
            dismiss()
            return
        }
        
        healthStore = context.healthStore
        configuration = context.configuration
        
        setupMenuItemsForWorkoutSessionState(.running)
    }
    
    func setupMenuItemsForWorkoutSessionState(_ state: HKWorkoutSessionState) {
        clearAllMenuItems()
        if state == .running {
            addMenuItem(with: .pause, title: "Pause", action: #selector(pauseWorkoutAction))
        } else if state == .paused {
            addMenuItem(with: .resume, title: "Resume", action: #selector(resumeWorkoutAction))
        }
        
        addMenuItem(with: .decline, title: "End", action: #selector(endWorkoutAction))
    }
    
    @objc
    func pauseWorkoutAction() {
        pauseWorkout()
    }
    
    @objc
    func resumeWorkoutAction() {
        resumeWorkout()
    }
    
    @objc
    func endWorkoutAction() {
        endWorkout()
    }
    
    func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didChangeTo toState: HKWorkoutSessionState,
        from fromState: HKWorkoutSessionState,
        date: Date
    ) {
        DispatchQueue.main.async {
            self.setupMenuItemsForWorkoutSessionState(toState)
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        //TODO
        //Error handling
    }
    
    func labelForQuantityType(_ type: HKQuantityType) -> WKInterfaceLabel? {
        switch type {
        case HKQuantityType.quantityType(forIdentifier: .heartRate):
            return heartRateLabel
        default:
            return nil
        }
    }
    
    fileprivate func writeRunningDataToFile() {
        if let fileUpdater = try? FileHandle(forUpdating: self.filePath){
            fileUpdater.seekToEndOfFile()
            fileUpdater.write("\nTimer:".data(using: .utf8)!)
            fileUpdater.write(dateString.data(using: .utf8)!)
            fileUpdater.write("\nBPM:".data(using: .utf8)!)
            fileUpdater.write(String(lastHeartRate).data(using: .utf8)!)
            fileUpdater.write("\nGPS:".data(using: .utf8)!)
            fileUpdater.write(self.gpsCoords.data(using: .utf8)!)
            let string = "\nSteps: " + steps + "\nDistance (m): " + distance
            fileUpdater.write(string.data(using: .utf8)!)
            fileUpdater.write("\n".data(using: .utf8)!)
            fileUpdater.write("\n".data(using: .utf8)!)
            fileUpdater.closeFile()
        }
        print(String(lastHeartRate) + ", " + dateString)
    }

    fileprivate func sendDataToApi() {
        var request = URLRequest(url: self.url!)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        request.setValue("Bearer " + self.token, forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        
        let json = [
            "heartBpm": lastHeartRate as NSNumber,
            "gpsCoordinates": (self.gpsCoords) as NSString,
            "steps": (steps as NSString).integerValue as NSNumber,
            "distance": (distance as NSString).integerValue as NSNumber,
            //"device": WKInterfaceDevice.current().model
            "device": getWatchModel()
        ] as [String : Any]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []){
            URLSession.shared.uploadTask(with: request, from: jsonData){ data, response, error in
                print("print action")
                if let httpResponse = response as? HTTPURLResponse{
                    print(httpResponse.statusCode)
                    print(httpResponse.allHeaderFields)
                }
            }.resume()
        }
    }

func updateLabel(_ label: WKInterfaceLabel?, withStatistics statistics: HKStatistics?) {
        guard let label = label, let statistics = statistics else {
            return
        }
        
        do {
            if self.status=="running"{
                let date = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm:ss"
                self.dateString = formatter.string(from: date)
                self.hourLabel.setText(self.dateString)
                do{
                    writeRunningDataToFile()
                    
                    sendDataToApi()
                }
            }
        }
        
        DispatchQueue.main.async {
            switch statistics.quantityType {
            case HKQuantityType.quantityType(forIdentifier: .heartRate):
                
                let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                
                let value = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit)
                let roundedValue = Int( round( 1 * value! ) / 1 )
                label.setText("\(roundedValue) BPM")
                self.lastHeartRate = roundedValue
            default:
                return
            }
        }
    }
    func getWatchModel() -> String {
        var size: size_t = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = CChar()
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        let model = String(cString: &machine, encoding: String.Encoding.utf8)
        switch model {
        case "Watch1,1":
            return "Apple Watch 28mm"
        case "Watch1,2":
            return"Apple Watch 42mm"
        case "Watch2,3":
            return "Apple Watch Series 2 38mm"
        case "Watch2,4":
            return "Apple Watch Series 2 42mmm"
        case "Watch2,6":
            return "Apple Watch Series 1 38mm"
        case "Watch2,7":
            return "Apple Watch Series 1 42mm"
        case "Watch3,1":
            return "Apple Watch Series 3 38mm Cellular"
        case "Watch3,2":
            return "Apple Watch Series 3 42mm Cellular"
        case "Watch3,3":
            return "Apple Watch Series 3 38mm"
        case "Watch3,4":
            return "Apple Watch Series 3 42mm"
        case "Watch4,1":
            return "Apple Watch Series 4 40mm"
        case "Watch4,2":
            return "Apple Watch Series 4 44mm"
        case "Watch4,3":
            return "Apple Watch Series 4 40mm Cellular"
        case "Watch4,4":
            return "Apple Watch Series 4 44mm Cellular"
        case "Watch5,1":
            return "Apple Watch Series 5 40mm"
        case "Watch5,2":
            return "Apple Watch Series 5 44mm"
        case "Watch5,3":
            return "Apple Watch Series 5 40mm Cellular"
        case "Watch5,4":
            return "Apple Watch Series 5 44mm Cellular"
        default:
            return "unknown"
        }
    }
    
    
    override func didAppear() {
        super.didAppear()
        
        do{
            try "START\n".write(to: self.filePath, atomically: false, encoding: String.Encoding.utf8)
        }
        catch{
            print("File write error")
        }
        
        let typesToShare: Set = [
            HKQuantityType.workoutType()
        ]
        
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!
        ]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
            //TODO
            //Error handling
        }
    }
    
    override func contextForSegue(withIdentifier segueIdentifier: String) -> Any? {
        if segueIdentifier == "startWorkout" {
            let configuration = HKWorkoutConfiguration()
            configuration.activityType = .running
            configuration.locationType = .outdoor
            
            return WorkoutSessionContext(healthStore: healthStore, configuration: configuration)
        }
        
        return nil
    }
    
}

class WorkoutSessionContext {
    
    let configuration: HKWorkoutConfiguration
    let healthStore: HKHealthStore
    
    init(healthStore: HKHealthStore, configuration: HKWorkoutConfiguration) {
        self.healthStore = healthStore
        self.configuration = configuration
    }
    
}

extension WorkoutInterfaceController: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("received message: \(message)")
        DispatchQueue.main.async {
            if let value = message["Bearer "] as? String {
                print(value)
                self.token = value
            }
        }
    }
}


