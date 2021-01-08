//
//  LocationUpdateViewController.swift
//  GPS-Demo
//
//  Created by monty on 07/01/21.
//

import UIKit
import CoreLocation

class LocationUpdateViewController: UIViewController {

    // MARK: - Constants

    private let navTitle = "Home Location Update"

    // MARK: - Properties

    var latitude: Double?
    var longitude: Double?

    // MARK: - IBOutlets

    @IBOutlet weak var latitudeTextField: UITextField!
    @IBOutlet weak var longitudeTextField: UITextField!

    // MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavBar()
    }

    // MARK: - Private Helpers

    private func setupNavBar() {
        title = navTitle

        let doneAction = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTapped))
        let cancelAction = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        navigationItem.leftBarButtonItem = cancelAction
        navigationItem.rightBarButtonItem = doneAction
    }

    @objc private func doneTapped() {
        // (43.61871, -116.214607)
        if let latitudeValue = Double(latitudeTextField.text ?? ""),
           let longitudeValue = Double(longitudeTextField.text ?? "") {
            UserDefaults.standard.setValue(latitudeValue, forKey: "lat")
            UserDefaults.standard.setValue(longitudeValue, forKey: "long")
            dismiss(animated: true, completion: nil)
        } else {
            print("Please add correct locations")
            latitudeTextField.text = ""
            longitudeTextField.text = ""
        }
    }

    @objc private func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }

}
