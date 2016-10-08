//
//  City+CoreDataClass.swift
//  MyMeetups
//
//  Created by Rodney Sampson on 9/28/16.
//  Copyright © 2016 Rodney Sampson II. All rights reserved.
//

import Foundation
import CoreData

internal class City: NSManagedObject {
    
    required convenience init?(json: [String:Any], context: NSManagedObjectContext) {
        guard let jsonName = json["city"] as? String,
              let jsonID = json["id"] as? NSNumber,
              let jsonCountryName = json["localized_country_name"] as? String,
              let jsonMemberCount = json["member_count"] as? NSNumber,
              let jsonState = json["state"] as? String else {
            return nil
        }
        
        self.init(entity: City.entity(), insertInto: context)
        
        name = jsonName
        id = jsonID.int64Value
        countryName = jsonCountryName
        memberCount = jsonMemberCount.int64Value
        state = jsonState
    }
    
    public override func awakeFromInsert() {
        self.id = 0
        self.name = ""
        self.state = ""
        self.memberCount = 0
        self.countryName = ""
    }
    
}
