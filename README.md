# watchKitSensors
This project contains 3 basic mobile applications (iPhone and Apple Watch - Swift, ESP32 microcontroller - Arduino/FreeRTOS) that collect sensors data and send it to a C# .NET API. The users then see the data on a React web application.
![image](https://user-images.githubusercontent.com/4541684/189479669-9ccb82f5-bb29-405d-bce6-0594c54a3aa7.png)

## iOS app
 - Written in Swift
 - Uses SwiftUI
 - Other frameworks: CoreMotion, CoreLocation, WatchConnectivity (the iOS app sends authorization data to the watchOS app)
 ![image](https://user-images.githubusercontent.com/4541684/189479961-db2f3a27-d4da-46c5-8dde-0439df8d8472.png)

## watchOS app
 - Written in Swift
 - WatchKit for the UI
 Other frameworks: HealthKit, CoreMotion, CoreLocation, WatchConnecitivy
 <img width="268" alt="image" src="https://user-images.githubusercontent.com/4541684/189480017-024c07f9-3679-43ab-9ba7-318184985e5c.png">
 
## ESP32 app
 - Written in Arduino
 - Uses FreeRTOS tasks
 ![image](https://user-images.githubusercontent.com/4541684/189480045-a641fb77-b68a-40a5-93fe-c98f6a333941.png)

## API and web app
 - Written in C#, .NET Core 3.1
 - SQLite database, Entity Framework Core
 - MVC Architecture
 - Basic authentication using JWT
 - Unit testing
 - Web app using React
 - Azure App Service (https://healthinfo.azurewebsites.net/ ![image](https://user-images.githubusercontent.com/4541684/189480189-99fe8e19-096e-4344-8d30-1f4d6b81fff3.png)
