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
    // MARK : Reused Managers
    var place: GooglePlace?
    var locationManager = CLLocationManager()
    
    // MARK : View assets
    var googleMaps = GMSMapView()
    var titleView = UIView()
    var imageView = UIImageView()
    var nameLabel = UILabel()
    var ratingLabel = UILabel()
    var cardView = UIView()
    
    // MARK: Controllers
    var reviewsTable = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reviewsTable.delegate = self
        reviewsTable.dataSource = self
        reviewsTable.register(ReviewCell.self, forCellReuseIdentifier: "ReviewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        //Configure views
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        //Load data into view after layout
        setupContainerData()
    }
    
    /*
     Setup views/containers. Using Stevia to configure layouts: a framework that is practical due to
     a more visually intuitive syntax. The basic usage of this framework involves setting a top constraint
     for every asset that is vertically aligned. Also, Stevia allows for positioning view objects horizontally
     aligned, and the sizes of each element become relative to one another based on percentages in relation to UIWindow sizes.
     Finally, |-asset-| spans the window with a small margin left/right. ~ is used to set an approximate 
     height relative to window height.
     
     In order to use Stevia:
     - 1. Add subviews to corresponding views w/ UIView.sv(views)
     - 2. Layout views within the top view with UIView.layout()
     */
    fileprivate func setupView() {
        //Set GMaps map frame
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
        
        // MARK: Additional layout
        
        //Custom blur effect imposed on GMap
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
    
    // MARK: Function used to load data into view after layouts finish initializing
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

// MARK: UITableView protocols

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
