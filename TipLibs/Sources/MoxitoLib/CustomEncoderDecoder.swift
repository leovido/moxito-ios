import Foundation

public enum CustomDecoderAndEncoder {
	public static var decoder: JSONDecoder {
		let formatter = DateFormatter()
		formatter.calendar = Calendar(identifier: .iso8601)
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.timeZone = TimeZone(secondsFromGMT: 0)
		
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
			let container = try decoder.singleValueContainer()
			let dateStr = try container.decode(String.self)
			
			formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
			if let date = formatter.date(from: dateStr) {
				return date
			}
			formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
			if let date = formatter.date(from: dateStr) {
				return date
			}
			fatalError()
		})
		
		return decoder
	}
	
	public static var encoder: JSONEncoder {
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .iso8601
		
		return encoder
	}
}
