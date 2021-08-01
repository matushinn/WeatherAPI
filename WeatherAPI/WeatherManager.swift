//
//  WeatherManager.swift
//  WeatherAPI
//
//  Created by 大江祥太郎 on 2021/08/01.
//

import Foundation

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=55d5a00b25be13205e67198e90a898d6&units=metric"
    
    func fetchWeather(cityName:String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        print(urlString)
        
        performRequest(urlString: urlString)
    }
    
    func performRequest(urlString:String){
        //①Create a URL
        if let url = URL(string: urlString){
            //②Create a URL Session
            let session = URLSession(configuration: .default)
            
            //③Give the sessin Task
            let task = session.dataTask(with: url, completionHandler: handle(data:response:error:))
            
            //④Start the task
            task.resume()
        }
        
    }
    
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
}
