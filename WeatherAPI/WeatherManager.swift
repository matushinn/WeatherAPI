//
//  WeatherManager.swift
//  WeatherAPI
//
//  Created by 大江祥太郎 on 2021/08/01.
//

/*
 JSON(JavaScript Object Notation)
 
 */

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager:WeatherManager,weather:WeatherModel)
    func didFailWithError(error:Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=55d5a00b25be13205e67198e90a898d6&units=metric"
    
    var delegate:WeatherManagerDelegate?
    
    func fetchWeather(cityName:String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        // print(urlString)
        
        self.performRequest(with: urlString)
    }
    
    func fetchWeather(latitude:CLLocationDegrees,longitude:CLLocationDegrees){
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        self.performRequest(with: urlString)
        
    }
    func performRequest(with urlString:String){
        //①Create a URL
        if let url = URL(string: urlString){
            //②Create a URL Session
            let session = URLSession(configuration: .default)
            
            //③Give the sessin Task
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    // print(error!)
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                
                if let safeData = data {
//                    let dataString = String(data:safeData,encoding:.utf8)
//                    // print(dataString)
                    if let weather = self.parseJSON(safeData){
                        self.delegate?.didUpdateWeather(self, weather: weather)
//                        let weatherVC = WeatherViewController()
//                        weatherVC.didUpdateWeather(weather: weather)
//
                    }
                    
                }
            }
            
            //④Start the task
            task.resume()
        }
        
    }
    func parseJSON(_ weatherData:Data) -> WeatherModel?{
        
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            // print(decodedData.weather[0].description)
            let id = decodedData.weather[0].id
            // getConditionName(weatherId: id)
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            
            return weather
            //print(weather.conditinName)
            
            
            
        } catch  {
            delegate?.didFailWithError(error: error)
            
            return nil
        }
       
        
    }
    
    
    
    /*
    func handle(data:Data?,response:URLResponse?,error:Error?){
        if error != nil {
            print(error!)
            return
        }
        
        if let safeData = data {
            let dataString = String(data:safeData,encoding:.utf8)
            // print(dataString)
            
        }
    }
 */
}
