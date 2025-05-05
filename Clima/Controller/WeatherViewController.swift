//
//  ViewController.swift
//  Clima
//
//  Created by Angela Yu on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        // This means that the text field will report back to this view controller (self, this object) when the user presses return
        searchTextField.delegate = self
        weatherManager.delegate = self
        
    }
    
    @IBAction func locationPressed(_ sender: UIButton) {
        locationManager.requestLocation()
    }
}

// MARK: - UITextFieldDelegate
extension WeatherViewController: UITextFieldDelegate {
    @IBAction func searchPressed(_ sender: UIButton) {
        searchTextField.endEditing(true)
    }
    
    // User pressed return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        return true
    }
    
    // This method is called when the user deselects the text field
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "Type something"
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Use searchTextField.text to get the weather data for that city
        if let city = searchTextField.text {
            weatherManager.fetchWeather(cityName: city)
            
        }
        
        searchTextField.text = ""
    }
    
}

// MARK: - WeatherManagerDelegate
extension WeatherViewController: WeatherManagerDelegate {
    
    // This method is called from inside the CompletionHandler in WeatherManager, but that method might be slow and we don't want to block the main thread
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        // Before updating the didUpdateWeather method is called, the WeatherManager must finish its task.
        // But in case the WeatherManager is slow, temperatureLabel has nothing to show.
        // That is the reason we need to use DispatchQueue.main.async, to ensure that the UI updates happen on the main thread, without waiting for the WeatherManager to finish its task.
        DispatchQueue.main.async {
            self.temperatureLabel.text = weather.temperatureString
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
            self.cityLabel.text = weather.cityName
        }
    }
    
    func didFailWithError(error: any Error) {
        print(error)
    }
}

// MARK: - CLLocationManagerDelegate
extension WeatherViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            // Stop updating location, so every time the location button is pressed, it will call the locationManager(_:didUpdateLocations:) method again
            // Ìf we don't stop updating location, the app will keep calling this method and it will be a waste of resources
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            debugPrint("lat: \(lat), lon: \(lon)")
            weatherManager.fetchWeather(latitude: lat, longitude: lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugPrint("Failed to find user's location: \(error.localizedDescription)")
    }
    
}
