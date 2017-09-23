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


class MapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        addLongPressGesture()
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
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
}
