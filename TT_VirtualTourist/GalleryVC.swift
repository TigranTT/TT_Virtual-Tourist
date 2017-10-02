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

class GalleryVC: UIViewController, CLLocationManagerDelegate, NSFetchedResultsControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    @IBOutlet weak var mapSnapshot: UIImageView!
    @IBOutlet weak var collectionGallery: UICollectionView!
    @IBOutlet weak var newCollection: UIButton!
    
    
    var pin: Pin!
    var flickrPhotos: [Photo]!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var mapSnapshotter: MKMapSnapshotter!
    let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    let itemsPerRow: CGFloat = 3
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapSnapshotter = snapshotSetup()
        snapshot()
        collectionGallery.delegate = self
        collectionGallery.dataSource = self
        collectionGallery.allowsMultipleSelection = true
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "imageURL", ascending: true)]
        let predicate = NSPredicate(format: "pin == %@", self.pin)
        fetchRequest.predicate = predicate
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest as! NSFetchRequest<Photo>, managedObjectContext: sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            flickrPhotos = fetchedResultsController.fetchedObjects!
        } catch let error as NSError {
            let message = "\(String(describing: error.code)): \(String(describing: error.localizedDescription))"
            self.showAlert("Error", message: message)
        }
        checkPhotoArray(photoArray: flickrPhotos)
    }
    
    
    func checkPhotoArray(photoArray: [Photo]) {
        if photoArray.count == 0 {
            showAlert("Error", message: "No Photos")
            newCollection.isEnabled = false
            print("Photo array count =\(photoArray.count)")
        }else{
            print("Photo array count =\(photoArray.count)")
        }
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
            guard (error == nil) else {
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
            print("got the Snapshot")
        })
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Got the photo count =\(pin.photo.count)")
        return pin.photo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! ImageCell
        
        
        cell.activityIndicator.startAnimating()
        let photos = pin.photo
        let photo = photos.allObjects[indexPath.row] as! Photo
        let imageURL = URL(string: photo.imageURL!)
        if let imageData = try? Data(contentsOf: imageURL!) {
            cell.imageView.image = UIImage(data: imageData)
            cell.activityIndicator.stopAnimating()
            cell.backgroundColor = UIColor.blue
        }
        
        //print("Got the photo cell")
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
     
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
     
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    
    @IBAction func newCollectionRefresh(_ sender: Any) {
        print("New Collection was pressed")
    }
    
    private func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
