//
//  WeatherViewController.swift
//  weatherApp
//
//  Created by Владислав on 13.08.2021.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController, CLLocationManagerDelegate {
    
    var weatherData: Weather?
    let manager = CLLocationManager()
    
    //MARK: - Outlets
    
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var currentWeatherLabel: UILabel!
    @IBOutlet weak var currentTemp: UILabel!
    
    @IBOutlet var hoursLabels: [UILabel]!
    @IBOutlet var weatherImages: [UIImageView]!
    @IBOutlet var tempLabels: [UILabel]!
    
    @IBOutlet var daysLabels: [UILabel]!
    @IBOutlet var daysWeather: [UIImageView]!
    @IBOutlet var daysDayTemp: [UILabel]!
    @IBOutlet var daysNightTemp: [UILabel]!
    
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var feelLikeLabel: UILabel!
    @IBOutlet weak var fallLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    //MARK: - Using api
    
    func getWeather(lat: String, lon: String) {
        NetworkManager.shared.getWeather(lat: lat, lon: lon) { [weak self] result in
            switch result {
            case .success(let model):
                self?.weatherData = model
                self?.updateUI()
                self?.saveDataToUserDefaults(weatherData: model)
            case .failure(let error):
                print(error)
                self?.updateWithUserDefaults()
            }
        }
    }
    
    
    //MARK: - Update UI
    
    func updateUI() {
        self.updateMainInfo()
        self.updateHoursHourWeather()
        self.updateWeatherByDay()
        self.updateInfoDay()
    }
    
    func updateMainInfo() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            
            guard let weatherData = self.weatherData,
                  let geoObject = weatherData.geo_object,
                  let country = geoObject.country,
                  let province = geoObject.province,
                  let countryName = country.name,
                  let provinceName = province.name,
                  let fact = weatherData.fact,
                  let condition = fact.condition,
                  let factTemp = fact.temp
                  else {
                return
            }
            
            self.countryLabel.text = String(countryName) + ", " + String(provinceName)
            self.currentWeatherLabel.text = self.getWeatherName(weatherName: condition)
            self.currentTemp.text = String(factTemp) + "°"
        }
    }
    
    func updateHoursHourWeather() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            
            guard let weatherData = self.weatherData,
                  let forecasts = weatherData.forecasts
                  else {
                return
            }
            
            let calendar = Calendar.current
            
            var currentHour: Int = {
                let currentHour = calendar.component(.hour, from: Date())
                return currentHour
            }()
            var currentDay = 0
            
            guard var sunrise = forecasts[currentDay].sunrise else {
                return
            }
            
            guard var sunset = forecasts[currentDay].sunset else {
                return
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            
            var skip = false
            
            for index in 0...25 {

                if skip {
                    skip = false
                    continue
                }
                
                let sunriseDate = dateFormatter.date(from: sunrise)
                let sunriseHour = calendar.component(.hour, from: sunriseDate!)
                
                let sunsetDate = dateFormatter.date(from: sunset)
                let sunsetHour = calendar.component(.hour, from: sunsetDate!)
                
                if currentHour >= 24 {
                    currentHour = 0
                    currentDay += 1
                    sunrise = forecasts[currentDay].sunrise!
                    sunset = forecasts[currentDay].sunset!
                }
                
                guard let hours = forecasts[currentDay].hours,
                    let temp = hours[currentHour].temp else {
                    return
                }
                    
                self.hoursLabels[index].text = hours[currentHour].hour
                self.tempLabels[index].text = String(temp) + "°"
                
                if index == 0 {
                    self.hoursLabels[index].text = "Сейчас"
                }
                
                // Update image
                guard let weather = hours[currentHour].condition else {
                    return
                }
                
                self.weatherImages[index].image = self.getImageByWeather(weatherName: weather)
                
                
                if currentHour == sunriseHour {
                    let next = index + 1
                    self.hoursLabels[next].text = sunrise
                    self.weatherImages[next].image = UIImage(systemName: "sunrise.fill")
                    self.tempLabels[next].text = "Восход солнца"
                    skip = true
                }
                
                if currentHour == sunsetHour {
                    let next = index + 1
                    self.hoursLabels[next].text = sunset
                    self.weatherImages[next].image = UIImage(systemName: "sunset.fill")
                    self.tempLabels[next].text = "Заход солнца"
                    skip = true
                }
                currentHour += 1
            }
        }
    }
    
    
    func updateWeatherByDay() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            
            guard let weatherData = self.weatherData,
                  let forecasts = weatherData.forecasts else {
                return
            }
            

            for index in 0...6 {
                // Update day
                
                guard let parts = forecasts[index].parts,
                      let partsDay = parts.day,
                      let partsNight = parts.night else {
                    return
                }
                
                let dateString = weatherData.forecasts![index].date
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "ru_RU")
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let date = dateFormatter.date(from: dateString!)
                dateFormatter.dateFormat = "EEEE"
                
                let day = dateFormatter.string(from: date!).capitalizingFirstLetter()
                
                self.daysLabels[index].text = day
                
                // Update temp
                
                self.daysDayTemp[index].text = String(partsDay.temp_avg!) + "°"
                self.daysNightTemp[index].text = String(partsNight.temp_avg!) + "°"
                
                // Update weather image
                
                guard let weather = partsDay.condition else {
                    return
                }
                
                self.daysWeather[index].image = self.getImageByWeather(weatherName: weather)
            }
        }
    }
    
    func updateInfoDay() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            
            guard let weatherData = self.weatherData,
                  let forecasts = weatherData.forecasts,
                  let parts = forecasts[0].parts,
                  let partsDay = parts.day,
                  let fact = weatherData.fact else {
                return
            }
            
            self.sunriseLabel.text = forecasts[0].sunrise
            self.sunsetLabel.text = forecasts[0].sunset
            self.humidityLabel.text = String(fact.humidity!) + "%"
            self.windSpeedLabel.text = String(fact.wind_speed!) + " м/c"
            self.feelLikeLabel.text = String(fact.feels_like!) + "°"
            self.fallLabel.text = String(partsDay.prec_mm!) + " мм"
            self.pressureLabel.text = String(fact.pressure_mm!) + " мм рт.ст"
        }
    }
    
    func getImageByWeather(weatherName: String) -> UIImage {
        switch weatherName {
        case "clear":
            return UIImage(systemName: "sun.max.fill")!
        case "partly-cloudy", "cloudy":
            return UIImage(systemName: "cloud.sun.fill")!
        case "overcast":
            return UIImage(systemName: "smoke.fill")!
        case "drizzle", "light-rain", "rain", "moderate-rain":
            return UIImage(systemName: "cloud.rain.fill")!
        case "heavy-rain", "continuous-heavy-rain", "showers":
            return UIImage(systemName: "cloud.heavyrain.fill")!
        case "wet-snow", "light-snow", "snow", "snow-showers":
            return UIImage(systemName: "cloud.snow.fill")!
        case "hail":
            return UIImage(systemName: "cloud.hail.fill")!
        case "thunderstorm", "thunderstorm-with-rain", "thunderstorm-with-hail":
            return UIImage(systemName: "cloud.bolt.rain.fill")!
        default:
            return UIImage(systemName: "sun.max.fill")!
        }
    }
    
    func getWeatherName(weatherName: String) -> String {
        switch weatherName {
        case "clear":
            return "Ясно"
        case "partly-cloudy":
            return "Малооблачно"
        case "cloudy":
            return "Облачно с прояснениями"
        case "overcast":
            return "Пасмурно"
        case "drizzle":
            return "Морось"
        case "light-rain":
            return "Небольшой дождь"
        case "rain":
            return "Дождь"
        case "moderate-rain":
            return "Умеренно сильный дождь"
        case "heavy-rain":
            return "Сильный дождь"
        case "continuous-heavy-rain":
            return "Длительно сильный дождь"
        case "showers":
            return "Ливень"
        case "wet-snow":
            return "Дождь со снегом"
        case "light-snow":
            return "Небольшой снег"
        case "snow":
            return "Снег"
        case "snow-showers":
            return "Снегопад"
        case "hail":
            return "Град"
        case "thunderstorm":
            return "Гроза"
        case "thunderstorm-with-rain":
            return "Дождь с грозой"
        case "thunderstorm-with-hail":
            return "Гроза с градом"
        default:
            return ""
        }
    }
    
    
    //MARK: - UserDefaults
    
    func saveDataToUserDefaults(weatherData: Weather) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(weatherData)

            UserDefaults.standard.set(data, forKey: "weatherData")
        } catch {
            print("Cant encode: (\(error))")
        }
    }
    
    func getDataFromUserDefaults(key: String) -> Weather? {
        if let data = UserDefaults.standard.data(forKey: key) {
            do {
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode(Weather.self, from: data)
                return decodedData
            }
            catch {
                print("Cant decode: \(error)")
            }
        }
        return nil
    }
    
    func updateWithUserDefaults() {
        guard let data = getDataFromUserDefaults(key: "weatherData") else {
            return
        }
        
        weatherData = data
        
        updateUI()
    }
    
    
    //MARK: - Location
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            
            let latitude = String(format: "%f", location.coordinate.latitude)
            let longitude = String(format: "%f", location.coordinate.longitude)
            
            manager.stopUpdatingLocation()
            
            getWeather(lat: latitude, lon: longitude)
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location")
        
        updateWithUserDefaults()
    }
}

