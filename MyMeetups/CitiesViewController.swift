//
//  ViewController.swift
//  MyMeetups
//
//  Created by Rodney Sampson on 9/28/16.
//  Copyright © 2016 Rodney Sampson II. All rights reserved.
//

import UIKit

class CitiesViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    fileprivate var store = CityStore()
    var cities: [City] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.reloadState()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.cities = []
    }
    
    fileprivate func reloadState() {
        let privateQueue = OperationQueue()
        privateQueue.addOperation {
            self.store.fetchDataWithCompletion { (cityResult) in
                OperationQueue.main.addOperation {
                    switch cityResult {
                    case let .Success(cities):
                        self.cities = cities
                        print("\n\n\nDone. Loaded \(self.cities.count) Cities\n\n\n")
                    case let .Failure(error):
                        print("\n\n\n\n\nError: \(error)")
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
}

extension CitiesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
}

extension CitiesViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "CityCell") as! CityCell
        let city = self.cities[indexPath.row]
        cell.cityIDLabel.text = "\(city.id)"
        cell.cityNameLabel.text = city.name ?? ""
        cell.cityStateLabel.text = city.state ?? ""
        cell.cityCountryNameLabel.text = city.countryName ?? ""
        cell.cityMemberCountLabel.text = "\(city.memberCount)"
        return cell
    }
    
}
