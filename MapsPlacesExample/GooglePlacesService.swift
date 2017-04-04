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
    
    //Singleton of self--the manager for Google Networking.
    static let sharedManager = GooglePlacesService()
    
    // MARK: - Fetching Places
    
    /* 
     Note: This example is fairly simple and does not include a client for dealing with networking code.
     Instead, GMaps prediction JSON results are parsed here, and the PlaceId from each object is then used to retrieve detailed
     information such as formatted addresses, and ratings. This is done directly from the endpoint opposed to using the SDK (very heavy).
     */
    
    //Function that takes a query string (an address, a location name, etc) and retrieves an array of GooglePlace objects
    func searchForPlaceNamed(name: String?, completionHandler: @escaping (_ addresses: [GooglePlace]?) -> Void) {
        /* 
         *MARK: Sets up autocomplete endpoint to retrieve locations from the center of user's radius -> outward.
         */
        let currentLoc = GooglePlacesService.locManager.location
        let baseUrl = "https://maps.googleapis.com/maps/api/place/autocomplete/json?"
        let locationFormat = "input=%@&location=\(currentLoc?.coordinate.latitude),\(currentLoc?.coordinate.longitude)&radius=%lu&language=%@&key=%@"
        let queryString = String(format: locationFormat, arguments: [name!, 16093, language, apiKey]) //Interpolate query params with url percent-encoding
        
        //Check for valid percent-encoded URL
        guard let escapedQuery = queryString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            fatalError("Malformed query string when calling into Google Places API")
        }
        let endpoint = baseUrl + escapedQuery
        
        Alamofire.request(endpoint, method: .get, parameters: nil).responseJSON { (response) in
            if let json = response.result.value {
                
                guard let json = json as? [String: AnyObject] else {
                    print("JSON error from: \(response.result.value)")
                    return
                }
                // MARK: Autocomplete predictions
                if let array = JSON(json["predictions"]!).array {
                    self.fetchDetailsFromID(predictions: array, completionHandler: {(arr) -> Void in
                        completionHandler(arr) //Pass GooglePlace collection to ViewController
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
    
    //Parse 'prediction' objects to save as GooglePlace objects
    func fetchDetailsFromID(predictions: [JSON], completionHandler: @escaping (_ addArr: [GooglePlace]? ) -> Void) {
        //Empty arr of GooglePlace objects
        var placesArr = [GooglePlace]()
        /*
         MARK: Check each Place JSON object for place_id key/value.
         This is the vital identifier to retrieve detailed information
         a Google Places location.
         */
        for object in predictions {
            if let id = object["place_id"].string {
                let baseUrl = "https://maps.googleapis.com/maps/api/place/details/json?"
                let locationFormat = "placeid=%@&key=%@"
                let queryString = String(format: locationFormat, arguments: [id, apiKey]) //Interpolate query params with url percent-encoding
                
                //Check for valid percent-encoded URL
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
                        // Mark: Check whether a place object is available and valid to initialize as GooglePlace
                        let result = JSON(json["result"])
                        print("PLACE: \(result)")
                        if let place = GooglePlace(json: result) {
                            placesArr.append(place)
                            completionHandler(placesArr)
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
    
    // NOTE: Fetches location image and converts to NSData. Configured to later be used with a Realm object (optimal to use images as Data)
    func fetchLocationImage(completionHandler: @escaping(_ image: NSData?) -> Void){
        /* 
         Note: querystring is set to empty-string because in this case we want to return all JSON objects.
         Setting a range limit of ~5 mi naturally limits the number of objects returned from the GMaps Places endpoint.
         */
        GooglePlacesService.sharedManager.fetchPlacesNearMe("", type: .cities, completionHandler: { (places) in
            let photos = JSON(places.first)
            let reference = (photos["photos"].array?.first?.dictionary?["photo_reference"]?.string)!
            
            let urlString = "https://maps.googleapis.com/maps/api/place/photo?"
            let query = "maxwidth=1200&photoreference=\(reference)&key=%@"
            let queryString = String(format: query, arguments: [self.apiKey])
            guard let escapedQuery = queryString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
                fatalError("Malformed query string when calling into Google Places API")
            }
            
            let url = urlString + escapedQuery
            print("IMAGEURL: \(url)")
            if let data = NSData(contentsOf: URL(string: url)!) {
                completionHandler(data)
            }
        })
    }
    
    //Specify the query type. This interpolates a special parameter value into the URL. For instance, 'restaurants' or 'points of interest'.
    func fetchPlacesNearMe(_ query: String, type: GooglePlaceType = .restaurant, completionHandler: GooglePlacesBlock? = nil, error: GoogleErrorBlock? = nil) {
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
                
                completionHandler?(places) //Completion
                
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
    var queryFormat = ""
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
