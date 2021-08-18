//
//  Weather.swift
//  weatherApp
//
//  Created by Владислав on 16.08.2021.
//

import Foundation

struct Weather: Codable {
    let now: Int?
    let now_dt: String?
    let info: Info?
    let geo_object: GeoObject?
    let fact: Fact?
    let forecasts: [Forecasts]?
}

struct Info: Codable {
    let lat: Int?
    let lon: Int?
    let tzinfo: TzInfo?
}

struct TzInfo: Codable {
    let name: String?
}

struct GeoObject: Codable {
    let locality: Locality?
    let province: Province?
    let country: Country?
}

struct Locality: Codable {
    let name: String?
}

struct Province: Codable {
    let name: String?
}

struct Country: Codable {
    let name: String?
}

struct Fact: Codable {
    let temp: Int?
    let feels_like: Int?
    let icon: String?
    let condition: String?
    let cloudness: Int?
    let wind_speed: Double?
    let pressure_mm: Int?
    let pressure_pa: Int?
    let humidity: Int?
    let daytime: String?
}

struct Forecasts: Codable {
    let date: String?
    let sunrise: String?
    let sunset: String?
    let hours: [Hours]?
    let parts: Parts?
}

struct Hours: Codable {
    let hour: String?
    let temp: Int?
    let feels_like: Int?
    let condition: String?
    let wind_speed: Double?
}

struct Parts: Codable {
    let day: DayPart?
    let night: DayPart?
}

struct DayPart: Codable {
    let temp_min: Int?
    let temp_avg: Int?
    let temp_max: Int?
    let condition: String?
    let pressure_mm: Int?
    let wind_speed: Double?
    let feels_like: Int?
    let prec_mm: Int?
    let humidity: Int?
}
