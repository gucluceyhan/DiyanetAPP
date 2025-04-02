import Foundation

struct User: Codable, Identifiable {
    let id: String
    let username: String
    let email: String
    let fullName: String
    let phoneNumber: String?
    let address: Address?
    let preferences: UserPreferences
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case email
        case fullName = "full_name"
        case phoneNumber = "phone_number"
        case address
        case preferences
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct Address: Codable {
    let street: String
    let city: String
    let state: String
    let country: String
    let postalCode: String
    
    enum CodingKeys: String, CodingKey {
        case street
        case city
        case state
        case country
        case postalCode = "postal_code"
    }
}

struct UserPreferences: Codable {
    var notificationsEnabled: Bool
    var darkModeEnabled: Bool
    var language: String
    var prayerReminders: Bool
    var quranReadingGoal: Int?
    
    enum CodingKeys: String, CodingKey {
        case notificationsEnabled = "notifications_enabled"
        case darkModeEnabled = "dark_mode_enabled"
        case language
        case prayerReminders = "prayer_reminders"
        case quranReadingGoal = "quran_reading_goal"
    }
} 