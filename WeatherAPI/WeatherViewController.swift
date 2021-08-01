//
//  WeatherViewController.swift
//  WeatherAPI
//
//  Created by 大江祥太郎 on 2021/07/31.
//

import UIKit

class WeatherViewController: UIViewController , UITextFieldDelegate{

    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temparatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    var weatherManager = WeatherManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchTextField.delegate = self
    }
    
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
