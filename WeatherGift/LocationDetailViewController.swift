//
//  LocationDetailViewController.swift
//  WeatherGift
//
//  Created by Kevin Watke on 3/5/22.
//

import UIKit
import CoreLocation

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
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var collectionView: UICollectionView!
	
	var weatherDetail: WeatherDetail!
	var locationIndex = 0
	var CELL_ID = "DailyWeatherCell"
	var COLLECTION_CELL_ID = "HourlyCell"
	var dailyCellHeight: CGFloat = 80
	var locationManager: CLLocationManager!

	
	// MARK: - Lifecycle Methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		tableView.delegate = self
		tableView.dataSource = self
		collectionView.delegate = self
		collectionView.dataSource = self
		
		if locationIndex == 0 {
			getLocation()
		}
		
		updateUserInterface()
	}
	
	
	// MARK: - Private functions
	
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
				self.imageView.image = UIImage(systemName: "\(self.weatherDetail.dayIcon).fill")
				
				self.tableView.reloadData()
				self.collectionView.reloadData()
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


// MARK: - TableView Delegate and DataSource Methods

extension LocationDetailViewController: UITableViewDelegate, UITableViewDataSource {
	
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return weatherDetail.dailyWeatherData.count
	}
	
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID, for: indexPath) as! DailyTableViewCell
		cell.dailyWeather = weatherDetail.dailyWeatherData[indexPath.row]
		
		return cell
	}
	
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return dailyCellHeight
	}
	
}


extension LocationDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return weatherDetail.hourlyWeatherData.count
	}
	
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let hourlyCell = collectionView.dequeueReusableCell(withReuseIdentifier: COLLECTION_CELL_ID, for: indexPath) as! HourlyCollectionViewCell
		hourlyCell.hourlyWeather = weatherDetail.hourlyWeatherData[indexPath.row]
		return hourlyCell
	}

	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: 70, height: 70)
	}
}


extension LocationDetailViewController: CLLocationManagerDelegate {
	
	// Creating a CLLocationManager will automatically check authorization
	func getLocation() {
		locationManager = CLLocationManager()
		locationManager.delegate = self
		
	}
	
	
	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		print("Checking authentication status.")
		handleAuthenticalStatus(status: manager.authorizationStatus)
	}
	
	
	func handleAuthenticalStatus(status: CLAuthorizationStatus) {
		
		switch status {
			case .notDetermined:
				locationManager.requestWhenInUseAuthorization()
			case .restricted:
				self.oneButtonAlert(
					title: "Location services denied",
					message: "It may be that parental controls are restricting location use in this app.")
			case .denied:
				break
			case .authorizedAlways, .authorizedWhenInUse:
				locationManager.requestLocation()
			case .authorized:
				break
			@unknown default:
				print("Developer alert, unknown status detected: \(status)")
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		
	}
	
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		let currentLocation = locations.last ?? CLLocation()
		let geocoder = CLGeocoder()
		
		geocoder.reverseGeocodeLocation(currentLocation) { placemarks, error in
			var locationName = ""
			
			if placemarks != nil {
				let placemark = placemarks?.last
				let city = placemark?.locality ?? "Unknown City"
				let state = placemark?.administrativeArea ?? "Unknown State"
				
				locationName = "\(city), \(state)"

			}
			else {
				print("Error: Retrieving place. Error code: \(error!)")
				locationName = "Could not find location"
			}
			
			let pageViewController = self.getRootViewControllerFromScene()
			
			pageViewController.weatherLocations[self.locationIndex].latitude = currentLocation.coordinate.latitude
			pageViewController.weatherLocations[self.locationIndex].longitude = currentLocation.coordinate.longitude
			pageViewController.weatherLocations[self.locationIndex].name = locationName
			
			self.updateUserInterface()
		}
	}
	
	
}
