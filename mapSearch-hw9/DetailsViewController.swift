//
//  DetailsViewController.swift
//  mapSearch-hw9
//
//  Created by pike on 4/22/18.
//  Copyright © 2018 pike. All rights reserved.
//

import UIKit
import EasyToast

class DetailsViewController: UITabBarController {

    
    var name = ""
    var placeId = ""
    var address = ""
    var website = ""
    var icon = NSURL()
    var fav = false
    
    var favlist = [Favs]()
    
    @IBOutlet weak var myTabBar: UITabBar!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        favlist = []
        if let savedFavs = loadFavs() {
            favlist += savedFavs
        }
    }
    
    private func saveFavs() {
        NSKeyedArchiver.archiveRootObject(favlist, toFile: Favs.ArchiveURL.path)
    }
    
    private func loadFavs() -> [Favs]?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Favs.ArchiveURL.path) as? [Favs]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //self.title = name
        navigationItem.title = name
        var url = URL(string: "http://cs-server.usc.edu:45678/hw/hw9/images/ios/forward-arrow.png")
        var data = try? Data(contentsOf: url!)
        let shareButton = UIBarButtonItem.init(image: UIImage(data: data!), style: .done, target: self, action: #selector(DetailsViewController.shareHandler))
        if !self.fav {
            url = URL(string: "http://cs-server.usc.edu:45678/hw/hw9/images/ios/favorite-empty.png")
        } else {
            url = URL(string: "http://cs-server.usc.edu:45678/hw/hw9/images/ios/favorite-filled.png")
        }
        
        data = try? Data(contentsOf: url!)
        let favButton = UIBarButtonItem.init(image: UIImage(data: data!), style: .done, target: self, action: #selector(DetailsViewController.favHandler))
        
        self.navigationItem.rightBarButtonItems = [favButton, shareButton]
        setTabBarItems()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func shareHandler() {
        let url = "https://twitter.com/intent/tweet?text=Check%20out%20\(self.name)%20located%20at%20\(self.address).%20Website:&url=\(self.website)&hashtags=TravelAndEntertainmentSearch"
        let escapedString = url.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
        UIApplication.shared.open(URL(string: escapedString)!)
    }
    @objc func favHandler() {
        if !self.fav {
            let entry = Favs(name: self.name, icon: self.icon, vicinity: self.address, placeId: self.placeId, fav: true)
            favlist.append(entry!)
            let url = URL(string: "http://cs-server.usc.edu:45678/hw/hw9/images/ios/favorite-filled.png")
            let data = try? Data(contentsOf: url!)
            self.navigationItem.rightBarButtonItems![0].image = UIImage(data: data!)
            self.view.showToast("\(self.name) was added to favorites", position: .bottom, popTime: 3, dismissOnTap: true)
        } else {
            if let i = favlist.index(where: { $0.placeId == self.placeId }) {
                favlist.remove(at: i)
            }
            let url = URL(string: "http://cs-server.usc.edu:45678/hw/hw9/images/ios/favorite-empty.png")
            let data = try? Data(contentsOf: url!)
            self.navigationItem.rightBarButtonItems![0].image = UIImage(data: data!)
            self.view.showToast("\(self.name) was removed from favorites", position: .bottom, popTime: 3, dismissOnTap: true)
        }
        self.fav = !self.fav
        saveFavs()
    }
    
    func setTabBarItems(){
        
        let myTabBarItem1 = (self.tabBar.items?[0])! as UITabBarItem
        var url = URL(string: "http://cs-server.usc.edu:45678/hw/hw9/images/ios/info.png")
        var data = try? Data(contentsOf: url!)
        myTabBarItem1.image = UIImage(data: data!)?.withRenderingMode(.alwaysTemplate)
        myTabBarItem1.selectedImage = UIImage(data: data!)?.withRenderingMode(.alwaysTemplate)
        
        let myTabBarItem2 = (self.tabBar.items?[1])! as UITabBarItem
        url = URL(string: "http://cs-server.usc.edu:45678/hw/hw9/images/ios/picture.png")
        data = try? Data(contentsOf: url!)
        myTabBarItem2.image = UIImage(data: data!)?.withRenderingMode(.alwaysTemplate)
        myTabBarItem2.selectedImage = UIImage(data: data!)?.withRenderingMode(.alwaysTemplate)
        
        let myTabBarItem3 = (self.tabBar.items?[2])! as UITabBarItem
        url = URL(string: "http://cs-server.usc.edu:45678/hw/hw9/images/ios/google-maps.png")
        data = try? Data(contentsOf: url!)
        myTabBarItem3.image = UIImage(data: data!)?.withRenderingMode(.alwaysTemplate)
        myTabBarItem3.selectedImage = UIImage(data: data!)?.withRenderingMode(.alwaysTemplate)
        
        let myTabBarItem4 = (self.tabBar.items?[3])! as UITabBarItem
        url = URL(string: "http://cs-server.usc.edu:45678/hw/hw9/images/ios/review.png")
        data = try? Data(contentsOf: url!)
        myTabBarItem4.image = UIImage(data: data!)?.withRenderingMode(.alwaysTemplate)
        myTabBarItem4.selectedImage = UIImage(data: data!)?.withRenderingMode(.alwaysTemplate)        
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
