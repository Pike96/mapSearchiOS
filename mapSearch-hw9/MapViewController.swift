//
//  MapViewController.swift
//  mapSearch-hw9
//
//  Created by pike on 4/22/18.
//  Copyright © 2018 pike. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import Alamofire
import Alamofire_SwiftyJSON

class MapViewController: UIViewController, GMSAutocompleteViewControllerDelegate, CLLocationManagerDelegate {
    
    var lat = 0.0
    var lon = 0.0
    var mode = "driving"
    var mapView: GMSMapView?
    var markerFrom = GMSMarker()
    var markerDest = GMSMarker()
    var coordinate: CLLocationCoordinate2D?
    @IBOutlet weak var fromText: UITextField!
    @IBOutlet weak var modeControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.mapView = GMSMapView.map(withFrame: CGRect(x: 16, y: 226, width: 343, height: 386), camera: GMSCameraPosition.camera(withLatitude: self.lat, longitude: self.lon, zoom: 14))
        
        
        markerDest.position = CLLocationCoordinate2D(latitude: self.lat, longitude: self.lon)
        markerDest.map = self.mapView
        
        self.view.addSubview(mapView!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        fromText.text = place.formattedAddress
        self.coordinate = place.coordinate
        getDirections()
        self.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("ERROR AUTO COMPLETE \(error)")
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil) // when cancel search
    }
    
    @IBAction func openSearchAddress(_ sender: Any) {
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        self.present(autoCompleteController, animated: true, completion: nil)
    }
    
    
    @IBAction func modeChanged(_ sender: Any) {
        switch modeControl.selectedSegmentIndex {
        case 0:
            self.mode = "driving"
        case 1:
            self.mode = "bicycling"
        case 2:
            self.mode = "transit"
        case 3:
            self.mode = "walking"
        default:
            break
        }
        let from = (self.fromText.text?.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil))!
        if from != "" {
            getDirections()
        }
    }
    
    func getDirections() {
        let from = (self.fromText.text?.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil))!
        Alamofire.request("https://maps.googleapis.com/maps/api/directions/json?origin=\(from)&destination=\(self.lat),\(self.lon)&mode=\(self.mode)", encoding: URLEncoding.default).responseSwiftyJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            if let json = response.result.value {
                let routes = json["routes"].arrayValue
                for i in routes {
                    self.mapView?.clear()
                    
                    let routeOverviewPolyline = i["overview_polyline"].dictionary
                    let points = routeOverviewPolyline?["points"]?.stringValue
                    let path = GMSPath.init(fromEncodedPath: points!)
                    let polyline = GMSPolyline.init(path:path)
                    polyline.strokeWidth = 5
                    polyline.strokeColor = UIColor.blue
                    polyline.map = self.mapView
                    
                    self.markerFrom.position = self.coordinate!
                    self.markerFrom.map = self.mapView
                    self.markerDest.position = CLLocationCoordinate2D(latitude: self.lat, longitude: self.lon)
                    self.markerDest.map = self.mapView
                    
                    let northeast = CLLocationCoordinate2D(latitude: i["bounds"]["northeast"]["lat"].doubleValue, longitude: i["bounds"]["northeast"]["lng"].doubleValue)
                    let southwest = CLLocationCoordinate2D(latitude: i["bounds"]["southwest"]["lat"].doubleValue, longitude: i["bounds"]["southwest"]["lng"].doubleValue)
                    let bounds = GMSCoordinateBounds(coordinate: northeast, coordinate: southwest)
                    let camera = self.mapView?.camera(for: bounds, insets: UIEdgeInsets())!
                    self.mapView?.camera = camera!
                }
            }
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
