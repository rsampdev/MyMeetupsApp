//
//  MeetupAPI.swift
//  MyMeetups
//
//  Created by Rodney Sampson on 9/28/16.
//  Copyright © 2016 Rodney Sampson II. All rights reserved.
//

import Foundation
import CoreData

internal struct MeetupAPIConfiguration {
    let apiKey: String
    let baseURL: String
    
    init() {
        let bundle = Bundle.main
        guard let plistURL = bundle.url(forResource: "MeetupConfig", withExtension: "plist"), let plistData = try? Data.init(contentsOf: plistURL), let plistAny = try? PropertyListSerialization.propertyList(from: plistData, options: [], format: nil), let plist = plistAny as? [String: Any] else {
            fatalError("Could not load MeetupConfig.plist")
        }
        
        self.apiKey = plist["APIKey"] as! String
        self.baseURL = plist["BaseURL"] as! String
    }
    
}

internal enum MeetupAPIMethods: String {
    case getCities = "/2/cities"
}

internal enum CityResult: Error {
    case Success([City])
    case Failure(Error)
}

struct MeetupAPI {
    
    static let configuration = MeetupAPIConfiguration()
    
    static func citiesFromJSONData(_ data: Data, error: Error?, inContext context: NSManagedObjectContext) -> CityResult {
        if error != nil {
            return CityResult.Failure(error!)
        }
        
        var cities = [City]()
        var jsonData = [String: AnyObject]()
        
        do {
            try jsonData  = JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
        } catch let error {
            print(error)
        }
        let jsonArray = jsonData["results"] as! [[String: AnyObject]]
        
        for jsonSinglePhotoDictionary: [String: AnyObject] in jsonArray {
            let city: City? = self.cityFromJSONDictionary(jsonSinglePhotoDictionary, inContext: context)
            if city != nil {
                cities.append(city!)
            }
        }
        
        return CityResult.Success(cities)
    }
    
    static func cityFromJSONDictionary(_ jsonDict: [String:AnyObject], inContext context: NSManagedObjectContext) -> City? {
        let request = NSFetchRequest<City>()
        request.entity = City.entity()
        
        let cityName = jsonDict["city"] as! String?
        let escapeNonAlphanumericCharacters = cityName?.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics)
        let predicate = NSPredicate(format: "name == '\(escapeNonAlphanumericCharacters)'", [])
        request.predicate = predicate
        
        var city: City? = nil
        do {
            let fetchedCities = try context.fetch(request)
            if fetchedCities.isEmpty == false {
                city = fetchedCities.first
            } else {
                context.performAndWait {
                    city = City(json: jsonDict, context: context)!
                }
            }
        } catch let fetchError {
            print("Error: \(fetchError)")
        }

        
        return city!
    }
    
    static func convertURLIntoSecureURL(_ url: URL) -> URL {
        var secureURL: URL? = nil
        var components = URLComponents(string: url.absoluteString)
        if components?.scheme == "https" {
            return url
        }
        components?.scheme = "https"
        secureURL = components?.url
        return secureURL!
    }
    
}
