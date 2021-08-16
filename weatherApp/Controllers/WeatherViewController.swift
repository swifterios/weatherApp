//
//  WeatherViewController.swift
//  weatherApp
//
//  Created by Владислав on 13.08.2021.
//

import UIKit

class WeatherViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getWeather()
    }


    func getWeather() {
        NetworkManager.shared.getWeather { [weak self] result in
            switch result {
            case .success(let model):
                print(model)
            case .failure(let error):
                print(error)
            }
        }
    }
}

