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
    var address: String?
    var rating: Float?
    var openNow: Bool?
    var locPhotoString: String?
    var lat: Double?
    var lng: Double?
    var ratings = [GoogleRating]()
    
    //MARK: Initialize template only if a location name exists
    init(name: String) {
        self.name = name
    }
    
    convenience init?(json: JSON) {
        if let name = json["name"].string {
            
            self.init(name: name)
            self.address = json["formatted_address"].string
            self.rating = json["rating"].float ?? 0.0
            self.locPhotoString = json["icon"].string
            self.openNow = json["open_now"].bool ?? false
            if let location = json["geometry"]["location"].dictionary {
                self.lat = location["lat"]?.double
                self.lng = location["lng"]?.double
            }
            /*
             Empty array to be cached then passed to the class variable.
             This is not optimized. Ideally you'd cache a large sum of data for reviews,
             then access the data via CoreData, Realm, etc. Luckily, in this case, we're
             not storing a list of PlaceModels for access at a later time--only a single 
             selection at most is possible from the autocomplete table. The table data is then
             cleared once the user A.) stops searching or B.) selects a cell.
             */
            var emptyRatings = [GoogleRating]()
            if let reviews = json["reviews"].array {
                for review in reviews {
                    if let rating = GoogleRating(json: review) {
                        emptyRatings.append(rating)
                    }
                }
                ratings = emptyRatings
            }
            
            return
        }
        return nil
    }
}
