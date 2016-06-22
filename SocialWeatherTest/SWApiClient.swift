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
    
    static func login(key: String, callback: (Result<AnyObject>) -> (Void)) {
        Alamofire.request(.POST, BASE_URL + "/user/login", parameters: ["key": key])
            .responseJSON { _, _, result in
                callback(result)
        }
    }
    
    static func uploadImage(token: String, image: NSData, lat: Double, lon: Double, weather_type: CGFloat, callback: (Result<AnyObject>) -> (Void)) {
        let headers = [
            "X-SW-USER-KEY": token
        ]
        
        let parameters = [
            "lat": lat,
            "lon": lon,
            "weather_type": weather_type
        ]
        
        Alamofire.upload(.POST, BASE_URL + "/posts/post", headers: headers, multipartFormData: {
            multipartFormData in
            
            multipartFormData.appendBodyPart(data: image, name: "image", fileName: "image.jpg", mimeType: "image/jpeg")
            
            for (key, value) in parameters {
                multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key as! String)
            }
            
        }, encodingCompletion: {
            encodingResult in
            
            switch encodingResult {
            case .Success(let upload, _, _):
                upload.responseJSON { _, _, result in
                    callback(result)
                }
                break
            case .Failure(let encodingError):
                print(encodingError)
                break
            }
        })
    }
}

