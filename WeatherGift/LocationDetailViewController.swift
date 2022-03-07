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
	
	var weatherDetail: WeatherDetail!
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
		
		let weatherLocation = pageViewController.weatherLocations[locationIndex]
		weatherDetail = WeatherDetail(name: weatherLocation.name, latitude: weatherLocation.latitude, longitude: weatherLocation.longitude)
		
		weatherDetail.getData { [weak self] in
			guard let self = self else { return }
			
			DispatchQueue.main.async {
				self.dateLabel.text = self.weatherDetail.timezone
				self.placeLabel.text = self.weatherDetail.name
				self.temperatureLabel.text = "\(self.weatherDetail.temperature)°"
				self.summaryLabel.text = self.weatherDetail.summary
			}
		}
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
