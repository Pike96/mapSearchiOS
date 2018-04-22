//
//  DetailsViewController.swift
//  mapSearch-hw9
//
//  Created by pike on 4/22/18.
//  Copyright © 2018 pike. All rights reserved.
//

import UIKit

class DetailsViewController: UITabBarController {

    var name = ""
    var placeId = ""
    
    @IBOutlet weak var myTabBar: UITabBar!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //self.title = name
        navigationItem.title = name
        var url = URL(string: "http://cs-server.usc.edu:45678/hw/hw9/images/ios/forward-arrow.png")
        var data = try? Data(contentsOf: url!)
        let shareButton = UIBarButtonItem.init(image: UIImage(data: data!), style: .done, target: self, action: #selector(DetailsViewController.share))
        url = URL(string: "http://cs-server.usc.edu:45678/hw/hw9/images/ios/favorite-empty.png")
        data = try? Data(contentsOf: url!)
        let favButton = UIBarButtonItem.init(image: UIImage(data: data!), style: .done, target: self, action: #selector(DetailsViewController.fav))
        
        self.navigationItem.rightBarButtonItems = [favButton, shareButton]
        setTabBarItems()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func share() {
        print("share")
    }
    @objc func fav() {
        print("fav")
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
