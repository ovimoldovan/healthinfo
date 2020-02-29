import WatchKit
import Foundation
import HealthKit
import WatchConnectivity
import CoreMotion
import CoreLocation

class WorkoutInterfaceController: WKInterfaceController, HKWorkoutSessionDelegate, HKLiveWorkoutBuilderDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var hourLabel: WKInterfaceLabel!
    
    var filePath = InterfaceController.returnDocumentsDirectoryUrl().appendingPathComponent("output.txt")
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
        gpsLabel.setText(gpsCoords)
        print(gpsCoords)
        
        
        /* Showing the location on the map
 
        let locatieAux = CLLocation(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        
        let mapLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(locatieAux.coordinate.latitude, locatieAux.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: mapLocation, span: span)
        
        self.mapView.setRegion(region)
        self.mapView.addAnnotation(mapLocation, with: .red)
         
        */
        
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
                let string = "\n\nStart sesiune noua"
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
        //timer.stop()
        setDurationTimerDate(.paused)
        statusLabel.setText("Status: stopped")
        status = "stopped"
        
        stopPedometerUpdating()
        
        do{
            if let fileUpdater = try? FileHandle(forUpdating: self.filePath){
                fileUpdater.seekToEndOfFile()
                let string = "\n\nTotal pasi in sesiunea curenta: " + steps + "\nTotal distanta parcursa (m) in sesiunea curenta: " + distance
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
            //print(pedometerData.numberOfSteps.stringValue)
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
    
    // Track elapsed time.
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        // Retreive the workout event.
        guard let workoutEventType = workoutBuilder.workoutEvents.last?.type else { return }
        
        // Update the timer based on the event received.
        switch workoutEventType {
        case .pause: // The user paused the workout.
            setDurationTimerDate(.paused)
        case .resume: // The user resumed the workout.
            setDurationTimerDate(.running)
        default:
            return
            
        }
    }
    
    func setDurationTimerDate(_ sessionState: HKWorkoutSessionState) {
        /// Obtain the elapsed time from the workout builder.
        /// - Tag: ObtainElapsedTime
        let timerDate = Date(timeInterval: -self.builder.elapsedTime, since: Date())
               
        
        // Dispatch to main, because we are updating the interface.
        DispatchQueue.main.async {
            self.timer.setDate(timerDate)
        }
        
        // Dispatch to main, because we are updating the interface.
        DispatchQueue.main.async {
            /// Update the timer based on the state we are in.
            /// - Tag: UpdateTimer
            sessionState == .running ? self.timer.start() : self.timer.stop()
        }
    }
    
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else {
                return
            }
            
            /// - Tag: GetStatistics
            let statistics = workoutBuilder.statistics(for: quantityType)
            let label = labelForQuantityType(quantityType)
            
            updateLabel(label, withStatistics: statistics)
        }
    }
    
    // MARK: - State Control
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
                // Dispatch to main, because we are updating the interface.
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
    
    /// Set up the contextual menu based on the workout session state.
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
        // Dispatch to main, because we are updating the interface.
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
//        case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
//            return activeCaloriesLabel
//        case HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning):
//            return distanceLabel
        default:
            return nil
        }
    }
    
    func updateLabel(_ label: WKInterfaceLabel?, withStatistics statistics: HKStatistics?) {
        guard let label = label, let statistics = statistics else {
            return
        }
        
        do {
            //try "0".write(to: self.filePath, atomically: true, encoding: String.Encoding.utf8)
            if self.status=="running"{
                let date = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm:ss"
                self.dateString = formatter.string(from: date)
                do{
                    if let fileUpdater = try? FileHandle(forUpdating: self.filePath){
                        fileUpdater.seekToEndOfFile()
                        fileUpdater.write("\nTimer:".data(using: .utf8)!)
                        fileUpdater.write(dateString.data(using: .utf8)!)
                        fileUpdater.write("\nBPM:".data(using: .utf8)!)
                        fileUpdater.write(String(lastHeartRate).data(using: .utf8)!)
                        fileUpdater.write("\nGPS:".data(using: .utf8)!)
                        fileUpdater.write(self.gpsCoords.data(using: .utf8)!)
                        let string = "\nPasi: " + steps + "\nDistanta parcursa (m): " + distance
                        fileUpdater.write(string.data(using: .utf8)!)
                        fileUpdater.write("\n".data(using: .utf8)!)
                        fileUpdater.write("\n".data(using: .utf8)!)
                        fileUpdater.closeFile()
                    }
                    print(String(lastHeartRate) + ", " + dateString)
                }
            }
        }
        
        DispatchQueue.main.async {
            switch statistics.quantityType {
            case HKQuantityType.quantityType(forIdentifier: .heartRate):
                /// - Tag: SetLabel
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
            
            // The quantity types to read from the health store.
            let typesToRead: Set = [
                HKQuantityType.quantityType(forIdentifier: .heartRate)!
//                HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
//                HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
            ]
            
            // Request authorization for those quantity types.
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
}


