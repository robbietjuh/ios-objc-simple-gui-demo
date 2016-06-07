//
//  OWMApiClient.swift
//  SocialWeatherTest
//
//  Created by R. de Vries on 07-06-16.
//  Copyright © 2016 R. de Vries. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftOpenWeatherMapAPI
import SwiftyJSON

class OWMApiClient {
    static let client = WAPIManager(apiKey: "cbaa784c51417480a69b93a134c50c48")
    
    static func currentWeatherByCoordinates(coordinates: CLLocationCoordinate2D, success: (String, Int) -> Void, error: (String) -> Void) {
        self.client.language = .English
        self.client.temperatureFormat = .Celsius
        
        self.client.currentWeatherByCoordinatesAsJson(coordinates) { (result: WeatherResult) in
            switch result {
                case .Success(let json):
                    let name = json["name"].stringValue
                    let temp = json["main"]["temp"].intValue
                
                    success(name, temp)
                    break
                case .Error(let errorMessage):
                    error(errorMessage)
                    break
            }
        }
    }
}