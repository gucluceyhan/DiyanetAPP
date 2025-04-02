import Foundation

struct Prayer: Codable, Identifiable {
    let id: String
    let name: String
    let arabicName: String
    let time: Date
    let type: PrayerType
    let location: Location
    let isCompleted: Bool
    let reminderEnabled: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case arabicName = "arabic_name"
        case time
        case type
        case location
        case isCompleted = "is_completed"
        case reminderEnabled = "reminder_enabled"
    }
}

enum PrayerType: String, Codable {
    case fajr = "FAJR"
    case sunrise = "SUNRISE"
    case dhuhr = "DHUHR"
    case asr = "ASR"
    case maghrib = "MAGHRIB"
    case isha = "ISHA"
}

struct Location: Codable {
    let latitude: Double
    let longitude: Double
    let city: String
    let country: String
    let timezone: String
    
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case city
        case country
        case timezone
    }
}

struct PrayerTimes: Codable {
    let date: Date
    let fajr: Date
    let sunrise: Date
    let dhuhr: Date
    let asr: Date
    let maghrib: Date
    let isha: Date
    let location: Location
    
    enum CodingKeys: String, CodingKey {
        case date
        case fajr
        case sunrise
        case dhuhr
        case asr
        case maghrib
        case isha
        case location
    }
} 