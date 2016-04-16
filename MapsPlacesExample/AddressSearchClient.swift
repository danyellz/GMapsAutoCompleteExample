//
//  AddressSearchClient.swift
//  MapsPlacesExample
//
//  Created by TY on 4/10/16.
//  Copyright © 2016 Ty Daniels Dev. All rights reserved.

//Custom Client to GET address JSON responses from Google Places

import Foundation
import UIKit
import GoogleMaps

class AddressSearchClient: NSObject {
    
    var lookUpAddress: [NSObject: AnyObject]!
    var photoResults: [NSObject: AnyObject]!
    var fetchedFormattedAddress: String!
    var formattedAddressLong: Double!
    var formattedAddressLat: Double!
    
    override init() {
        super.init()
    }
    
    //Function to get properly formatted JSON response from 
    //Google Places to be used in SearchResultsAutoComplete table
    
    func geoCodeAddress(address: String!, withCompletionHandler completionHandler: ((status: String!, success: Bool!) -> Void)){
        
        //Check if user input is valid with Google Places JSON reponses
        if let lookupAddress = address {
            
            //1. Create URL to return desired location JSON
            //2. Format URL using PlacesConstants model
            let geoURLString = Constants.BaseURL + ParameterKeys.AddressKey + lookupAddress + JSONResponseKeys.Sensor
            let geoCodeURLs = NSURL(string: geoURLString)
            
            //3. Get raw JSON data
            let geoCoderesultData = NSData(contentsOfURL: geoCodeURLs!)
            
            //4.Convert raw JSON to readable object
            let dictionary: [NSObject : AnyObject] = try! NSJSONSerialization.JSONObjectWithData(geoCoderesultData!, options: .AllowFragments) as! [NSObject:AnyObject]
            
            var error = NSError?()
            if error !== nil{
                    print(error)
                    completionHandler(status: "error", success: false)
                    return
            }else{
                //Check JSON reponse status
                let status = dictionary[JSONResponseKeys.Status] as! String
                if status == "OK" {
                    
                    //Get all initial values returned from the JSON search
                    let allResults = dictionary[JSONResponseKeys.Results] as! [[NSObject: AnyObject]]
                    self.lookUpAddress = allResults[0]
                    
                    //Get address key value pair from results
                    fetchedFormattedAddress = self.lookUpAddress[JSONResponseKeys.FormattedAddress] as! String
                    
                    //Get geometry key value pair from results
                    let geometry = self.lookUpAddress[JSONResponseKeys.Geometry] as! [NSObject: AnyObject]
                    
                    //Latitude from searched address
                    self.formattedAddressLong = ((geometry[JSONResponseKeys.Location] as! [NSObject:AnyObject])[JSONResponseKeys.Lng] as! NSNumber).doubleValue
                    
                    //Longitutude from searched address
                    self.formattedAddressLat = ((geometry[JSONResponseKeys.Location] as! [NSObject:AnyObject])[JSONResponseKeys.Lat] as! NSNumber).doubleValue
                    
                    completionHandler(status: status, success: true)
                }
            }
        }
    }
}
