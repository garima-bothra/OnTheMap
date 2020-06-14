//
//  StudentResults.swift
//  OnTheMap
//
//  Created by Garima Bothra on 25/05/20.
//  Copyright © 2020 Garima Bothral. All rights reserved.
//

import Foundation

struct StudentResults: Codable {
    let results: [StudentInformation]
    enum CodingKeys: String, CodingKey {
        case results
    }
}
