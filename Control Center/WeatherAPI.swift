//
//  WeatherAPI.swift
//  Control Center
//
//  Created by MinhTon on 7/9/20.
//  Copyright © 2020 MinhTon. All rights reserved.
//

import Foundation
import Cocoa

struct Weather: CustomStringConvertible {
    var city: String
    var currentTemp: Double
    var conditions: String
    var icon: String
    var feels_like: NSNumber
    var pressure: Int
    var humidity: Int
    
    var description: String {
        return "\(city) \(currentTemp) \(conditions) \(icon) \(feels_like) \(pressure) \(humidity)"
    }
}

protocol WeatherAPIDelegate {
    func weatherDidUpdate(_ weather: Weather)
}

class WeatherAPI {
    var delegate: WeatherAPIDelegate?

    init(delegate: WeatherAPIDelegate) {
        self.delegate = delegate
    }
    
    func fetchWeather(_ query: String, success: @escaping (Weather) -> Void) {
        let session = URLSession.shared
        // url-escape the query string we're passed
        let escapedQuery = query.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        let formatter = MeasurementFormatter()
        let Temperature = Measurement(value: 0, unit: UnitTemperature.celsius)
        let tempUnit = formatter.string(from: Temperature).last
        
        let API_KEY = weatherAPIKey()
        
        var unit = ""
        
        if tempUnit == "C" {
             unit = "metric"
        } else {
            unit = "imperial"
        }
        
        let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?q=\(escapedQuery!)&units=\(unit)&appid=\(API_KEY)")
        
        let task = session.dataTask(with: url!) { data, response, err in
            // first check for a hard error
            if let error = err {
                NSLog("weather api error: \(error)")
            }

            // then check the response code
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200: // all good!
                    if let weather = self.weatherFromJSONData(data!) {
                        success(weather)
                    }
                case 401: // unauthorized
                    NSLog("weather api returned an 'unauthorized' response. Did you set your API key?")
                default:
                    NSLog("weather api returned response: %d %@", httpResponse.statusCode, HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))
                }
            }
        }
        task.resume()
    }
    
    func weatherFromJSONData(_ data: Data) -> Weather? {
        typealias JSONDict = [String:AnyObject]
        let json : JSONDict

        do {
            json = try JSONSerialization.jsonObject(with: data, options: []) as! JSONDict
        } catch {
            NSLog("JSON parsing failed: \(error)")
            return nil
        }

        let mainDict = json["main"] as! JSONDict
        let weatherList = json["weather"] as! [JSONDict]
        let weatherDict = weatherList[0]

        let weather = Weather(
            city: json["name"] as! String,
            currentTemp: mainDict["temp"] as! Double,
            conditions: weatherDict["main"] as! String,
            icon: weatherDict["icon"] as! String,
            feels_like: mainDict["feels_like"] as! NSNumber,
            pressure: mainDict["pressure"] as! Int,
            humidity: mainDict["humidity"] as! Int
        )

        return weather
    }
}
