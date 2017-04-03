//
//  GooglePlacesService.swift
//  MapsPlacesExample
//
//  Created by Ty Daniels on 4/3/17.
//  Copyright © 2017 Ty Daniels Dev. All rights reserved.
//

import Foundation
import CoreLocation
import Foundation
import Alamofire
import SwiftyJSON
import SDWebImage

typealias GoogleErrorBlock = (_ errorMessage: String) -> Void
typealias GooglePlacesBlock = (_ places: [GooglePlace]) -> Void

enum GooglePlaceType {
    case restaurant
    case cities
    
    func toString() -> String {
        switch self {
        case .restaurant:
            return "restaurant"
        case .cities:
            return "locality"
        }
    }
}

class GooglePlacesService {
    
    static var currentLocation = CLLocation()
    static let locManager = CLLocationManager()
    
    // MARK: - Lifecycle
    
    /**
     *  Singleton instance of the manager
     */
    static let sharedManager = GooglePlacesService()
    
    // MARK: - Fetching Places
    
    /* 
     Note: This example is fairly simple and does not include a client for dealing with networking code.
     Instead, all of the networking code for fetching current location information, then information about places
     is retrieved based on the PlacesId. This is done directly from the endpoint opposed to using the SDK (very heavy).
     */
    func searchForPlaceNamed(name: String?, completionHandler: @escaping (_ addresses: [String]?) -> Void) {
        
        let currentLoc = GooglePlacesService.locManager.location
        let baseUrl = "https://maps.googleapis.com/maps/api/place/autocomplete/json?"
        let locationFormat = "input=%@&location=\(currentLoc?.coordinate.latitude),\(currentLoc?.coordinate.longitude)&radius=%lu&language=%@&key=%@"
        let queryString = String(format: locationFormat, arguments: [name!, 16093, language, apiKey])
        guard let escapedQuery = queryString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            fatalError("Malformed query string when calling into Google Places API")
        }
        
        let endpoint = baseUrl + escapedQuery
        Alamofire.request(endpoint, method: .get, parameters: nil).responseJSON { (response) in
            if let json = response.result.value {
                guard let json = json as? [String: AnyObject] else {
                    print(response.result.value)
                    return
                }
                
                if let array = JSON(json["predictions"]).array {
                    self.fetchDetailsFromID(placeIds: array, completionHandler: {(arr) -> Void in
                        completionHandler(arr)
                    })
                }
            } else {
                guard response.result.error == nil else {
                    print("Bad response")
                    return
                }
            }
        }
    }
    
    func fetchDetailsFromID(placeIds: [JSON], completionHandler: @escaping (_ addArr: [String]) -> Void) {
        
        var addressArr = [String]()
        for object in placeIds {
            if let id = object["place_id"].string {
                let baseUrl = "https://maps.googleapis.com/maps/api/place/details/json?"
                let locationFormat = "placeid=%@&key=%@"
                let queryString = String(format: locationFormat, arguments: [id, apiKey])
                
                guard let escapedQuery = queryString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
                    fatalError("Malformed query string when calling into Google Places API")
                }
                
                let endpoint = baseUrl + escapedQuery
                Alamofire.request(endpoint, method: .get, parameters: nil).responseJSON { (response) in
                    if let json = response.result.value {
                        guard let json = json as? [String: AnyObject] else {
                            print(response.result.value!)
                            return
                        }
                        
                        let results = JSON(json["result"])
                        if let address = results["formatted_address"].string {
                            addressArr.append(address)
                            completionHandler(addressArr)
                        }
                    } else {
                        guard response.result.error == nil else {
                            print("Bad response")
                            return
                        }
                    }
                }
            }
        }
    }
    
    func fetchLocationImage(completionHandler: @escaping(_ data: NSData?) -> Void){
        
        GooglePlacesService.sharedManager.fetchPlacesNearMe("", type: .cities, success: { (places) in
            let photos = JSON(places.first!)
            let reference = (photos["photos"].array?.first?.dictionary?["photo_reference"]?.string)!
            
            let urlString = "https://maps.googleapis.com/maps/api/place/photo?"
            let query = "maxwidth=1200&photoreference=%@&key=%@"
            let queryString = String(format: query, arguments: [reference, self.apiKey])
            guard let escapedQuery = queryString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
                fatalError("Malformed query string when calling into Google Places API")
            }
            
            let url = urlString + escapedQuery
            
            if let data = NSData(contentsOf: URL(string: url)!) {
                completionHandler(data)
            }
        })
    }
    
    func fetchPlacesNearMe(_ query: String, type: GooglePlaceType = .restaurant, success: GooglePlacesBlock? = nil, error: GoogleErrorBlock? = nil) {
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse) ||
            (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            
            if let location = GooglePlacesService.locManager.location {
                queryFormat = "name=%@&type=%@&location=\(location.coordinate.latitude),\(location.coordinate.longitude)&radius=%lu&language=%@&key=%@"
            }
            
        }
        
        let queryString = String(format: queryFormat, arguments: [pipedQueryFrom(query), type.toString(), radius, language, apiKey])
        guard let escapedQuery = queryString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            fatalError("Malformed query string when calling into Google Places API")
        }
        
        let endpoint = baseURL + escapedQuery
        Alamofire.request(endpoint, method: .get, parameters: nil).responseJSON { (response) in
            if let json = response.result.value {
                guard let json = json as? [String: AnyObject], let places = self.placesFromJSON(json) else {
                    error?("Could not parse JSON or it was empty")
                    return
                }
                print("PLACES: \(places)")
                success?(places)
            } else {
                guard let apiError = response.result.error else {
                    error?("Bad response")
                    return
                }
                
                error?(apiError.localizedDescription)
            }
        }
    }
    
    func cancelAllFetches() {
//        Alamofire.Manager.sharedInstance.session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
//            for task in dataTasks {
//                if let originalRequest = task.originalRequest, originalRequest.URLString.containsString(self.baseURL) {
//                    task.cancel()
//                }
//            }
//        }
    }
    
    // MARK: - Private Properties
    
    //Achieve the functionality of the SDK by hitting the GMaps endpoint directly
    let baseURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
    var queryFormat = "name=%@&type=%@&location=37.333906,-121.893895&radius=%lu&language=%@&key=%@"
    let currentLocURL = "https://www.googleapis.com/geolocation/v1/geolocate?key=%@&key=%@"
    let apiKey = "AIzaSyDheMo9mZDAjLhGqE_vBckIcTf_DzQJW2o"
    let radius = 8000 // ~5 miles
    let language = "en"
    
}

private extension GooglePlacesService {
    
    func pipedQueryFrom(_ query: String) -> String {
        let queryTerms = query.components(separatedBy: " ")
        guard queryTerms.count > 1 else { return query }
        
        return queryTerms.joined(separator: "|")
    }
    
    func placesFromJSON(_ json: [String: AnyObject]) -> [GooglePlace]? {
        guard let results = json["results"] as? [AnyObject] else { return nil }
        guard results.count != 0 else { return nil }
        
        //Check if Google 'place' matches GooglePlace model before initialization. If so, append to empty array of Type GooglePlace
        var places = [GooglePlace]()
        for placeDictionary in results {
            print("GOOGLEPLACE: \(placeDictionary)")
            if let place = GooglePlace(json: JSON(placeDictionary)) {
                places.append(place)
            }
        }
        
        return places
    }
}
