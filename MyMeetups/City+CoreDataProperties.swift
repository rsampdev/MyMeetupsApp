//
//  City+CoreDataProperties.swift
//  MyMeetups
//
//  Created by Rodney Sampson on 9/28/16.
//  Copyright © 2016 Rodney Sampson II. All rights reserved.
//

import Foundation
import CoreData


extension City {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<City> {
        return NSFetchRequest<City>(entityName: "City");
    }

    @NSManaged public var name: String?
    @NSManaged public var state: String?
    @NSManaged public var id: Int64
    @NSManaged public var memberCount: Int64
    @NSManaged public var countryName: String?

}
