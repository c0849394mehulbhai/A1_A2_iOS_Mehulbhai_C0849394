//
//  ViewController.swift
//  A1_A2_iOS_Mehulbhai_C0849394
//
//  .
//
import CoreLocation
import UIKit
import MapKit

class ViewController: UIViewController {
    
  
    @IBOutlet weak var mapvw: MKMapView!
   
    @IBOutlet weak var uiNavigationBar: UINavigationBar!
    var locationManager:CLLocationManager!
    
    var designPoly: MKPolygon? = nil
    let uiNavItem = UINavigationItem()
    var cityArr :[MKMapItem] = []

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
        
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(longPressFunction))
        self.mapvw.addGestureRecognizer(longpress)
        
        
        uiNavItem.rightBarButtonItem = UIBarButtonItem(title: "Route", style: .plain, target: self, action: #selector(addPhotosTapped))
        self.uiNavigationBar.items = [uiNavItem]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkRouteOption()
    }

    func checkRouteOption() {
        if cityArr.count > 2 {
            self.uiNavigationBar.items = [uiNavItem]
        } else {
            self.uiNavigationBar.items?.removeAll()
        }
    }
    
    @objc func addPhotosTapped() {
        if mapvw.overlays.last != nil {
            self.mapvw.removeOverlay(mapvw.overlays.last!)
            designPoly = nil
        }
        for i in 0..<cityArr.count {
            if i == 0 {
                showRoute(source: locationManager.location!.coordinate, destination: cityArr[i].placemark.coordinate, title: "A")
            } else if i == 1 {
                showRoute(source: cityArr[i-1].placemark.coordinate, destination: cityArr[i].placemark.coordinate, title: "B")
            } else if i == 2 {
                showRoute(source: cityArr[i-1].placemark.coordinate, destination: cityArr[i].placemark.coordinate, title: "C")
            }
        }
    }
    
    func showRoute(source : CLLocationCoordinate2D, destination : CLLocationCoordinate2D, title : String) {
        
        let sourceLocation = source
        let destinationLocation = destination
        
        let sourcePlaceMark = MKPlacemark(coordinate: sourceLocation)
        let destinationPlaceMark = MKPlacemark(coordinate: destinationLocation)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
        directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let directionResonse = response else {
                if let error = error {
                    print("we have error getting directions==\(error.localizedDescription)")
                }
                return
            }
            
            //get route and assign to our route variable
            let route = directionResonse.routes[0]
            route.polyline.title = title
            
            
            self.mapvw.addOverlay(route.polyline, level: .aboveRoads)
            
            //setting rect of our mapview to fit the two locations
            let rect = route.polyline.boundingMapRect
            self.mapvw.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
        
    @objc func longPressFunction(sender: UILongPressGestureRecognizer) {
        let alertDialog = UIAlertController(title: "Map Example", message: "Find City", preferredStyle: .alert)

        alertDialog.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "secondViewController") as! secondViewController
            secondViewController.mapView = self.mapvw
            secondViewController.delegate = self
            self.navigationController?.pushViewController(secondViewController, animated: true)
          }))

        alertDialog.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
          
          }))

        present(alertDialog, animated: true, completion: nil)
    }
    
    func drawTraingle() {
        var points: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
        
        for i in 0..<cityArr.count {
            points.append(cityArr[i].placemark.coordinate)
        }
        
        let polygon = MKPolygon(coordinates: points, count: points.count)
        self.designPoly = polygon
        mapvw.addOverlay(polygon)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if touch.tapCount == 1 {
                let touchLocation = touch.location(in: self.mapvw)
                let locationCoordinate = mapvw.convert(touchLocation, toCoordinateFrom: mapvw)
                
                for polygon in mapvw.overlays as! [MKPolygon] {
                    let renderer = MKPolygonRenderer(polygon: polygon)
                    let mapPoint = MKMapPoint(locationCoordinate)
                    let viewPoint = renderer.point(for: mapPoint)
                    if polygon.contain(coor: locationCoordinate) {
                        print("With in range")
                        checkPoint(location: locationCoordinate)
                    } else {
                        print("out side of range")
                    }
                }
            }
        }
        
        super.touchesEnded(touches, with: event)
    }
    
    func checkPoint(location : CLLocationCoordinate2D) {
        var distanceArray : [Double] = []
        for i in 0..<cityArr.count {
            let dist = getDistance(source: location, destination: cityArr[i].placemark.coordinate)
            distanceArray.append(dist)
        }
        let dist = distanceArray.max { a, b in
            return a > b
        }
        var index = 0
        for i in 0..<distanceArray.count {
            if dist == distanceArray[i] {
                index = i
                break
            }
        }
        cityArr.remove(at: index)
//        mapView.removeAnnotation(annotations[index])
        mapvw.removeAnnotations(mapvw.annotations)
        if mapvw.overlays.last != nil {
            mapvw.removeOverlay(mapvw.overlays.last!)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.addAnnotations()
            self.checkRouteOption()
        }
        
    }
    
    func getDistance(source : CLLocationCoordinate2D, destination : CLLocationCoordinate2D) ->  Double {
        let coordinate₀ = CLLocation(latitude: source.latitude, longitude: source.longitude)
        let coordinate₁ = CLLocation(latitude: destination.latitude, longitude: destination.longitude)

        let distanceInMeters = coordinate₀.distance(from: coordinate₁)
        return Double(distanceInMeters)
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
    

    func addAnnotations() {
        var annotations = [MKAnnotation]()
        for i in 0..<cityArr.count {
            let annotation = MKPointAnnotation()
            if i == 0 {
                annotation.title = "A"
            } else if i == 1 {
                annotation.title = "B"
            } else if i == 2 {
                annotation.title = "C"
                drawTraingle()
            } else {
                annotation.title = ""
            }
            
            annotation.coordinate = CLLocationCoordinate2D(latitude: cityArr[i].placemark.coordinate.latitude, longitude: cityArr[i].placemark.coordinate.longitude)
            annotations.append(annotation)
        }
        
        mapvw.addAnnotations(annotations)
        mapvw.fitAll(in: annotations, andShow: true)
    }
}

