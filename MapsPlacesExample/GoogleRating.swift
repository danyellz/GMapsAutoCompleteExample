//
//  GoogleRating.swift
//  MapsPlacesExample
//
//  Created by Ty Daniels on 4/3/17.
//  Copyright © 2017 Ty Daniels Dev. All rights reserved.
//

import Foundation
import SwiftyJSON

struct GoogleRating {
    var review: String?
    var rating: Float?
    var usrPhotoString: String?
    
    //MARK: Initialize template only if a rating string exists
    init(review: String) {
        self.review = review
    }
    
    init?(json: JSON) {
        if let review = json["text"].string {
            self.init(review: review)
            
            self.rating = json["rating"].float ?? 0.0
            self.usrPhotoString = json["profile_photo_url"].string ?? ""
            
            return
        }
        return nil
    }
}
