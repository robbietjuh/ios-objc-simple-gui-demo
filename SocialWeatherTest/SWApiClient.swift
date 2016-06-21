//
//  SWApiClient.swift
//  SocialWeatherTest
//
//  Created by R. de Vries on 21-06-16.
//  Copyright © 2016 R. de Vries. All rights reserved.
//

//import Foundation
import Alamofire

class SWApiClient {
    static let BASE_URL = ""
    
    static func register(email: String, callback: (Result<AnyObject>) -> (Void)) {
        Alamofire.request(.POST, BASE_URL + "/user/register", parameters: ["email": email])
            .responseJSON { _, _, result in
                callback(result)
        }
    }
}

