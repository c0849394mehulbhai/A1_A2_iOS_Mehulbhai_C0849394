//
//  ViewController.swift
//  A1_A2_iOS_Mehulbhai_C0849394
//
//  .
//
import CoreLocation
import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
    
  
    @IBOutlet weak var mapvw: MKMapView!
   
    let regionInMeters: Double = 10000
    var locationManager:CLLocationManager!
    
//    var arrrCity :[MKMapItem] = []
//    var polygon: MKPolygon? = nil
//    
//    let item = UINavigationItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
}


extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0))
            self.mapvw.setRegion(region, animated: true)
            mapvw.showsUserLocation = true
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
     
    }
}

          

 



