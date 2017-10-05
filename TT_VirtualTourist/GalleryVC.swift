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
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var editButton: UIBarButtonItem!
    

    var pin: Pin!
    var flickrPhotos: [Photo]!
    var photoID: String!
    var selectedPhoto: UIImage!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var mapSnapshotter: MKMapSnapshotter!
    let sectionInsets = UIEdgeInsets(top: 5.0, left: 10.0, bottom: 5.0, right: 10.0)
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
            newCollectionButton.isEnabled = false
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
        cell.imageView.image = nil
        cell.activityIndicator.startAnimating()
        let photo = fetchedResultsController.object(at: indexPath)
        newCollectionButton.isEnabled = false
        if photo.imageData != nil {
            if let image = UIImage(data: photo.imageData! as Data) {
                cell.activityIndicator.stopAnimating()
                cell.imageView.image = image
            }
            newCollectionButton.isEnabled = true
        }else if photo.imageURL != nil {
            FlickrApi.sharedInstance().downloadImageFromURLString(photo.imageURL!, completionHandler: { (result, error) in
                performUIUpdatesOnMain {
                    if error != nil {
                        self.showAlert("Error", message: "No Photos")
                    }
                    if let image = UIImage(data: result! as Data) {
                        cell.activityIndicator.stopAnimating()
                        cell.imageView.image = image
                        photo.imageData = result! as NSData
                        
                        do {
                            try self.sharedContext.save()
                            self.collectionGallery.reloadItems(at: [indexPath])
                        }catch let error as NSError {
                            let message = "\(String(describing: error.code)): \(String(describing: error.localizedDescription))"
                            self.showAlert("Error", message: message)
                        }
                    }
                }
            })
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if editButton.title == "Done" {
            let photo = self.fetchedResultsController?.object(at: indexPath)
            
            self.sharedContext.delete(photo!)
            do {
                try self.sharedContext.save()
                try self.fetchedResultsController.performFetch()
                self.flickrPhotos = self.fetchedResultsController.fetchedObjects!
            } catch let error as NSError {
                let message = "\(String(describing: error.code)): \(String(describing: error.localizedDescription))"
                self.showAlert("Error", message: message)
            }
            self.collectionGallery.deleteItems(at: [indexPath])
        }else{
            let cell = collectionView.cellForItem(at: indexPath) as! ImageCell
            selectedPhoto = cell.imageView.image
            performSegue(withIdentifier: "seguePhotoPressed", sender: nil)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "seguePhotoPressed" {
            (segue.destination as! PhotoVC).photo = selectedPhoto
        }
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
    
    
    func refreshCollection() -> Void {
        
    }
    
    
    @IBAction func newCollectionRefresh(_ sender: Any) {
        newCollectionButton.isEnabled = false
        
        let photos = self.fetchedResultsController.fetchedObjects
        for photo in photos! {
            self.sharedContext.delete(photo)
            do {
                try self.sharedContext.save()
            } catch let error as NSError {
                let message = "\(String(describing: error.code)): \(String(describing: error.localizedDescription))"
                self.showAlert("Error", message: message)
            }
        }
        
        let totalPages = pin.numOfPages
        let pageLimit = min(totalPages, 40)
        let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
        FlickrApi.sharedInstance().getPhotos(pin: pin, latitude: pin.latitude, longitude: pin.longitude, withPageNumber: randomPage, completionHandler: { (pages, error) in
            performUIUpdatesOnMain {
                if error != nil {
                    let message = "\(String(describing: error!.code)): \(String(describing: error!.localizedDescription))"
                    self.showAlert("Error", message: message)
                } else {
                    do {
                        try self.fetchedResultsController.performFetch()
                        self.flickrPhotos = self.fetchedResultsController.fetchedObjects!
                    } catch let error as NSError {
                        let message = "\(String(describing: error.code)): \(String(describing: error.localizedDescription))"
                        self.showAlert("Error", message: message)
                    }
                    self.collectionGallery.reloadData()
                }
                self.newCollectionButton.isEnabled = true
            }
        })
        print("New Collection was pressed")
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        if editButton.title == "Edit" {
            editButton.title = "Done"
            editButton.tintColor = UIColor.red
        }else if editButton.title == "Done" {
            editButton.title = "Edit"
            editButton.tintColor = nil
        }
    }
    
    
    private func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
