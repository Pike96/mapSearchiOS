//
//  MainViewController.swift
//  mapSearch-hw9
//
//  Created by pike on 4/12/18.
//  Copyright © 2018 pike. All rights reserved.
//

import UIKit
import McPicker
import GooglePlaces
import Alamofire
import Alamofire_SwiftyJSON
import EasyToast
import MapKit
import CoreLocation

class MainViewController: UIViewController, GMSAutocompleteViewControllerDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var keywordText: UITextField!
    @IBOutlet weak var categoryText: McTextField!
    @IBOutlet weak var distanceText: UITextField!
    @IBOutlet weak var fromText: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
    @IBOutlet weak var viewControl: UISegmentedControl!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var noItemsView: UIView!
    
    let DOMAIN = "http://mapsearchpike96.rajgs5wdu2.us-west-1.elasticbeanstalk.com"
    var lat = 0.0
    var lon = 0.0
    var dis = "10"
    var passedResults = "";
    
    var favlist = [Favs]()
    var selectedName = ""
    var selectedPlaceId = ""
    var fav = false
    var icon = NSURL()
    var address = ""
    var phone = ""
    var price = ""
    var rating = ""
    var website = ""
    var googlepage = ""
    var detailsLat = 0.0
    var detailsLon = 0.0
    var reviews = [ReviewItem]()
    var city = ""
    var state = ""
    var country = ""
    
    let locationManager = CLLocationManager()
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        favlist = []
        if let savedFavs = loadFavs() {
            favlist += savedFavs
        }
        if favlist.count == 0 {
            self.tableView.backgroundView = self.noItemsView
            self.tableView.separatorStyle = .none
        } else {
            self.tableView.separatorStyle = .singleLine
            self.tableView.backgroundView = nil
        }
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.us
        
        searchView.isHidden = false
        tableView.isHidden = true
        
        searchButton.backgroundColor = UIColor.lightGray
        clearButton.backgroundColor = UIColor.lightGray
        categoryText.text = "Default"
        distanceText.placeholder = "Enter distance (default 10 miles)"
        
        let categories: [[String]] = [
            ["Default", "Airport", "Amusement Park", "Aquarium", "Art Gallery", "Bakery", "Bar", "Beauty Salon", "Bowling Alley", "Bus Station", "Cafe", "Campground", "Car Rental", "Casino", "Lodging", "Movie Theater", "Museum", "Night Club", "Park", "Parking", "Restaurant", "Shopping Mall", "Stadium", "Subway Station", "Taxi Stand", "Train Station", "Transit Station", "Travel Agency", "Zoo"]
        ]
        let mcInputView = McPicker(data: categories)
        mcInputView.backgroundColor = .gray
        mcInputView.backgroundColorAlpha = 0.25
        categoryText.inputViewMcPicker = mcInputView
        categoryText.doneHandler = { [weak categoryText] (selections) in
            categoryText?.text = selections[0]!
        }
        categoryText.selectionChangedHandler = { [weak categoryText] (selections, componentThatChanged) in
            categoryText?.text = selections[componentThatChanged]!
        }
        categoryText.textFieldWillBeginEditingHandler = { [weak categoryText] (selections) in
            if categoryText?.text == "" {
                // Selections always default to the first value per component
                categoryText?.text = selections[0]
            }
        }
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        self.lat = locValue.latitude
        self.lon = locValue.longitude
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        fromText.text = place.formattedAddress
        self.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("ERROR AUTO COMPLETE \(error)")
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil) // when cancel search
    }
    
    @IBAction func openSearchAddress(_ sender: UITextField) {
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        self.present(autoCompleteController, animated: true, completion: nil)
    }
    
    @IBAction func search(_ sender: UIButton) {
        if (keywordText.text! == "") {
            self.view.showToast("Please enter a keyword", position: .bottom, popTime: 3, dismissOnTap: true)
        } else {
            performSegue(withIdentifier: "showResults", sender: self)
        }
    }
    
    @IBAction func clear(_ sender: UIButton) {
        keywordText.text = ""
        categoryText.text = "Default"
        distanceText.text = ""
        fromText.text = "Your location"
    }
    
    @IBAction func viewChanged(_ sender: UISegmentedControl) {
        switch viewControl.selectedSegmentIndex {
        case 0:
            searchView.isHidden = false
            tableView.isHidden = true
        case 1:
            searchView.isHidden = true
            tableView.isHidden = false
        default:
            break
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.favlist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavCell") as! FavTableViewCell
        let item = self.favlist[indexPath.row]
        if let imageData = NSData(contentsOf: item.icon as URL) {
            cell.iconView.image = UIImage(data: imageData as Data)
        }
        cell.nameLabel!.text = item.name
        cell.vicinityLabel!.text = item.vicinity
        
        // add code to download the image from fruit.imageURL
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.favlist[indexPath.row]
        self.selectedName = item.name!
        self.selectedPlaceId = item.placeId!
        self.fav = item.fav!
        self.icon = item.icon
        getDetails(placeID: item.placeId!)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            self.view.showToast("\(self.favlist[indexPath.row].name!) was removed from favorites", position: .bottom, popTime: 3, dismissOnTap: true)
            favlist.remove(at: indexPath.row)
            saveFavs()
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            if favlist.count == 0 {
                self.tableView.backgroundView = self.noItemsView
                self.tableView.separatorStyle = .none
            } else {
                self.tableView.separatorStyle = .singleLine
                self.tableView.backgroundView = nil
            }
        }
    }
    
    private func saveFavs() {
        NSKeyedArchiver.archiveRootObject(favlist, toFile: Favs.ArchiveURL.path)
    }
    
    private func loadFavs() -> [Favs]?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Favs.ArchiveURL.path) as? [Favs]
    }
    
    func getDetails(placeID: String) {
        Alamofire.request("\(DOMAIN)/details?placeid=\(placeID)", encoding: URLEncoding.default).responseSwiftyJSON { response in
            if response.error != nil {
                self.view.showToast("Error", position: .bottom, popTime: 3, dismissOnTap: true)
            }
            if let json = response.result.value {
                self.address = json["result"]["formatted_address"].stringValue
                self.phone = json["result"]["international_phone_number"].stringValue
                self.price = json["result"]["price_level"].stringValue
                self.rating = json["result"]["rating"].stringValue
                self.website = json["result"]["website"].stringValue
                self.googlepage = json["result"]["url"].stringValue
                self.detailsLat = json["result"]["geometry"]["location"]["lat"].doubleValue
                self.detailsLon = json["result"]["geometry"]["location"]["lng"].doubleValue
                
                self.reviews = []
                let tempArr = json["result"]["reviews"].arrayValue
                for i in tempArr {
                    let name = i["author_name"].stringValue
                    let photo = i["profile_photo_url"].stringValue
                    let rating = i["rating"].doubleValue
                    let time = i["time"].stringValue
                    let text = i["text"].stringValue
                    let url = i["author_url"].stringValue
                    
                    let item = ReviewItem(name: name, photo: NSURL(string:photo)!, rating: rating, time: time, text: text, url: url)
                    self.reviews.append(item)
                }
                
                let addressArr = json["result"]["address_components"].arrayValue
                for i in addressArr {
                    if i["types"][0].stringValue == "locality" {
                        self.city = i["short_name"].stringValue
                    }
                    if i["types"][0].stringValue == "administrative_area_level_1" {
                        self.state = i["short_name"].stringValue
                    }
                    if i["types"][0].stringValue == "country" {
                        self.country = i["short_name"].stringValue
                    }
                }
                
                self.performSegue(withIdentifier: "favDetails", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showResults" {
            // get a reference to the second view controller
            let resultsViewController = segue.destination as! ResultsViewController
            
            // set a variable in the second view controller with the String to pass
            resultsViewController.kwd = self.keywordText.text!
            resultsViewController.ctg = self.categoryText.text!
            resultsViewController.dis = self.distanceText.text!
            resultsViewController.from = self.fromText.text!
            resultsViewController.lat = self.lat
            resultsViewController.lon = self.lon
        } else if segue.identifier == "favDetails" {
            // get a reference to the second view controller
            let detailsViewController = segue.destination as! DetailsViewController
            
            // set a variable in the second view controller with the String to pass
            detailsViewController.name = self.selectedName
            detailsViewController.placeId = self.selectedPlaceId
            detailsViewController.address = self.address
            detailsViewController.website = self.website
            detailsViewController.fav = self.fav
            detailsViewController.icon = self.icon
            
            let infoDes = detailsViewController.viewControllers?[0] as! InfoViewController
            infoDes.placeId = self.selectedPlaceId
            infoDes.address = self.address
            infoDes.phone = self.phone
            infoDes.price = self.price
            infoDes.rating = self.rating
            infoDes.website = self.website
            infoDes.googlepage = self.googlepage
            let photosDes = detailsViewController.viewControllers?[1] as! PhotosViewController
            photosDes.placeId = self.selectedPlaceId
            let mapDes = detailsViewController.viewControllers?[2] as! MapViewController
            mapDes.lat = self.detailsLat
            mapDes.lon = self.detailsLon
            let reviewsDes = detailsViewController.viewControllers?[3] as! ReviewsViewController
            reviewsDes.reviews = self.reviews
            reviewsDes.name = self.selectedName
            reviewsDes.address = self.address
            reviewsDes.city = self.city
            reviewsDes.state = self.state
            reviewsDes.country = self.country
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
