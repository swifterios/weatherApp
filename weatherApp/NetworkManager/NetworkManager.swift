//
//  NetworkManager.swift
//  weatherApp
//
//  Created by Владислав on 13.08.2021.
//

import Foundation

final class NetworkManager {
    
    static let shared = NetworkManager()
    
    struct Constants {
        static let host = "api.weather.yandex.ru"
        static let apiPath = "/v2/forecast"
        static let apiKey = "0dd40c8c-ec22-48fa-843a-f0bbad027cb2"
    }
    
    public func getWeather(lat: String, lon: String, completion: @escaping (Result<Weather, Error>) -> Void) {
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = Constants.host
        urlComponents.path = Constants.apiPath
        urlComponents.queryItems = [URLQueryItem(name: "lat", value: lat),
                                    URLQueryItem(name: "lon", value: lon),
                                    URLQueryItem(name: "lang", value: "ru_RU"),
                                    URLQueryItem(name: "extra", value: "true"),
                                    URLQueryItem(name: "limit", value: "7")]
        
        guard let reqUrl = urlComponents.url else {
            return
        }
        
        var request = URLRequest(url: reqUrl)
        request.httpMethod = "GET"
        request.addValue(Constants.apiKey, forHTTPHeaderField: "X-Yandex-API-Key")
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                let result = try JSONDecoder().decode(Weather.self, from: data)
                completion(.success(result))
            }
            catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
