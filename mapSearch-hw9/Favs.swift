//
//  Favs.swift
//  mapSearch-hw9
//
//  Created by pike on 4/25/18.
//  Copyright © 2018 pike. All rights reserved.
//

import UIKit

class Favs: NSObject, NSCoding {
    //MARK: Properties
    
    var name: String?
    var icon: NSURL
    var vicinity: String?
    var placeId: String?
    var fav: Bool?
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("favs")
    
    //MARK: Initialization
    
    init?(name: String, icon: NSURL, vicinity: String, placeId: String, fav: Bool) {
        
        // Initialize stored properties.
        self.name = name
        self.icon = icon
        self.vicinity = vicinity
        self.placeId = placeId
        self.fav = fav
    }
    
    //MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(icon, forKey: "icon")
        aCoder.encode(vicinity, forKey: "vicinity")
        aCoder.encode(placeId, forKey: "placeId")
        aCoder.encode(fav, forKey: "fav")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let name = aDecoder.decodeObject(forKey: "name") as? String else {
            return nil
        }
        guard let icon = aDecoder.decodeObject(forKey: "icon") as? NSURL else {
            return nil
        }
        guard let vicinity = aDecoder.decodeObject(forKey: "vicinity") as? String else {
            return nil
        }
        guard let placeId = aDecoder.decodeObject(forKey: "placeId") as? String else {
            return nil
        }
        guard let fav = aDecoder.decodeObject(forKey: "fav") as? Bool else {
            return nil
        }
        
        // Must call designated initializer.
        self.init(name: name, icon: icon, vicinity: vicinity, placeId: placeId, fav: fav)
        
    }
}
