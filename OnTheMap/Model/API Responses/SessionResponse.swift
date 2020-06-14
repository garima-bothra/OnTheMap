//
//  SessionResponse.swift
//  OnTheMap
//
//  Created by Garima Bothra on 25/05/20.
//  Copyright © 2020 Garima Bothra. All rights reserved.
//

import Foundation


struct SessionResponse: Codable {
    let account: Account
    let session: Session
    
    enum CodingKeys: String, CodingKey {
        case account
        case session
    }
    
    struct Account: Codable {
        let registered: Bool
        let key: String
    }
    
    struct Session: Codable {
        let id: String
        let expiration: String
    }
}
