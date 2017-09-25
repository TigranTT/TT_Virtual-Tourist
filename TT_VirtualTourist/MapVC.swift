//
//  MapVC.swift
//  TT_VirtualTourist
//
//  Created by Tigran Tshorokhyan on 9/22/17.
//  Copyright © 2017 Tigran Tshorokhyan. All rights reserved.
//

import Foundation
import MapKit
import CoreData
import CoreLocation


class MapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    
    var contextPins: [Pin]!
    let clLocationManager = CLLocationManager()
    var sharedContext: NSManagedObjectContext  = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        clLocationManager.delegate = self
        addLongPressGesture()
        mapView.showsUserLocation = true
        contextPins = fetchPins()
        for pins in contextPins {
            addAnnotationCoordinate(pins)
            lastPinRegion(pins)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        bottomView.transform = CGAffineTransform(translationX: 0, y: 51)
    }
    
    func bottomViewIsHidden(hidden: Bool) {
        UIView.animate(withDuration: 0.3, animations: {
            if hidden {
                self.bottomView.transform = CGAffineTransform(translationX: 0, y: 51)
                self.mapView.transform = CGAffineTransform(translationX: 0, y: 0)
            }else{
                self.bottomView.transform = CGAffineTransform(translationX: 0, y: 0)
                self.mapView.transform = CGAffineTransform(translationX: 0, y: -50)
            }
        })
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        if editButton.title == "Edit" {
            print("Edit button was pressed")
            bottomViewIsHidden(hidden: false)
            editButton.title = "Done"
        }else if editButton.title == "Done" {
            bottomViewIsHidden(hidden: true)
            editButton.title = "Edit"
        }
    }
    
    
    func addLongPressGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(addPins(gesture:)))
        longPressGesture.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPressGesture)
    }
    
    func addPins(gesture: UILongPressGestureRecognizer) {
        if editButton.title == "Edit" && gesture.state == .ended {
            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            print("PIN dropped")
            print(coordinate)
            contextPins.append(Pin(latitude: coordinate.latitude, longitude: coordinate.longitude, title: "", subtitle: "", context: sharedContext))
            
            saveContext()
        }
    }
    
    func saveContext() {
        do {
            try sharedContext.save()
            print("Context saved")
        }catch let error as NSError {
            let messageString = "\(String(describing: error.code)): \(String(describing: error.localizedDescription))"
            showAlert("Error", message: messageString)
        }
    }
    
    /*func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        pinView.canShowCallout = true
        pinView.pinTintColor = .red
        pinView.animatesDrop = true
        return pinView
    }*/

    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: true)
        for selectedPin in contextPins {
            if selectedPin.latitude == view.annotation?.coordinate.latitude && selectedPin.longitude == view.annotation?.coordinate.longitude && editButton.title == "Done" {
                sharedContext.delete(selectedPin)
                mapView.removeAnnotation(view.annotation!)
                print("PIN deleted")
                saveContext()
            }else if editButton.title == "Edit" {
                performSegue(withIdentifier: "seguePinPressed", sender: self)
            }
        }
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
     let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
     pinView.canShowCallout = true
     pinView.pinTintColor = .red
     pinView.animatesDrop = true
     return pinView
     }
    
    
    func fetchPins() -> [Pin] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entDescription = NSEntityDescription.entity(forEntityName: "Pin", in: sharedContext)
        fetchRequest.entity = entDescription
        
        var results: [AnyObject]!
        do {
            results = try sharedContext.fetch(fetchRequest)
            print("Context fetched")
        }catch let error as NSError {
            results = nil
            print("error \(error)")
        }
        return results as! [Pin]
    }
    
    func addAnnotationCoordinate(_ pin: Pin) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        mapView.addAnnotation(annotation)
    }
    
    func lastPinRegion(_ pin: Pin) {
        let region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude), 5000, 5000)
        mapView.setRegion(region, animated: true)
    }
    
    
    @IBAction func showUserLocation(_ sender: Any) {
        clLocationManager.requestWhenInUseAuthorization()
        let location = mapView.userLocation
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude), span)
        mapView.setRegion(region, animated: true)
    }
    
    
    private func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
}
