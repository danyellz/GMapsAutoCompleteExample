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
    
    var googleMaps = GMSMapView()
    var titleView = UIView()
    var imageView = UIImageView()
    var nameLabel = UILabel()
    var ratingLabel = UILabel()
    
    var cardView = UIView()
    var reviewsTable = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reviewsTable.delegate = self
        reviewsTable.dataSource = self
        reviewsTable.register(ReviewCell.self, forCellReuseIdentifier: "ReviewCell")
    }
    
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
        
        googleMaps.frame = view.bounds
        view.sv(googleMaps, titleView, reviewsTable)
        view.layout(
            0,
            |titleView| ~ view.frame.height / 2,
            0,
            |reviewsTable| ~ view.frame.height / 2
        )
        
        titleView.sv(imageView, nameLabel, ratingLabel)
        titleView.layout(
            (view.frame.height / 4),
            imageView,
            0,
            |-nameLabel-| ~ 40,
            0,
            |-ratingLabel-| ~ 40
        )
        
        cardView.sv()
        cardView.layout(

        )
        
        let blurEffect: UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        var blurEffectView: UIVisualEffectView = UIVisualEffectView()
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        titleView.insertSubview(blurEffectView, at: 0)
        
        titleView.backgroundColor = UIColor.clear
        imageView.width(50)
        imageView.height(50)
        imageView.centerHorizontally()
        
        cardView.backgroundColor = UIColor.lightGray
        nameLabel.backgroundColor = UIColor.clear
    }
    
    fileprivate func setupContainerData() {
        nameLabel.text = place?.name
        nameLabel.textColor = UIColor.white
        nameLabel.textAlignment = .center
        nameLabel.font = UIFont.boldSystemFont(ofSize: 22)
        
        ratingLabel.text = String(format: "Rating: %.1f", (place?.rating)!)
        ratingLabel.textColor = UIColor.white
        ratingLabel.textAlignment = .center
        
        imageView.sd_setImage(with: URL(string: (place?.locPhotoString)!),
                              placeholderImage: nil,
                              options: .refreshCached
        )
    }
}

extension PlaceDetailViewController : UITableViewDelegate {
    
}

extension PlaceDetailViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (place?.ratings.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell") as! ReviewCell
        cell.commentItem = place?.ratings[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
}
