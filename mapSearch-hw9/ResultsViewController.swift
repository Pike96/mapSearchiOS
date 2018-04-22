//
//  ResultsViewController.swift
//  mapSearch-hw9
//
//  Created by pike on 4/12/18.
//  Copyright © 2018 pike. All rights reserved.
//

import UIKit
import Alamofire
import Alamofire_SwiftyJSON
import SwiftSpinner

struct ResultsItem {
    let name: String?
    let icon: NSURL
    let vicinity: String?
    let placeId: String?
    let fav: Bool?
}

class ResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let DOMAIN = "http://mapsearchpike96.rajgs5wdu2.us-west-1.elasticbeanstalk.com"
    var kwd = ""
    var ctg = "Default"
    var dis = "10"
    var from = ""
    var lat = 0.0
    var lon = 0.0
    var page = 1
    var nextPageToken = ""
    var resultsArr = [ResultsItem]()
    var resultsAll = [AnyObject]()
    var selectedName = ""
    var selectedPlaceId = ""
    @IBOutlet var noItemsView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        SwiftSpinner.show("Searching...")
        searchHandler()
        
        self.tableView.backgroundView = self.noItemsView
        self.tableView.separatorStyle = .none
    }
    
    func searchHandler() {
        if from == "My location" || from == "Your location" {
            Alamofire.request("http://ip-api.com/json").responseSwiftyJSON { response in
                if let json = response.result.value {
                    self.lat = json["lat"].double!
                    self.lon = json["lon"].double!
                    self.apiSearch(kwd: self.kwd, ctg: self.ctg, dis: self.dis, lat: self.lat, lon: self.lon)
                }
            }
        } else {
            let loc = from.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
            Alamofire.request("\(DOMAIN)/location?loc=\(loc)", encoding: URLEncoding.default).responseSwiftyJSON { response in
                    if let json = response.result.value {
                    self.lat = json["lat"].double!
                    self.lon = json["lon"].double!
                    self.apiSearch(kwd: self.kwd, ctg: self.ctg, dis: self.dis, lat: self.lat, lon: self.lon)
                }
            }
        }
    }
    
    func apiSearch(kwd: String, ctg: String, dis: String, lat: Double, lon: Double) {
        let keyword = kwd.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        let category = ctg.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        let distance = dis == "" ? "10" : dis;
        Alamofire.request("\(DOMAIN)/list?keyword=\(keyword)&category=\(category)&distance=\(distance)&lat=\(lat)&lon=\(lon)").responseSwiftyJSON { response in
                if let json = response.result.value {
                    if json["status"].string! == "OK" {
                        //self.info.text = "has"
                        self.page = 1
                        self.resultsAll = []
                        let tempArr = json["results"].arrayValue
                        for i in tempArr {
                            let name = i["name"].stringValue
                            let icon = i["icon"].stringValue
                            let vicinity = i["vicinity"].stringValue
                            let placeId = i["place_id"].stringValue
                            
                            let item = ResultsItem(name: name, icon: NSURL(string:icon)!, vicinity: vicinity, placeId: placeId, fav: false)
                            self.resultsArr.append(item)
                        }
                        self.resultsAll.append(self.resultsArr as AnyObject)
                        self.tableView.separatorStyle = .singleLine
                        self.tableView.backgroundView = nil
                    } else {
                        self.tableView.backgroundView = self.noItemsView
                        self.tableView.separatorStyle = .none
                    }
                    if json["next_page_token"].stringValue != "" {
                        self.nextButton.isEnabled = true
                        self.nextPageToken = json["next_page_token"].stringValue
                    }
                    self.tableView.reloadData()
                    SwiftSpinner.hide()
                }
        }
    }
    
    @IBAction func next(_ sender: UIButton) {
        SwiftSpinner.show("Searching...")
        self.page = self.page + 1
        if self.page != 1 {
            self.prevButton.isEnabled = true
        } else {
            self.prevButton.isEnabled = false
        }
        if self.page >= self.resultsAll.count {
            Alamofire.request("\(DOMAIN)/nextpage?pagetoken=\(self.nextPageToken)", encoding: URLEncoding.default).responseSwiftyJSON { response in
                if let json = response.result.value {
                    //print(json["next_page_token"].stringValue)
                    if json["next_page_token"].stringValue != "" {
                        self.nextButton.isEnabled = true
                        self.nextPageToken = json["next_page_token"].stringValue
                    } else {
                        self.nextButton.isEnabled = false
                    }
                    self.resultsArr = []
                    let tempArr = json["results"].arrayValue
                    for i in tempArr {
                        let name = i["name"].stringValue
                        let icon = i["icon"].stringValue
                        let vicinity = i["vicinity"].stringValue
                        let placeId = i["place_id"].stringValue
                        
                        let item = ResultsItem(name: name, icon: NSURL(string:icon)!, vicinity: vicinity, placeId: placeId, fav: false)
                        self.resultsArr.append(item)
                    }
                    self.resultsAll.append(self.resultsArr as AnyObject)
                    self.tableView.reloadData()
                    SwiftSpinner.hide()
                }
            }
        } else {
            self.resultsArr = self.resultsAll[self.page - 1] as! [ResultsItem]
            self.tableView.reloadData()
            SwiftSpinner.hide()
        }
    }
    
    @IBAction func prev(_ sender: UIButton) {
        SwiftSpinner.show("Searching...")
        self.page = self.page - 1
        if self.page != 1 {
            self.prevButton.isEnabled = true
        } else {
            self.prevButton.isEnabled = false
        }
        
        self.nextButton.isEnabled = true
        
        self.resultsArr = self.resultsAll[self.page - 1] as! [ResultsItem]
        self.tableView.reloadData()
        SwiftSpinner.hide()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.resultsArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultsCell") as! ResultsTableViewCell
        let item = self.resultsArr[indexPath.row]
        cell.iconView.image = UIImage(data: NSData(contentsOf: item.icon as URL)! as Data)
        cell.nameLabel!.text = item.name
        cell.vicinityLabel!.text = item.vicinity
        if item.fav! {
            let url = URL(string: "http://cs-server.usc.edu:45678/hw/hw9/images/ios/favorite-filled.png")
            let data = try? Data(contentsOf: url!)
            cell.favView.image = UIImage(data: data!)
        } else {
            let url = URL(string: "http://cs-server.usc.edu:45678/hw/hw9/images/ios/favorite-empty.png")
            let data = try? Data(contentsOf: url!)
            cell.favView.image = UIImage(data: data!)
        }

        // add code to download the image from fruit.imageURL
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Segue to the second view controller
        let item = self.resultsArr[indexPath.row]
        self.selectedName = item.name!
        self.selectedPlaceId = item.placeId!
        self.performSegue(withIdentifier: "showDetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // get a reference to the second view controller
        let detailsViewController = segue.destination as! DetailsViewController
        
        // set a variable in the second view controller with the String to pass
        detailsViewController.name = self.selectedName
        detailsViewController.placeId = self.selectedPlaceId
    }
    
}

