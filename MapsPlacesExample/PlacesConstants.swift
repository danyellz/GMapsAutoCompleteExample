//
//  PlacesConstants.swift
//  MapsPlacesExample
//
//  Created by TY on 4/9/16.
//  Copyright © 2016 Ty Daniels Dev. All rights reserved.
//
//Constants used to format JSON request URL in AddressSearchClient

import Foundation

extension AddressSearchClient {
    
    struct Constants{
        static let BaseURL: String = "https://maps.googleapis.com/maps/api/geocode/json?"
    }
    
    struct ParameterKeys{
        static let AddressKey: String = "address="
}
    struct JSONResponseKeys{
        static let Results: String = "results"
        static let Status: String = "status"
        static let FormattedAddress: String = "formatted_address"
        static let Geometry: String = "geometry"
        static let Location: String = "location"
        static let Lat: String = "lat"
        static let Lng: String = "lng"
        static let Sensor: String = "&sensor=false"
        static let Photos: String = "photos"
        static let PhotoRef: String = "photo_reference"
    }
}