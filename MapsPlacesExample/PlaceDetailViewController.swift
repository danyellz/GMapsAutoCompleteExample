//
//  PlaceDetailViewController.swift
//  MapsPlacesExample
//
//  Created by Ty Daniels on 4/3/17.
//  Copyright © 2017 Ty Daniels Dev. All rights reserved.
//

import Foundation
import UIKit
import Stevia
import SDWebImage
import CoreLocation

class PlaceDetailViewController: UIViewController {
    var place: GooglePlace?
    var locationManager = CLLocationManager()
    
    var titleView = UIView()
    var imageView = UIImageView()
    var nameLabel = UILabel()
    
    var cardView = UIView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            
            setupContainerData()
        }
    }
    
    fileprivate func setupView() {
        view.sv(titleView, cardView)
        view.layout(
            0,
            |titleView| ~ view.frame.height / 2,
            0,
            |cardView| ~ view.frame.height / 2
        )
        
        titleView.sv(imageView, nameLabel)
        titleView.layout(
            (view.frame.height / 4),
            imageView,
            0,
            |-nameLabel-| ~ 20
        )
        
        cardView.sv()
        cardView.layout(

        )
        
        titleView.backgroundColor = UIColor.white
        imageView.width(50)
        imageView.height(50)
        imageView.centerHorizontally()
        
        cardView.backgroundColor = UIColor.lightGray
        nameLabel.backgroundColor = UIColor.clear
    }
    
    fileprivate func setupContainerData() {
        nameLabel.text = place?.name
        nameLabel.textAlignment = .center
        nameLabel.font = UIFont.boldSystemFont(ofSize: 22)
        
        imageView.sd_setImage(with: URL(string: (place?.locPhotoString)!),
                              placeholderImage: nil,
                              options: .refreshCached
        )
    }
}
