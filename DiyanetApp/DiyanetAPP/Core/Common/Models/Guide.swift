import Foundation

struct Guide: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let content: String
    let category: GuideCategory
    let author: Author
    let tags: [String]
    let images: [GuideImage]?
    let videoUrl: String?
    let readTime: Int
    let createdAt: Date
    let updatedAt: Date
    let isBookmarked: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case content
        case category
        case author
        case tags
        case images
        case videoUrl = "video_url"
        case readTime = "read_time"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case isBookmarked = "is_bookmarked"
    }
}

enum GuideCategory: String, Codable {
    case prayer = "PRAYER"
    case fasting = "FASTING"
    case zakat = "ZAKAT"
    case hajj = "HAJJ"
    case quran = "QURAN"
    case hadith = "HADITH"
    case lifestyle = "LIFESTYLE"
    case family = "FAMILY"
    case other = "OTHER"
}

struct Author: Codable, Identifiable {
    let id: String
    let name: String
    let title: String?
    let bio: String?
    let avatarUrl: String?
    let socialMedia: AuthorSocialMedia?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case title
        case bio
        case avatarUrl = "avatar_url"
        case socialMedia = "social_media"
    }
}

struct AuthorSocialMedia: Codable {
    let twitter: String?
    let linkedin: String?
    let website: String?
}

struct GuideImage: Codable, Identifiable {
    let id: String
    let url: String
    let caption: String?
    let altText: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case url
        case caption
        case altText = "alt_text"
    }
} 