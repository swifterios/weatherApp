//
//  Extensions.swift
//  weatherApp
//
//  Created by Владислав on 18.08.2021.
//

import Foundation

extension String {
    func capitalizingFirstLetter() -> String {
      return prefix(1).uppercased() + self.lowercased().dropFirst()
    }

    mutating func capitalizeFirstLetter() {
      self = self.capitalizingFirstLetter()
    }
    
    func removeMinus() -> String {
        return self.replacingOccurrences(of: "_", with: "")
    }
    
    mutating func removeMinus() {
      self = self.removeMinus()
    }
}
