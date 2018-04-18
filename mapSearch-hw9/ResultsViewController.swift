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
    let fav: Bool?
}

class ResultsViewController: UIViewController, UITableViewDataSource {

    let DOMAIN = "http://mapsearchpike96.rajgs5wdu2.us-west-1.elasticbeanstalk.com"
    var kwd = ""
    var ctg = "Default"
    var dis = "10"
    var from = ""
    var lat = 0.0
    var lon = 0.0
    var resultsArr = [ResultsItem]()
    @IBOutlet var noItemsView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        SwiftSpinner.show("Searching...")
        searchHandler()
        
        self.tableView.backgroundView = noItemsView
        self.tableView.separatorStyle = .none
    }
    
    func searchHandler() {
        if from == "My location" || from == "Your location" {
            //            let serverTrustPolicies: [String: ServerTrustPolicy] = [
            //                "ip-api.com": .disableEvaluation
            //            ]
            //
            //            let sessionManager = SessionManager(
            //                serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
            //            )
            //            sessionManager.request("http://ip-api.com/json")
            //            Alamofire.request("http://ip-api.com/json", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON{ (response) in
            //                print(response.result)
            //
            //            }
            Alamofire.request("http://ip-api.com/json").responseSwiftyJSON { response in
                print("Request: \(String(describing: response.request))")   // original url request
                print("Response: \(String(describing: response.response))") // http url response
                print("Result: \(response.result)")                         // response serialization result
                
                if let json = response.result.value {
                    print(json) // serialized json response
                    self.lat = json["lat"].double!
                    self.lon = json["lon"].double!
                    self.apiSearch(kwd: self.kwd, ctg: self.ctg, dis: self.dis, lat: self.lat, lon: self.lon)
                }
            }
        } else {
            let loc = from.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
            Alamofire.request("\(DOMAIN)/location?loc=\(loc)", encoding: URLEncoding.default).responseSwiftyJSON { response in
                print("Request: \(String(describing: response.request))")   // original url request
                print("Response: \(String(describing: response.response))") // http url response
                print("Result: \(response.result)")                         // response serialization result
                
                if let json = response.result.value {
                    print("JSON: \(json)") // serialized json response
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
                print("Request: \(String(describing: response.request))")   // original url request
                print("Result: \(response.result)")                         // response serialization result
                
                if let json = response.result.value {
                    print(json) // serialized json response
                    if json["status"].string! == "OK" {
                        //self.info.text = "has"
                        let tempArr = json["results"].arrayValue
                        for i in tempArr {
                            let name = i["name"].stringValue
                            let icon = i["icon"].stringValue
                            let vicinity = i["vicinity"].stringValue
                            
                            let item = ResultsItem(name: name, icon: NSURL(string:icon)!, vicinity: vicinity, fav: false)
                            self.resultsArr.append(item)
                        }
                        self.tableView.separatorStyle = .singleLine
                        self.tableView.backgroundView = nil
                        self.tableView.reloadData()
                    } else {
                        //self.info.text = "No"
                    }
                    SwiftSpinner.hide()
                }
        }
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
    
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

