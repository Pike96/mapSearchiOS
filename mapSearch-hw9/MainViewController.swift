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

class MainViewController: UIViewController, GMSAutocompleteViewControllerDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var keywordText: UITextField!
    @IBOutlet weak var categoryText: McTextField!
    @IBOutlet weak var distanceText: UITextField!
    @IBOutlet weak var fromText: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
    let DOMAIN = "http://mapsearchpike96.rajgs5wdu2.us-west-1.elasticbeanstalk.com"
    var lat = 0.0
    var lon = 0.0
    var dis = "10"
    var passedResults = "";
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // get a reference to the second view controller
        let resultsViewController = segue.destination as! ResultsViewController
        
        // set a variable in the second view controller with the String to pass
        resultsViewController.kwd = self.keywordText.text!
        resultsViewController.ctg = self.categoryText.text!
        resultsViewController.dis = self.distanceText.text!
        resultsViewController.from = self.fromText.text!
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
