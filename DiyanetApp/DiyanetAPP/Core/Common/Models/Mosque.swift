import Foundation
import CoreLocation

struct Mosque: Codable, Identifiable {
    let id: String
    let name: String
    let arabicName: String?
    let location: MosqueLocation
    let address: MosqueAddress
    let contact: MosqueContact?
    let services: MosqueServices
    let images: [MosqueImage]?
    let rating: Double?
    let reviewCount: Int
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case arabicName = "arabic_name"
        case location
        case address
        case contact
        case services
        case images
        case rating
        case reviewCount = "review_count"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct MosqueLocation: Codable {
    let coordinates: CLLocationCoordinate2D
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case coordinates
        case type
    }
}

struct MosqueAddress: Codable {
    let street: String
    let city: String
    let state: String
    let country: String
    let postalCode: String
    let formattedAddress: String
    
    enum CodingKeys: String, CodingKey {
        case street
        case city
        case state
        case country
        case postalCode = "postal_code"
        case formattedAddress = "formatted_address"
    }
}

struct MosqueContact: Codable {
    let phone: String?
    let email: String?
    let website: String?
    let socialMedia: SocialMedia?
    
    enum CodingKeys: String, CodingKey {
        case phone
        case email
        case website
        case socialMedia = "social_media"
    }
}

struct SocialMedia: Codable {
    let facebook: String?
    let twitter: String?
    let instagram: String?
    let youtube: String?
}

struct MosqueServices: Codable {
    let hasFridayPrayer: Bool
    let hasWuduFacilities: Bool
    let hasParking: Bool
    let hasWomenSection: Bool
    let hasWheelchairAccess: Bool
    let hasAirConditioning: Bool
    let hasHeating: Bool
    let hasLibrary: Bool
    let hasQuranClasses: Bool
    
    enum CodingKeys: String, CodingKey {
        case hasFridayPrayer = "has_friday_prayer"
        case hasWuduFacilities = "has_wudu_facilities"
        case hasParking = "has_parking"
        case hasWomenSection = "has_women_section"
        case hasWheelchairAccess = "has_wheelchair_access"
        case hasAirConditioning = "has_air_conditioning"
        case hasHeating = "has_heating"
        case hasLibrary = "has_library"
        case hasQuranClasses = "has_quran_classes"
    }
}

struct MosqueImage: Codable, Identifiable {
    let id: String
    let url: String
    let type: ImageType
    let caption: String?
    let uploadedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case url
        case type
        case caption
        case uploadedAt = "uploaded_at"
    }
}

enum ImageType: String, Codable {
    case exterior = "EXTERIOR"
    case interior = "INTERIOR"
    case minaret = "MINARET"
    case dome = "DOME"
    case other = "OTHER"
} 