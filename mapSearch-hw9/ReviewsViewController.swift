//
//  ReviewsViewController.swift
//  mapSearch-hw9
//
//  Created by pike on 4/22/18.
//  Copyright © 2018 pike. All rights reserved.
//

import UIKit

class ReviewsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var reviews = [ReviewItem]()
    var reviewsBackup = [ReviewItem]()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sortControl: UISegmentedControl!
    @IBOutlet weak var orderControl: UISegmentedControl!
    @IBOutlet weak var reviewControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        reviewsBackup = reviews
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
        let date = NSDate(timeIntervalSince1970: Double(item.time!)! + 25200)
        let dateString = formatter.string(from: date as Date)
        cell.timeLabel!.text = dateString
        
        cell.textView!.text = item.text!
        cell.textView!.frame.size = cell.textView!.contentSize
        
        
        // add code to download the image from fruit.imageURL
        return cell
    }

    @IBAction func sortChanged(_ sender: UISegmentedControl) {
        reorder()
    }
    
    @IBAction func orderChanged(_ sender: UISegmentedControl) {
        reorder()
    }
    
    func reorder() {
        switch sortControl.selectedSegmentIndex {
        case 0:
            self.orderControl.isEnabled = false
            self.reviews = self.reviewsBackup
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
}
