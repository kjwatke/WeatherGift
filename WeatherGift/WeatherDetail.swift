	//
	//  WeatherDetail.swift
	//  WeatherGift
	//
	//  Created by Kevin Watke on 3/6/22.
	//

import Foundation

private let dateFormatter: DateFormatter = {
	let dateFormatter = DateFormatter()
	dateFormatter.dateFormat = "EEEE"
	return dateFormatter
}()


private let hourFormatter: DateFormatter = {
	let hourFormatter = DateFormatter()
	hourFormatter.dateFormat = "ha"
	return hourFormatter
}()


struct DailyWeather {
	var dailyIcon: String
	var dailyWeekday: String
	var dailySummary: String
	var dailyHigh: Int
	var dailyLow: Int
	var id: Int
}


struct HourlyWeather {
	var hour: String
	var hourlyTemperature: Int
	var hourlyIcon: String
	var id: Int
}


class WeatherDetail: WeatherLocation {
	
	
	private struct Result: Codable {
		var timezone: String
		var current: Current
		var daily: [Daily]
		var hourly: [Hourly]
	}
	
	
	private struct Current: Codable {
		var dt: TimeInterval
		var temp: Double
		var weather: [Weather]
	}
	
	
	private struct Weather: Codable {
		var description: String
		var icon: String
		var id: Int
	}
	
	
	private struct Daily: Codable {
		var dt: TimeInterval
		var temp: Temp
		var weather: [Weather]
	}
	
	private struct Hourly: Codable {
		var dt: TimeInterval
		var temp: Double
		var weather: [Weather]
	}
	
	
	private struct Temp: Codable {
		var max: Double
		var min: Double
	}
	
	
	
	
	
	var timezone = ""
	var currentTime = 0.0
	var temperature = 0
	var summary = ""
	var dayIcon = ""
	var dailyWeatherData = [DailyWeather]()
	var hourlyWeatherData = [HourlyWeather]()
	
	
	func getData(completed: @escaping () -> () ) {
		let urlString = "https://api.openweathermap.org/data/2.5/onecall?lat=\(latitude)&lon=\(longitude)&exclude=minutely&units=imperial&appid=\(APIkeys.OPEN_WEATHER_KEY)"
		
			// Create a URL
		guard let url = URL(string: urlString) else {
			print("Error: Could not create a URL from \(urlString)")
			completed()
			return
		}
		
			// Create a Session
		let session = URLSession.shared
		
			// Get data with .dataTask method
		let task = session.dataTask(with: url) { data, response, error in
			if let error = error {
				print("Error: \(error.localizedDescription)")
			}
			
				// Deal with the data
			do {
				print("URL: \(url)")
				let result = try JSONDecoder().decode(Result.self, from: data!)
				self.timezone = result.timezone
				self.currentTime = result.current.dt
				self.temperature = Int(result.current.temp.rounded())
				self.summary = result.current.weather[0].description
				self.dayIcon = WeatherDetail.getWeatherString(
					withId: result.current.weather[0].id,
					withIcon: result.current.weather[0].icon
				)
				
				for index in 0..<result.daily.count {
					let weekdayDate = Date(timeIntervalSince1970: result.daily[index].dt)
					dateFormatter.timeZone = TimeZone(identifier: result.timezone)
					let dailyWeekday = dateFormatter.string(from: weekdayDate)
					let dailyIcon = WeatherDetail.getWeatherString(
						withId: result.daily[index].weather[0].id,
						withIcon: result.daily[index].weather[0].icon
					)
					let dailySummary = result.daily[index].weather[0].description
					let dailyHigh = Int(result.daily[index].temp.max.rounded())
					let dailyLow = Int(result.daily[index].temp.min.rounded())
					let id = result.daily[index].weather[0].id
					let dailyWeather = DailyWeather(dailyIcon: dailyIcon, dailyWeekday: dailyWeekday, dailySummary: dailySummary, dailyHigh: dailyHigh, dailyLow: dailyLow, id: id)
					
					self.dailyWeatherData.append(dailyWeather)
					
				}
				
					// Get no more than 24 hours of data
				let lastHour = min(24, result.hourly.count)
				
				if lastHour > 0 {
					for index in 1...lastHour {
						let hourlyDate = Date(timeIntervalSince1970: result.hourly[index].dt)
						hourFormatter.timeZone = TimeZone(identifier: result.timezone)
						
						let hour = hourFormatter.string(from: hourlyDate)
						let hourlyIcon = result.hourly[index].weather[0].icon
						let hourlyTemp = result.hourly[index].temp.rounded()
						let id = result.hourly[index].weather[0].id
						let hourlyWeatherItem = HourlyWeather(
							hour: hour,
							hourlyTemperature: Int(hourlyTemp),
							hourlyIcon: hourlyIcon,
							id: id
						)
						
						self.hourlyWeatherData.append(hourlyWeatherItem)
					}
				}
			} catch  {
				print("JSON Error: \(error)")
			}
			
			completed()
		}
		
		task.resume()
	}
	
	
	static func getWeatherString(withId id: Int, withIcon icon: String) -> String {
		switch id {
			case 200...299:
				return "cloud.bolt.rain"
			case 300...399:
				return "cloud.drizzle"
			case 500, 501, 520, 521, 531:
				return "cloud.rain"
			case 502, 503, 504, 522:
				return "cloud.heavyrain"
			case 511, 611...616:
				return "cloud.sleet"
			case 600...602, 620...622:
				return "snow"
			case 701, 711, 741:
				return "cloud.fog"
			case 721:
				return (icon.hasSuffix("d") ? "sun.haze" : "cloud.fog")
			case 731, 751, 761, 762:
				return (icon.hasSuffix("d") ? "sun.dust" : "cloud.fog")
			case 771:
				return "wind"
			case 800:
				return (icon.hasSuffix("d") ? "sun.max" : "moon")
			case 801, 802:
				return (icon.hasSuffix("d") ? "cloud.sun" : "cloud.moon")
			case 803, 804:
				return "cloud"
			default:
				return "cloud.sleet"
		}
	}
}
