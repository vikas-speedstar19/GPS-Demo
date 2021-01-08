//
//  AppDelegate.swift
//  GPS-Demo
//
//  Created by monty on 06/01/21.
//

import UIKit
import CoreLocation
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MAR: - Properties
    
    var window: UIWindow?
    var locationManager: CLLocationManager? = CLLocationManager()
    var myLocation: CLLocation?
    
    // MARK: - App Lifecyele
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if launchOptions?[UIApplication.LaunchOptionsKey.location] != nil {
            if locationManager == nil {
                locationManager = CLLocationManager()
                locationManager?.delegate = self
                locationManager?.distanceFilter = 10
                locationManager?.desiredAccuracy = kCLLocationAccuracyBest
                locationManager?.allowsBackgroundLocationUpdates = true
                locationManager?.startUpdatingLocation()
            } else {
                locationManager = nil
                locationManager = CLLocationManager()
                locationManager?.delegate = self
                locationManager?.distanceFilter = 10
                locationManager?.desiredAccuracy = kCLLocationAccuracyBest
                locationManager?.allowsBackgroundLocationUpdates = true
                locationManager?.startUpdatingLocation()
            }
        } else {
            locationManager?.delegate = self
            locationManager?.distanceFilter = 10
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager?.allowsBackgroundLocationUpdates = true
            
            if locationManager?.authorizationStatus == .notDetermined {
                locationManager?.requestAlwaysAuthorization()
            }
            else if locationManager?.authorizationStatus == .denied {
                // This point is handled in ViewController
            }
            else if locationManager?.authorizationStatus == .authorizedWhenInUse {
                locationManager?.requestAlwaysAuthorization()
            }
            else if locationManager?.authorizationStatus == .authorizedAlways {
                locationManager?.startUpdatingLocation()
            }
        }
        registerNotifications()
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        guard let location = myLocation else {
            print("Location Object is nil")
            return
        }
        createRegion(location: location)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func registerNotifications() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                guard granted else { return }
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        UNUserNotificationCenter.current().delegate = self
    }
    
    func createRegion(location: CLLocation) {
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            let latValue = UserDefaults.standard.double(forKey: "lat")
            let longValue = UserDefaults.standard.double(forKey: "long")
            let coordinate = CLLocationCoordinate2DMake(latValue, longValue)
            let regionRadius = 200.0
            let region = CLCircularRegion(center: CLLocationCoordinate2D(
                                            latitude: coordinate.latitude,
                                            longitude: coordinate.longitude),
                                          radius: regionRadius,
                                          identifier: "RegionIdentifier")
            region.notifyOnEntry = true
            // region.notifyOnExit = true
            postNotification(alert: "Entered Home Region")
            locationManager?.stopUpdatingLocation()
            locationManager?.startMonitoring(for: region)
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Successfully registered for notifications!")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifs")
    }
    
    // MARK:- UNUserNotification Delegates
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([UNNotificationPresentationOptions.badge, UNNotificationPresentationOptions.sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let latValue = UserDefaults.standard.double(forKey: "lat")
        let longValue = UserDefaults.standard.double(forKey: "long")
        LocationAPIs.postHomeCoordinates(latitude: latValue, longitude: longValue)
    }
    
    private func postNotification(alert: String) {
        let content = UNMutableNotificationContent()
        let requestIdentifier = UUID.init().uuidString
        content.badge = 0
        content.title = "Reached Home"
        content.body = alert
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1.0, repeats: false)
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error:Error?) in
            if error != nil {
                print(error?.localizedDescription ?? "")
            }
        }
    }
    
}

// MARK: - CLLocationManagerDelegate

extension AppDelegate: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        if location.horizontalAccuracy <= Double(65.0) {
            myLocation = location
            if !(UIApplication.shared.applicationState == .active) {
                createRegion(location: location)
            }
        } else {
            manager.stopUpdatingLocation()
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        postNotification(alert: "Entered Home Region")
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
}
