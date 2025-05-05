//
//  WeatherManager.swift
//  Clima
//
//  Created by VuNA on 4/5/25.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

// By convention, the delegate protocol is declared in the same file as the class it is associated with
// Later, the ViewController will conform to this protocol to receive updates from the WeatherManager to get the notification and update the UI
protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?units=metric&appid=2589467362ea5a48103f96d8c10b5b97"
    
    // Delegate property will be set by other classes (like ViewController) to receive updates
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        debugPrint(urlString)
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        debugPrint(urlString)
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        // 1. Create a URL
        if let url = URL(string: urlString) {
            // 2. Create a URLSession
            let session = URLSession(configuration: .default)
            // 3. Give the session a task
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        // this call to delegate is made so the WeatherViewController (or any other class conforming to the protocol) will run the function didUpdateWeather
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            // 4. Start the task
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let name = decodedData.name
            let main = decodedData.main.temp
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: main)
            debugPrint(weather.conditionName)
            debugPrint(weather.temperatureString)

            return weather
        } catch {
            self.delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}
