//
//  GooglePlace.swift
//  MapsPlacesExample
//
//  Created by Ty Daniels on 4/3/17.
//  Copyright © 2017 Ty Daniels Dev. All rights reserved.
//

import Foundation
import SwiftyJSON

class GooglePlace {
    var name: String?
    var rating: Float?
    var openNow: Bool?
    var locPhotoString: String?
    
    init(name: String) {
        self.name = name
    }
    
    convenience init?(json: JSON) {
        if let name = json["name"].string {
            self.init(name: name)
            return
        }
        return nil
    }
}
