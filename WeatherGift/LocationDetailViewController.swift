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
	var locationIndex = 0
	
	// MARK: - Lifecycle Methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
	
		updateUserInterface()
	}
	
	func getRootViewControllerFromScene() -> PageViewController {
		let scenes = UIApplication.shared.connectedScenes
		let windowScenes = scenes.first as? UIWindowScene
		return (windowScenes?.windows.first!.rootViewController!)! as! PageViewController
	}
	
	func updateUserInterface() {
		let pageViewController = getRootViewControllerFromScene()
		
		weatherLocation = pageViewController.weatherLocations[locationIndex]
		dateLabel.text = "12/12/1212"
		placeLabel.text = weatherLocation.name
		temperatureLabel.text = "52°"
		summaryLabel.text = "Dummy Text"
	}

	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let destination = segue.destination as! LocationListViewController
		let pageViewController = getRootViewControllerFromScene()
		destination.weatherLocations = pageViewController.weatherLocations
	}
	
	
	// MARK: @IBAction Methods
	
	@IBAction func unwindFromLocationListViewController(segue: UIStoryboardSegue) {
		let source = segue.source as! LocationListViewController
		let pageViewController = getRootViewControllerFromScene()
		let viewControllerToPresent = pageViewController.createLocationDetailViewController(forPage: locationIndex)
		
		locationIndex = source.selectedLocationIndex
		pageViewController.weatherLocations = source.weatherLocations
		pageViewController.setViewControllers([viewControllerToPresent], direction: .forward, animated: false, completion: nil)
		
		updateUserInterface()
	}
}
