//
//  CityStore.swift
//  MyMeetups
//
//  Created by Rodney Sampson on 9/28/16.
//  Copyright © 2016 Rodney Sampson II. All rights reserved.
//

import Foundation
import CoreData

internal class CityStore {
    
    var session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    let coreDataStack = CoreDataStack(modelName: "MyMeetups")
    var cities: [City] = []
    
    func fetchDataWithCompletion(completion: @escaping (CityResult) -> Void ) {
        let url = MeetupAPI.convertURLIntoSecureURL(URL(string: "\(MeetupAPI.configuration.baseURL)\(MeetupAPIMethods.getCities.rawValue)")!)
        let request = URLRequest(url: url)
        let task = self.session.dataTask(with: request) { data, response, error in
            var result = self.processCitiesRequestWithData(data, error: error)
            
            if case let .Success(cities) = result {
                let privateQueueContext = self.coreDataStack.privateQueueContext
                privateQueueContext.performAndWait {
                    try! privateQueueContext.obtainPermanentIDs(for: cities)
                }
                
                do {
                    result = .Success(try self.fetchMainQueueCities())
                    self.coreDataStack.saveChanges(error: error)
                
                } catch let error {
                    print("Error: \(error)")
                }
            } else {
                result = CityResult.Failure(error!)
            }
            
            
            completion(result)
        }
        task.resume()
    }
    
    func processCitiesRequestWithData(_ data: Data?, error: Error?) -> CityResult {
        if (data != nil) {
            return MeetupAPI.citiesFromJSONData(data!, error: error ,inContext: self.coreDataStack.privateQueueContext)
        } else {
            return CityResult.Failure(error!)
        }
    }
    
    func fetchMainQueueCities(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) throws -> [City] {
        var mainQueueCities: [City]?
        
        let request = NSFetchRequest<City>()
        request.entity = City.entity()
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        
        let mainQueueContext = self.coreDataStack.mainQueueContext
        
        var fetchError: Error?
        
        mainQueueContext.performAndWait {
            do {
                mainQueueCities = try mainQueueContext.fetch(request)
            } catch let error {
                fetchError = error
            }
        }
        
        guard let cities = mainQueueCities else {
            throw fetchError!
        }
        
        return cities
    }
    
}
