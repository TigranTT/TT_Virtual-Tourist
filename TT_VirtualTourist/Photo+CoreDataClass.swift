//
//  Photo+CoreDataClass.swift
//  TT_VirtualTourist
//
//  Created by Tigran Tshorokhyan on 9/23/17.
//  Copyright © 2017 Tigran Tshorokhyan. All rights reserved.
//

import Foundation
import CoreData

@objc(Photo)
public class Photo: NSManagedObject {
    
    
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    
    convenience init(imageURL: String, pin: Pin, insertInto context: NSManagedObjectContext?) {
        
        if let entDescription = NSEntityDescription.entity(forEntityName: "Photo", in: context!) {
            self.init(entity: entDescription, insertInto: context)
            self.imageURL = imageURL
        }else{
            fatalError("Unable to find Entity name!")
        }
    }

}
