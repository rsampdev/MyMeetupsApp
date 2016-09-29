//
//  ViewController.swift
//  MyMeetups
//
//  Created by Rodney Sampson on 9/28/16.
//  Copyright © 2016 Rodney Sampson II. All rights reserved.
//

import UIKit

class CitiesViewController: UIViewController {
    
    fileprivate var store = CityStore()
    var cities: [City] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reloadState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.cities.isEmpty == true {
            self.reloadState()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.cities = []
    }
    
    fileprivate func reloadState() {
        store.fetchDataWithCompletion { (cityResult) in
            OperationQueue.main.addOperation {
                switch cityResult {
                case let .Success(cities):
                    self.cities = cities
                    print("\n\n\nDone. Loaded \(self.cities.count) Cities\n\n\n")
                case let .Failure(error):
                    print("\n\n\n\n\nError: \(error)")
                }
            }
        }
    }
    
}
