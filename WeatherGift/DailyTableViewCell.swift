//
//  DailyTableViewCell.swift
//  WeatherGift
//
//  Created by Kevin Watke on 3/8/22.
//

import UIKit

class DailyTableViewCell: UITableViewCell {
	
	var dailyWeather: DailyWeather! {
		didSet {
			dailyImageView.image = UIImage(systemName: dailyWeather.dailyIcon)
			dailyWeekdayLabel.text = dailyWeather.dailyWeekday
			dailySummaryView.text = dailyWeather.dailySummary
			dailyHighLabel.text = String(dailyWeather.dailyHigh)
			dailyLowLabel.text = String(dailyWeather.dailyLow)
		}
	}
	
	@IBOutlet weak var dailyImageView: UIImageView!
	@IBOutlet weak var dailyWeekdayLabel: UILabel!
	@IBOutlet weak var dailySummaryView: UITextView!
	@IBOutlet weak var dailyHighLabel: UILabel!
	@IBOutlet weak var dailyLowLabel: UILabel!
	
	
}
