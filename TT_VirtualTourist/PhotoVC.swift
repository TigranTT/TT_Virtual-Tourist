//
//  PhotoVC.swift
//  TT_VirtualTourist
//
//  Created by Tigran Tshorokhyan on 10/3/17.
//  Copyright © 2017 Tigran Tshorokhyan. All rights reserved.
//

import Foundation
import UIKit

class PhotoVC: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var photo: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let image = photo {
            imageView.image = image
        }
    }

    
    
    
    
    
    
    
    
}
