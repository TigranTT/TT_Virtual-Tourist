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
    
    /*
    internal func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        if(pinView == nil) {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
        }
        return pinView
    } */
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: true)
        if editButton.title == "Done" {
            let point = view.annotation
            mapView.removeAnnotation(point!)
            let pin = contextPins.filter{$0.latitude == point?.coordinate.latitude && $0.longitude == point?.coordinate.longitude}.first
            if let unwrappedPin = pin {
                contextPins.remove(at: contextPins.index(of: unwrappedPin)!)
                sharedContext.delete(unwrappedPin)
            }
            print("PIN deleted")
            saveContext()
        }else{
            performSegue(withIdentifier: "seguePinPressed", sender: view)
        }
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
            print("error \(String(describing: error))")
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "seguePinPressed" {
            let vc = segue.destination as!  GalleryVC
            let annotationView = (sender as! MKAnnotationView).annotation
            let pin = contextPins.filter{$0.latitude == annotationView?.coordinate.latitude && $0.longitude == annotationView?.coordinate.longitude}.first
            vc.pin = pin
        }
    }
    
    
    
    
    
    
}
