//
//  WeatherViewController.swift
//  weatherApp
//
//  Created by Владислав on 13.08.2021.
//

import UIKit

class WeatherViewController: UIViewController {
    
    var weatherData: Weather?
    
    //MARK: - Outlets
    
    @IBOutlet var hoursLabels: [UILabel]!
    @IBOutlet var weatherImages: [UIImageView]!
    @IBOutlet var tempLabels: [UILabel]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getWeather()
    }

    //MARK: - Using api
    
    func getWeather() {
        NetworkManager.shared.getWeather { [weak self] result in
            switch result {
            case .success(let model):
                self?.weatherData = model
                self?.updateHoursHourWeather()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    //MARK: - Update UI
    
    func updateHoursHourWeather() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            
            guard let weatherData = self.weatherData else {
                return
            }
            
            let calendar = Calendar.current
            
            var currentHour: Int = {
                let currentHour = calendar.component(.hour, from: Date())
                return currentHour
            }()
            var currentDay = 0
            
            guard var sunrise = weatherData.forecasts![currentDay].sunrise else {
                return
            }
            
            guard var sunset = weatherData.forecasts![currentDay].sunset else {
                return
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            
            var skip = false
            
            for var index in 0...23 {

                if skip {
                    skip = false
                    continue
                }
                
                let sunriseDate = dateFormatter.date(from: sunrise)
                let sunriseHour = calendar.component(.hour, from: sunriseDate!)
                
                let sunsetDate = dateFormatter.date(from: sunset)
                let sunsetHour = calendar.component(.hour, from: sunsetDate!)
                
                if currentHour >= 24 {
                    print(currentHour)
                    currentHour = 0
                    currentDay += 1
                    sunrise = weatherData.forecasts![currentDay].sunrise!
                    sunset = weatherData.forecasts![currentDay].sunset!
                }
                
                guard let temp = weatherData.forecasts![currentDay].hours![currentHour].temp else {
                    return
                }
                    
                self.hoursLabels[index].text = weatherData.forecasts![currentDay].hours![currentHour].hour
                self.tempLabels[index].text = String(temp)
                
                if index == 0 {
                    self.hoursLabels[index].text = "Сейчас"
                }
                
                // Update image
                let weather = weatherData.forecasts![currentDay].hours![currentHour].condition
                
                switch weather {
                case "clear":
                    self.weatherImages[index].image = UIImage(systemName: "sun.max.fill")
                case "partly-cloudy", "cloudy":
                    self.weatherImages[index].image = UIImage(systemName: "cloud.sun.fill")
                case "overcast":
                    self.weatherImages[index].image = UIImage(systemName: "smoke.fill")
                case "drizzle", "light-rain", "rain", "moderate-rain":
                    self.weatherImages[index].image = UIImage(systemName: "cloud.rain.fill")
                case "heavy-rain", "continuous-heavy-rain", "showers":
                    self.weatherImages[index].image = UIImage(systemName: "cloud.heavyrain.fill")
                case "wet-snow", "light-snow", "snow", "snow-showers":
                    self.weatherImages[index].image = UIImage(systemName: "cloud.snow.fill")
                case "hail":
                    self.weatherImages[index].image = UIImage(systemName: "cloud.hail.fill")
                case "thunderstorm", "thunderstorm-with-rain", "thunderstorm-with-hail":
                    self.weatherImages[index].image = UIImage(systemName: "cloud.bolt.rain.fill")
                default:
                    self.weatherImages[index].image = UIImage(systemName: "sun.max.fill")
                }
                
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
                    
                    self.hoursLabels[next].translatesAutoresizingMaskIntoConstraints = false
                    
                    skip = true
                }
                currentHour += 1
            }
        }
    }
}

