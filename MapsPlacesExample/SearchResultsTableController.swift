//
//  SearchResultsClient.swift
//  MapsPlacesExample
//
//  Created by TY on 4/9/16.
//  Copyright © 2016 Ty Daniels Dev. All rights reserved.
//
//Tableviewcontroller to hold autocomplete results when searchBar NSRange > 0

import UIKit

//Protocol for delegating pin values of selected table row to be added to GMSMapView
protocol LocateOnTheMap{
    func locateWithLongitude(_ lon:Double, andLatitude lat:Double, andTitle title: String)
}

class SearchResultsTableController: UITableViewController {
    
    //searchResults holds all places objects for use in tableview cells. Primarily for address strings.
    var searchResults: [GooglePlace]!
    
    var delegate: LocateOnTheMap!
    public var formattedAddress: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Make searchResults an array of location strings
        self.searchResults = Array()
        //Instantiate tableView cell identifier for reuse
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //Populate tableView with number of rows as results returned from search
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResults.count
    }
    
    //Add address string to corresponding tableView cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)
        cell.textLabel?.text = self.searchResults[indexPath.row].address
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Format string of selected cell before it is added to annotation marker
        formattedAddress = self.searchResults[indexPath.row].address?.addingPercentEncoding(withAllowedCharacters: CharacterSet.symbols)
        self.delegate.locateWithLongitude(0.00, andLatitude: 0.00, andTitle: searchResults[indexPath.row].address!)
    }
    
    //Reload table view / add updated address strings into tableView as searchBar text changes
    func reloadDataWithArray(_ array:[GooglePlace]){
        self.searchResults = array
        self.tableView.reloadData()
    }
    
    //Create an alert for errors
    func showAlertMessage(_ message: String){
        let alertController = UIAlertController(title: "AutoCompleteDemo", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let closeAlertAction  = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel) {(alertAction) -> Void in
    }
        alertController.addAction(closeAlertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
