//
//  LocationDetailViewController.swift
//  WeatherGift
//
//  Created by Kevin Watke on 3/5/22.
//

import UIKit

class LocationDetailViewController: UIViewController {

	private let dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "EEEE, MMM d, h:mm aaa"
		return dateFormatter
	}()
	
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
				self.dateFormatter.timeZone = TimeZone(identifier: self.weatherDetail.timezone)
				let usableDate = Date(timeIntervalSince1970: self.weatherDetail.currentTime)
				self.dateLabel.text = self.dateFormatter.string(from: usableDate)
				self.placeLabel.text = self.weatherDetail.name
				self.temperatureLabel.text = "\(self.weatherDetail.temperature)°"
				self.summaryLabel.text = self.weatherDetail.summary
				self.imageView.image = self.setWeatherPhoto(withIcon: self.weatherDetail.dailyIcon)
				print("iconCode: \(self.weatherDetail.dailyIcon) for location: \(self.weatherDetail.name)")
			}
		}
	}

	
	func setWeatherPhoto(withIcon icon: String) -> UIImage {
		switch icon {
			case "01d":
				return UIImage(systemName: "sun.max.fill")!
			case "01n":
				return UIImage(systemName: "moon.fill")!
			case "02d", "02n", "03d", "03n", "04d", "04n":
				return UIImage(systemName: "cloud.fill")!
			case "09d", "09n", "10d", "10n":
				return UIImage(systemName: "cloud.heavyrain.fill")!
			case "11d", "11n":
				return UIImage(systemName: "cloud.sun.bolt.fill")!
			case "13d", "13n":
				return UIImage(systemName: "cloud.snow.fill")!
			case "50d", "50n":
				return UIImage(systemName: "cloud.fog.fill")!
			default:
				return UIImage(systemName: "sun.max.fill")!
				
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
