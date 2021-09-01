# Weather

SwiftでOpenWeatherAPIを使って天気予報アプリを作ってみたいと思います。
初心者にもわかりやすく、AutoLayoutの設定、デザインパターン、コードの可読性もしっかり守っているので、APIの入門記事としてはぴったりかなと。
では始めていきます。ぜひ最後までご覧ください。

## UIの設計
まずこのアプリでは以下の画像を使ったので[ここ](![background.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/325764/366fc02a-f70d-4542-a0bd-6ea8aeb79805.jpeg))からダウンロードしてください。
このように配置していきます。
![スクリーンショット 2021-08-31 11.39.52.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/325764/3f15fe2b-7c19-b511-02fe-99a6933a86ce.png)

制約をつけていきます。
![seiyaku.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/325764/06ef3174-8fbe-a2d1-1f01-c9f2c96ad484.png)

WeatherViewControllerを作り、IBOutlet,IBAction接続します。
![スクリーンショット 2021-08-31 12.54.39.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/325764/d475a82a-3650-4921-5131-e5f9043814b0.png)

```swift:WeatherViewController.swift
class WeatherViewController: UIViewController{

    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temparatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func searchPressed(_ sender: UIButton) {
    }
}
```

## 全体設計
UIができた後に、今回のアプリの設計を行なっていく。
![スクリーンショット 2021-09-01 13.44.41.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/325764/c935da6e-65f1-3e8d-061b-1f25df2960f2.png)

![スクリーンショット 2021-09-01 13.59.13.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/325764/7d613567-772b-f9c3-ef01-03b53243513d.png)

## APIの取得
まず、APIの取得からやっていきたいと思います。
[OpenWeatherAPI](https://openweathermap.org/api)を使います。
こちらでサインインして、APIKeyを取得します。
今回はCurrentWeatherDataを使います。
![スクリーンショット 2021-09-01 14.20.15.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/325764/6c328ed0-e3b2-f8f2-a348-7e6e86472409.png)

こちらでこのようにAPIを叩くと、JSONデータを変換してくれます。
![スクリーンショット 2021-09-01 14.19.28.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/325764/6ab3f236-4dd1-c0a6-0a8b-1c7627f1db57.png)
これらのデータをうまく使い今回はアプリを作成していきます。


## WeatherManager
今回のAPIにおいてのロジックを管理するWeatherManagerを書いていきます。

```swift:WeatherViewController.swift
import Foundation

//UI更新のためのプロトコル
protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    //[APIKey]には自分のAPIKeyをかく
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=[APIKey]&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        func performRequest(with urlString:String){
        //①URL型に変換
        if let url = URL(string: urlString){
            //②URLSessionを作る
            let session = URLSession(configuration: .default)
            
            //③Session taskを与える
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = self.parseJSON(safeData){
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            //④タスクが始まる
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            //JSONを変換
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
　　　　　　　　　　　　　　　　　　　　　　　　//データをアプリで使いやすいようにまとめる
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}


```

## WeatherModel
データをアプリが使いやすいような形に変換するためのWeatherModelを作成していきます。

```swift:WeatherModel.swift
import Foundation

struct WeatherModel {
    let conditionId:Int
    let cityName:String
    let temperature:Double
    
    var temperatureString:String {
        return String(format: "%.1f",temperature)
    }
    
    var conditinName:String{
        switch conditionId {
        case 200...232:
            return "cloud.bolt"
        case 300...321:
            return "cloud.drizzle"
        case 500...531:
            return "cloud-rain"
        case 600...622:
            return "cloud-snow"
        case 701...781:
            return "cloud-fog"
        case 800:
            return "sun.max"
        case 801...804:
            return "cloud.bolt"
        default:
            return "cloud"
        }
    }
}

```

## WeatherData
レスポンスしたデータをデコードするためWeatherDataを作ります。

```swift:WeatherData.swift
import Foundation

//Codable = Decodable & Encodable
struct WeatherData : Codable{
    let name:String
    let main:Main
    let weather:[Weather]
}

struct Main:Codable {
    let temp:Double
}

struct Weather:Codable {
    let description:String
    let id:Int
}

```

## WeatherViewController
最後に取得したデータをViewに反映させる、またTableViewの操作のためにWeatherViewControllerを作っていきます。

```swift:WeatherViewController
import UIKit

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    var weatherManager = WeatherManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weatherManager.delegate = self
        searchTextField.delegate = self
    }

}

//MARK: - UITextFieldDelegate
extension WeatherViewController: UITextFieldDelegate {
    
    @IBAction func searchPressed(_ sender: UIButton) {
        searchTextField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "何か入力してください"
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if let city = searchTextField.text {
            weatherManager.fetchWeather(cityName: city)
        }
        
        searchTextField.text = ""
        
    }
}

//MARK: - WeatherManagerDelegate

extension WeatherViewController: WeatherManagerDelegate {
    
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            //ここでUIの更新
            self.temperatureLabel.text = weather.temperatureString
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
            self.cityLabel.text = weather.cityName
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}
```
UITextFieldの処理は[UITextField](https://developer.apple.com/documentation/uikit/uitextfield)のドキュメントを確認しながら学んでください。

## 終わりに
以上でこのようなアプリが作成できました。
![Animated GIF-downsized_large (4)](https://user-images.githubusercontent.com/44314610/129537899-c8e2d075-96fb-43d0-b849-de01622e9884.gif)

