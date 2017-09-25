//
//  GalleryVC.swift
//  TT_VirtualTourist
//
//  Created by Tigran Tshorokhyan on 9/24/17.
//  Copyright © 2017 Tigran Tshorokhyan. All rights reserved.
//

import Foundation
import CoreData
import MapKit

class GalleryVC: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet weak var mapSnapshot: UIImageView!
    @IBOutlet weak var collectionGallery: UICollectionView!
    @IBOutlet weak var newCollection: UIButton!
    
    var pin: Pin!
    var mapSnapshotter: MKMapSnapshotter!
    let cellIdentifier = "ImageCell"
    var sharedContext: NSManagedObjectContext  = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapSnapshotter = snapshotSetup()
        snapshot()
    }
    
    
    
    func snapshotSetup() -> MKMapSnapshotter{
        let options = MKMapSnapshotOptions()
        options.region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude), 5000, 5000)
        options.size =  mapSnapshot.bounds.size
        options.scale = UIScreen.main.scale
        return MKMapSnapshotter(options: options)
    }
    
    
    func snapshot(){
        mapSnapshotter.start(completionHandler: { (snapshot, error) -> Void in
            guard error == nil else {
                print("error \(String(describing: error))")
                return
            }
            let pin = MKPinAnnotationView(annotation: nil, reuseIdentifier: nil)
            let image = snapshot!.image
            
            UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale)
            image.draw(at: CGPoint.zero)
            
            let rect = CGRect(origin: CGPoint.zero, size: image.size)
            
            var point = snapshot!.point(for: CLLocationCoordinate2D(latitude: self.pin.latitude, longitude: self.pin.longitude))
            if rect.contains(point) {
                point.x = point.x + pin.centerOffset.x - (pin.bounds.size.width / 2)
                point.y = point.y + pin.centerOffset.y - (pin.bounds.size.height / 2)
                pin.image?.draw(at: point)
            }
            let snapshotImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            self.mapSnapshot.image = snapshotImage
        })
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
        
    

    
    
}
