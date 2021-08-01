//
//  WeatherViewController.swift
//  WeatherAPI
//
//  Created by 大江祥太郎 on 2021/07/31.
//

import UIKit
import CoreLocation

/*
 UITextFieldDelegateはextensionで中身は既に書かれていて、無くてもいいがoverrideしたときにその威力を発揮する。
 */

class WeatherViewController: UIViewController{

    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temparatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        

        searchTextField.delegate = self
        weatherManager.delegate = self
        
    }
    
    @IBAction func locationPressed(_ sender: UIButton) {
        //初期化
        locationManager.requestLocation()
    }
    
}

//MARK: - UITextFieldDelegate

extension WeatherViewController:UITextFieldDelegate{
    @IBAction func searchPressed(_ sender: UIButton) {
        print(searchTextField.text!)
    }
    
    //returnを押した時の処理
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //キーボードを閉じる処理
        searchTextField.endEditing(true)
        return true
    }
    
    /*
     textFieldShouldReturn before responder と textFieldShouldReturn の間にtextFieldShouldEndEditing, textFieldDidEndEditingが来ているので、resignFirstResponder()内でtextFieldShouldEndEditing, textFieldDidEndEditingが呼ばれているようです
     
     上のメソッドからこのメソッドでのshouldreturnが呼ばれている。

     */
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        }else{
            textField.placeholder = "Try something"
            return false
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let city = searchTextField.text{
            weatherManager.fetchWeather(cityName: city)
        }
        
        searchTextField.text = ""
    }
    
}

//MARK: - WeatherManagerDelegate

extension WeatherViewController:WeatherManagerDelegate{
    
    func didUpdateWeather(_ weatherManager:WeatherManager,weather:WeatherModel){
        // print(weather.temperature)
        DispatchQueue.main.async {
            self.temparatureLabel.text = weather.temperatureString
            self.conditionImageView.image = UIImage(systemName: weather.conditinName)
            self.cityLabel.text = weather.cityName
        }
    }
    func didFailWithError(error: Error) {
        print(error)
    }
}

//MARK: - CLLocationManagerDelegate

extension WeatherViewController:CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            print(lat)
            print(lon)
            weatherManager.fetchWeather(latitude:lat,longitude:lon)
 
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        
    }
}
