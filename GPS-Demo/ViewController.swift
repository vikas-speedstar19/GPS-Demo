//
//  ViewController.swift
//  GPS-Demo
//
//  Created by monty on 06/01/21.
//

import UIKit
import CoreLocation
import UserNotifications

class ViewController: UIViewController {
    
    // MARK: - Constants
    
    private let navigationTitle = "Demo Home"
    private let alertControllerTitle = "Location Permission"
    private let alertMessage = "Please change the location permission to always to take most benefit of GPS-Demo"
    private let settingsTitle = "Settings"
    private let cancelTitle = "Cancel"
    private let updateTitle = "Update"
    
    // MARK: - Properties
    
    private let locationManager = CLLocationManager()
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var gpsCoordinatesLabel: UILabel!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        
        // Display permission for location permission
        getLocationGPS()
    }
    
    // MARK: - Private Helper Methods
    
    private func setupNavigationBar() {
        title = navigationTitle
        let rightNavButton = UIBarButtonItem(title: updateTitle, style: .plain, target: self, action: #selector(showHomeLocationChangePopup))
        navigationItem.rightBarButtonItem = rightNavButton
    }
    
    private func getLocationGPS() {
        displayLocationPermissionDialog()
        displayDialogIfLocationPermissionNotAlways()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        appDelegate.locationManager?.delegate = self
    }
    
    private func updateGPSCoordinatesLabel(latitude: Double, longitude: Double) {
        print("\(latitude)\n\(longitude)")
        gpsCoordinatesLabel.text = "\(latitude)\n\(longitude)"
    }
    
    @objc private func showHomeLocationChangePopup() {
        let navController = UINavigationController(rootViewController: LocationUpdateViewController())
        present(navController, animated: true, completion: nil)
    }
    
}

// MARK: - CLLocationManagerDelegate

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        updateGPSCoordinatesLabel(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus != .authorizedAlways {
            displayDialogIfLocationPermissionNotAlways()
        }
    }
    
}

// MARK: - Permission Dialog Methods

extension ViewController {
    
    private func displayDialogIfLocationPermissionNotAlways() {
        if locationManager.authorizationStatus == .notDetermined {
            return
        }
        if locationManager.authorizationStatus != .authorizedAlways {
            // Display dialog with appropriate message for always location permission
            let alertController = UIAlertController(title: alertControllerTitle,
                                                    message: alertMessage,
                                                    preferredStyle: .alert)
            let settingOption = UIAlertAction(title: settingsTitle, style: .default) { (action) in
                self.navigateToSettings()
            }
            let cancelOption = UIAlertAction(title: cancelTitle, style: .cancel) { (action) in }
            alertController.addAction(settingOption)
            alertController.addAction(cancelOption)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    private func displayLocationPermissionDialog() {
        if locationManager.authorizationStatus != .authorizedWhenInUse || locationManager.authorizationStatus != .authorizedAlways {
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    func navigateToSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
}
