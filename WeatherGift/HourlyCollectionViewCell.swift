//
//  HourlyCollectionViewCell.swift
//  WeatherGift
//
//  Created by Kevin Watke on 3/11/22.
//

import UIKit

class HourlyCollectionViewCell: UICollectionViewCell {
    
	@IBOutlet weak var timeLabel: UILabel!
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var tempLabel: UILabel!
	
	
	
	var hourlyWeather: HourlyWeather! {
		didSet {
			let systemImage = WeatherDetail.getWeatherString(withId: hourlyWeather.id, withIcon: hourlyWeather.hourlyIcon)
			
			timeLabel.text = hourlyWeather.hour
			tempLabel.text = "\(hourlyWeather.hourlyTemperature)°"
			imageView.image = UIImage(systemName: systemImage)
		}
	}
}
