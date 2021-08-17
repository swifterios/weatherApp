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
                self?.updateHoursLabels()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    //MARK: - Update UI
    
    func updateHoursLabels() {
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
            
            for index in 0...23 {

                if currentHour >= 22 {
                    currentHour = 0
                    currentDay += 1
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
                var weather = weatherData.forecasts![currentDay].hours![currentHour].condition
                
                switch weather {
                
                case "clear":
                    self.weatherImages[index].image = UIImage(systemName: "sun.max.fill")
                case "partly-cloudy":
                    self.weatherImages[index].image = UIImage(systemName: "cloud.sun.fill")
                case "cloudy":
                    self.weatherImages[index].image = UIImage(systemName: "cloud.sun.fill")
                case "overcast":
                    self.weatherImages[index].image = UIImage(systemName: "smoke.fill")
                case "drizzle":
                    self.weatherImages[index].image = UIImage(systemName: "cloud.rain.fill")
                case "light-rain":
                    self.weatherImages[index].image = UIImage(systemName: "cloud.rain.fill")
                case "rain":
                    self.weatherImages[index].image = UIImage(systemName: "cloud.rain.fill")
                case "moderate-rain":
                    self.weatherImages[index].image = UIImage(systemName: "cloud.rain.fill")
                case "heavy-rain":
                    self.weatherImages[index].image = UIImage(systemName: "cloud.heavyrain.fill")
                case "continuous-heavy-rain":
                    self.weatherImages[index].image = UIImage(systemName: "cloud.heavyrain.fill")
                case "showers":
                    self.weatherImages[index].image = UIImage(systemName: "cloud.heavyrain.fill")
                case "wet-snow":
                    self.weatherImages[index].image = UIImage(systemName: "cloud.snow.fill")
                case "light-snow":
                    self.weatherImages[index].image = UIImage(systemName: "cloud.snow.fill")
                case "snow":
                    self.weatherImages[index].image = UIImage(systemName: "cloud.snow.fill")
                case "snow-showers":
                    self.weatherImages[index].image = UIImage(systemName: "cloud.snow.fill")
                case "hail":
                    self.weatherImages[index].image = UIImage(systemName: "cloud.hail.fill")
                case "thunderstorm":
                    self.weatherImages[index].image = UIImage(systemName: "cloud.bolt.rain.fill")
                case "thunderstorm-with-rain":
                    self.weatherImages[index].image = UIImage(systemName: "cloud.bolt.rain.fill")
                case "thunderstorm-with-hail":
                    self.weatherImages[index].image = UIImage(systemName: "cloud.bolt.rain.fill")
                default:
                    self.weatherImages[index].image = UIImage(systemName: "sun.max.fill")
                }
                currentHour += 1
                
            }
        }
    }
}

