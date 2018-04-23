//
//  InfoViewController.swift
//  mapSearch-hw9
//
//  Created by pike on 4/22/18.
//  Copyright © 2018 pike. All rights reserved.
//

import UIKit
import GooglePlaces

class InfoViewController: UIViewController {

    var name = ""
    var placeId = ""
    var placeObj: GMSPlace?
    @IBOutlet weak var addressText: UITextView!
    @IBOutlet weak var phoneText: UITextView!
    @IBOutlet weak var priceText: UITextView!
    @IBOutlet weak var ratingText: UITextView!
    @IBOutlet weak var websiteText: UITextView!
    @IBOutlet weak var googleText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        addressText.text = self.placeObj!.formattedAddress
        addressText.frame.size = addressText.contentSize
        phoneText.text = self.placeObj!.phoneNumber
        let price = self.placeObj!.priceLevel.rawValue
        if (price == -1) {
            priceText.text = "Unknown"
        } else if (price == 0) {
            priceText.text = "Free"
        } else {
            priceText.text = String(repeating: "$", count: self.placeObj!.priceLevel.rawValue)
        }
        //ratingText.text = self.placeObj!.rating as? String
        websiteText.text = self.placeObj!.website?.absoluteString
        //googleText.text = self.placeObj!.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
