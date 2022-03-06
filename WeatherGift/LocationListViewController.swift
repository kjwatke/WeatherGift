//
//  LocationListViewController.swift
//  WeatherGift
//
//  Created by Kevin Watke on 3/4/22.
//

import UIKit
import GooglePlaces

class LocationListViewController: UIViewController {

	@IBOutlet weak var editBarButton: UIBarButtonItem!
	@IBOutlet weak var addBarButton: UIBarButtonItem!
	@IBOutlet weak var tableView: UITableView!
	
	var weatherLocations: [WeatherLocation] = []
	var selectedLocationIndex = 0
	let CELL_ID = "WeatherCell"
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.dataSource = self
		tableView.delegate = self
	}
	
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		selectedLocationIndex = tableView.indexPathForSelectedRow!.row
		saveLocations()
	}
	
	
	func saveLocations() {
		let encoder = JSONEncoder()
		
		if let encoded = try? encoder.encode(weatherLocations) {
			UserDefaults.standard.set(encoded, forKey: "weatherLocations")
		}
		else {
			print("Error saving locations")
		}
	}
	
	
		// MARK: - @IBAction methods
	
	@IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
		let autocompleteController = GMSAutocompleteViewController()
		autocompleteController.delegate = self
		
		present(autocompleteController, animated: true, completion: nil)
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
		let lat = weatherLocations[indexPath.row].latitude
		let long = weatherLocations[indexPath.row].longitude
		
		cell.textLabel?.text = weatherLocations[indexPath.row].name
		cell.detailTextLabel?.text = "Lat:\(lat), Long:\(long)"
		
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


extension LocationListViewController: GMSAutocompleteViewControllerDelegate {
	
	// Handle the user's selection.
	func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
		let newLocation = WeatherLocation(name: place.name ?? "unknown", latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
		weatherLocations.append(newLocation)
		tableView.reloadData()
		
		dismiss(animated: true, completion: nil)
	}
	
	func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
		// TODO: handle the error.
		print("Error: ", error.localizedDescription)
	}
	
	// User canceled the operation.
	func wasCancelled(_ viewController: GMSAutocompleteViewController) {
		dismiss(animated: true, completion: nil)
	}

	
}
