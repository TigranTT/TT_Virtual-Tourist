//
//  Pin+CoreDataClass.swift
//  TT_VirtualTourist
//
//  Created by Tigran Tshorokhyan on 9/23/17.
//  Copyright © 2017 Tigran Tshorokhyan. All rights reserved.
//

import Foundation
import CoreData
import MapKit

@objc(Pin)
public class Pin: NSManagedObject {
    
    
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    
    convenience init(latitude: Double, longitude: Double, title: String, subtitle: String, entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        
        if let entDescription = NSEntityDescription.entity(forEntityName: "Pin", in: context!) {
            self.init(entity: entDescription, insertInto: context)
            self.latitude = latitude
            self.longitude = longitude
            self.title = title
            self.subtitle = subtitle
            self.numOfPages = 0
        }else{
            fatalError("Unable to find Entity name!")
        }
        
    }
    

}
