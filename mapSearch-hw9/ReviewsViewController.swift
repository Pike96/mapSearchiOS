//
//  ReviewsViewController.swift
//  mapSearch-hw9
//
//  Created by pike on 4/22/18.
//  Copyright © 2018 pike. All rights reserved.
//

import UIKit
import Alamofire
import Alamofire_SwiftyJSON

class ReviewsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let DOMAIN = "http://mapsearchpike96.rajgs5wdu2.us-west-1.elasticbeanstalk.com"
    var reviews = [ReviewItem]()
    var googleBackup = [ReviewItem]()
    var yelpBackup = [ReviewItem]()
    var name = ""
    var address = ""
    var city = ""
    var state = ""
    var country = ""
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var noItemView: UIView!
    @IBOutlet weak var sortControl: UISegmentedControl!
    @IBOutlet weak var orderControl: UISegmentedControl!
    @IBOutlet weak var reviewControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        googleBackup = reviews
        if reviews.count == 0 {
            self.tableView.backgroundView = self.noItemView
            self.tableView.separatorStyle = .none
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewsViewCell") as! ReviewsViewCell
        let item = self.reviews[indexPath.row]
        cell.photoView.image = UIImage(data: NSData(contentsOf: item.photo as URL)! as Data)
        cell.nameLabel!.text = item.name!
        cell.ratingStars.rating = item.rating!
        cell.ratingStars.settings.updateOnTouch = false
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = NSDate(timeIntervalSince1970: Double(item.time!)! + (reviewControl.selectedSegmentIndex == 0 ? 25200 : 0))
        let dateString = formatter.string(from: date as Date)
        cell.timeLabel!.text = dateString
        
        cell.textView!.text = item.text!
        cell.textView!.frame.size = cell.textView!.contentSize
                
        // add code to download the image from fruit.imageURL
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.reviews[indexPath.row]
        UIApplication.shared.open(URL(string: item.url!)!)
    }

    @IBAction func sortChanged(_ sender: UISegmentedControl) {
        self.reorder()
    }
    
    @IBAction func orderChanged(_ sender: UISegmentedControl) {
        self.reorder()
    }
    
    func reorder() {
        switch sortControl.selectedSegmentIndex {
        case 0:
            self.orderControl.isEnabled = false
            self.reviews = reviewControl.selectedSegmentIndex == 0 ? self.googleBackup : self.yelpBackup
            self.tableView.reloadData()
        case 1:
            self.orderControl.isEnabled = true
            if (self.orderControl.selectedSegmentIndex == 0) {
                self.reviews.sort(by: { $0.rating! < $1.rating! })
            } else {
                self.reviews.sort(by: { $0.rating! > $1.rating! })
            }
            self.tableView.reloadData()
        case 2:
            self.orderControl.isEnabled = true
            if (self.orderControl.selectedSegmentIndex == 0) {
                self.reviews.sort(by: { Double($0.time!)! < Double($1.time!)! })
            } else {
                self.reviews.sort(by: { Double($0.time!)! > Double($1.time!)! })
            }
            self.tableView.reloadData()
        default:
            break
        }
    }
    
    @IBAction func typeChanged(_ sender: Any) {
        switch reviewControl.selectedSegmentIndex {
        case 0:
            self.reviews = self.googleBackup
            if reviews.count == 0 {
                self.tableView.backgroundView = self.noItemView
                self.tableView.separatorStyle = .none
            } else {
                self.tableView.separatorStyle = .singleLine
                self.tableView.backgroundView = nil
            }
            self.reorder()
            self.tableView.reloadData()
        case 1:
            let name = self.name.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
            let address = self.address.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
            let city = self.city.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
            Alamofire.request("\(DOMAIN)/yelp?name=\(name)&address1=\(address)&city=\(city)&state=\(self.state)&country=\(self.country)").responseSwiftyJSON { response in
                if let json = response.result.value {
                    if json.arrayValue.count == 0 {
                        self.reviews = []
                        self.tableView.backgroundView = self.noItemView
                        self.tableView.separatorStyle = .none
                        self.tableView.reloadData()
                    } else {
                        self.tableView.separatorStyle = .singleLine
                        self.tableView.backgroundView = nil
                        
                        self.reviews = []
                        let tempArr = json.arrayValue
                        for i in tempArr {
                            let name = i["user"]["name"].stringValue
                            let photo = i["user"]["image_url"].stringValue
                            let rating = i["rating"].doubleValue
                            let time = i["time_created"].stringValue
                            let text = i["text"].stringValue
                            
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            guard let date = formatter.date(from: time) else {
                                fatalError("ERROR: Date conversion failed due to mismatched format.")
                            }
                            let timeUnix = date.timeIntervalSince1970.description
                            
                            let url = i["url"].stringValue
                            
                            let item = ReviewItem(name: name, photo: NSURL(string:photo)!, rating: rating, time: timeUnix, text: text, url: url)
                            self.reviews.append(item)
                        }
                        self.yelpBackup = self.reviews
                        self.reorder()
                        self.tableView.reloadData()
                    }
                }
            }
        default:
            break
        }
    }
}
