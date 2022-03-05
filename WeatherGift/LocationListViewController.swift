//
//  LocationListViewController.swift
//  WeatherGift
//
//  Created by Kevin Watke on 3/4/22.
//

import UIKit

class LocationListViewController: UIViewController {

	@IBOutlet weak var editBarButton: UIBarButtonItem!
	@IBOutlet weak var addBarButton: UIBarButtonItem!
	@IBOutlet weak var tableView: UITableView!
	
	var weatherLocations: [WeatherLocation] = []
	var CELL_ID = "WeatherCell"
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.dataSource = self
		tableView.delegate = self
		
		generateDummyData()
	}
	
	
	func generateDummyData() {
		let omahaLocation = WeatherLocation(name: "Omaha", latitude: 193.44, longitude: 23.44)
		let denverLocation = WeatherLocation(name: "Denver", latitude: 220.44, longitude: 190.55)
		let austinLocation = WeatherLocation(name: "Austin", latitude: 330.45, longitude: 111.44)
		
		weatherLocations += [omahaLocation, denverLocation, austinLocation]
	}
	
	
	// MARK: - @IBAction methods
	
	@IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
		print("add button pressed")
	}
	
	
	@IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
		if tableView.isEditing {
			tableView.setEditing(false, animated: true)
			sender.title = "Edit"
			addBarButton.isEnabled = true
		}
		else {
			tableView.setEditing(true, animated: true)
			sender.title = "Done"
			addBarButton.isEnabled = false
		}
	}
	
	
}


// MARK: - UITableView Delegate and DataSource methods

extension LocationListViewController: UITableViewDelegate, UITableViewDataSource {
	
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return weatherLocations.count
	}
	
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID, for: indexPath)
		cell.textLabel?.text = "\(weatherLocations[indexPath.row].name), \(weatherLocations[indexPath.row].longitude), \(weatherLocations[indexPath.row].latitude)"
		return cell
	}
	
	
	func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		let weatherItem = weatherLocations[sourceIndexPath.row]
		weatherLocations.remove(at: sourceIndexPath.row)
		weatherLocations.insert(weatherItem, at: destinationIndexPath.row)
	}
	
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		weatherLocations.remove(at: indexPath.row)
		tableView.deleteRows(at: [indexPath], with: .automatic)
		
	}
	
}
