//
//  WeatherManager.swift
//  Clima
//
//  Created by VuNA on 4/5/25.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import Foundation

struct WeatherManager {
    let weatherURL = "http://api.openweathermap.org/data/2.5/weather?units=metric&appid=2589467362ea5a48103f96d8c10b5b97"
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        print(urlString)
        // performRequest(urlString: urlString)
    }
}
