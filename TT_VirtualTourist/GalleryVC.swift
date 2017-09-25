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

class GalleryVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var mapSnapshot: UIImageView!
    @IBOutlet weak var collectionGallery: UICollectionView!
    @IBOutlet weak var newCollection: UIButton!
    
    var pin : Pin!
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        <#code#>
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        <#code#>
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
