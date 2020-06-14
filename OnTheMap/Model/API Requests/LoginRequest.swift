//
//  LoginRequest.swift
//  OnTheMap
//
//  Created by Garima Bothra on 25/05/20.
//  Copyright © 2020 Garima Bothra. All rights reserved.
//

import Foundation

struct LoginRequest: Codable {
    let udacity: Udacity
    
    enum CodingKeys: String, CodingKey {
        case udacity
    }
    
    struct Udacity: Codable {
        let username: String
        let password: String
    }
}