protocol SearchCityResult {
    func searchedCity(item : MKMapItem)
}

extension ViewController : SearchCityResult {
    
    func searchedCity(item: MKMapItem) {
        cityArr.append(item)
        addAnnotations()
    }
    
}

extension ViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if designPoly == nil {
            let renderer = MKPolylineRenderer(overlay: overlay)
            if overlay.title == "A" {
                renderer.strokeColor = UIColor.green
            } else if overlay.title == "B" {
                renderer.strokeColor = UIColor.brown
            } else if overlay.title == "C" {
                renderer.strokeColor = UIColor.systemPink
            }
            renderer.lineWidth = 4.0
            return renderer
        } else {
            let renderer = MKPolygonRenderer(polygon: designPoly!)
            renderer.fillColor = UIColor.red.withAlphaComponent(0.90)
            return renderer
        }
    }
}




extension MKPolygon {
    func contain(coor: CLLocationCoordinate2D) -> Bool {
        let polygonRenderer = MKPolygonRenderer(polygon: self)
        let currentMapPoint: MKMapPoint = MKMapPoint(coor)
        let polygonViewPoint: CGPoint = polygonRenderer.point(for: currentMapPoint)
        if polygonRenderer.path == nil {
          return false
        }else{
          return polygonRenderer.path.contains(polygonViewPoint)
        }
    }
}

extension MKMapView {

    func drwrectbetwwnpoint() {
        var zoomRect = MKMapRect.null;
        for annotation in annotations {
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.01, height: 0.01);
            zoomRect = zoomRect.union(pointRect);
        }
        setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
    }
    func drwrectbetwwnpoint(in annotations: [MKAnnotation], andShow show: Bool) {
        var zoomRect:MKMapRect  = MKMapRect.null
    
        for annotation in annotations {
            let aPoint = MKMapPoint(annotation.coordinate)
            let rect = MKMapRect(x: aPoint.x, y: aPoint.y, width: 0.1, height: 0.1)
        
            if zoomRect.isNull {
                zoomRect = rect
            } else {
                zoomRect = zoomRect.union(rect)
            }
        }
        if(show) {
            addAnnotations(annotations)
        }
        setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
    }

}












          

 



