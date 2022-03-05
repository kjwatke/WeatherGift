//
//  LocationDetailViewController.swift
//  WeatherGift
//
//  Created by Kevin Watke on 3/5/22.
//

import UIKit

class LocationDetailViewController: UIViewController {

	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var placeLabel: UILabel!
	@IBOutlet weak var temperatureLabel: UILabel!
	@IBOutlet weak var summaryLabel: UILabel!
	@IBOutlet weak var imageView: UIImageView!
	
	var weatherLocation: WeatherLocation!
	var weatherLocations = [WeatherLocation]()
	
	// MARK: - Lifecycle Methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
	
		if weatherLocation == nil {
			weatherLocation = WeatherLocation(name: "Current Location", latitude: 0.0, longitude: 0.0)
			weatherLocations.append(weatherLocation)
		}
		
		updateUserInterface()
	}
	
	
	func updateUserInterface() {
		dateLabel.text = "12/12/1212"
		placeLabel.text = weatherLocation.name
		temperatureLabel.text = "52°"
		summaryLabel.text = "Dummy Text"
	}

	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let destination = segue.destination as! LocationListViewController
		destination.weatherLocations = weatherLocations
	}
	
	
	// MARK: @IBAction Methods
	
	@IBAction func unwindFromLocationListViewController(segue: UIStoryboardSegue) {
		let source = segue.source as! LocationListViewController
		weatherLocations = source.weatherLocations
		weatherLocation = weatherLocations[source.selectedLocationIndex]
		print(weatherLocation)
		updateUserInterface()
	}
}