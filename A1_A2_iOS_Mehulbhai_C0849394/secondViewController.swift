//
//  secondViewController.swift
//  A1_A2_iOS_Mehulbhai_C0849394
//
//  
//
import MapKit
import UIKit

class secondViewController: UIViewController {

    @IBOutlet weak var taView: UITableView!
    
    @IBOutlet weak var entercityTextField: UITextField!
    
    
    var mapView : MKMapView?
    
    var matchingItems:[MKMapItem] = []
    
    var delegate : SearchCityResult?
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func enterCityBtn(_ sender: UIButton) {
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = entercityTextField.text!
        request.region = mapView!.region
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems.removeAll()
            self.matchingItems = response.mapItems
            self.taView.reloadData()
        }

    }
    
}

extension secondViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell") as!
        tableViewCellTableViewCell
        cell.viewCityLbl.text = matchingItems[indexPath.row].placemark.title ?? ""
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.searchedCity(item: matchingItems[indexPath.row])
        self.navigationController?.popViewController(animated: true)
    }
    
}

