//
//  PhotoVC.swift
//  TT_VirtualTourist
//
//  Created by Tigran Tshorokhyan on 10/3/17.
//  Copyright © 2017 Tigran Tshorokhyan. All rights reserved.
//

import Foundation
import UIKit

class PhotoVC: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var photo: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.isUserInteractionEnabled = true
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        scrollView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let image = photo {
            imageView.image = image
        }
    }
    
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    
    func generateMemedImage() -> UIImage {
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let selectedPhoto:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return selectedPhoto
    }
    
    
    @IBAction func share(_ sender: Any) {
        let memedImage = generateMemedImage()
        let activityView = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        activityView.completionWithItemsHandler = {
            (_, successful, _, _) in
            
            if successful{
                self.dismiss(animated: true, completion: nil)
            }
        }
        present(activityView, animated: true, completion: nil)
    }
    
    
}
