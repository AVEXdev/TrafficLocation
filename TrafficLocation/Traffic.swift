//
//  Traffic.swift
//  TrafficLocation
//
//  Created by user149365 on 4/14/19.
//  Copyright © 2019 user149365. All rights reserved.
//

import Foundation

struct Traffic {
    
    var latitude :Double
    var longitude :Double
    
    func toDictionary() -> [String:Any] {
        return ["latitude":self.latitude,"longitude":self.longitude]
    }
}

extension Traffic {
    
    init?(dictionary :[String:Any]) {
        
        guard let latitude = dictionary["latitude"] as? Double,
            let longitude = dictionary["longitude"] as? Double else {
                return nil
        }
        self.latitude = latitude
        self.longitude = longitude
    }
}
