import Foundation
import SwiftUI

struct Guide: Identifiable {
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
    var isBookmarked: Bool
}

enum GuideCategory: String, CaseIterable {
    case PRAYER = "prayer"
    case FASTING = "fasting"
    case ZAKAT = "zakat"
    case PILGRIMAGE = "hac"
    case UMRAH = "umre"
    case JERUSALEM = "kudus"
    case FAMILY = "aile"
    case RAMADAN = "ramazan"
    case EDUCATION = "egitim"
    case HISTORY = "tarih"
    case OTHER = "diger"
    
    var title: String {
        switch self {
        case .PRAYER: return "Namaz"
        case .FASTING: return "Oruç"
        case .ZAKAT: return "Zekat"
        case .PILGRIMAGE: return "Hac"
        case .UMRAH: return "Umre"
        case .JERUSALEM: return "Kudüs"
        case .FAMILY: return "Aile"
        case .RAMADAN: return "Ramazan"
        case .EDUCATION: return "Eğitim"
        case .HISTORY: return "Tarih"
        case .OTHER: return "Diğer"
        }
    }
    
    var iconName: String {
        switch self {
        case .PRAYER: return "hands.sparkles"
        case .FASTING: return "moon.stars"
        case .ZAKAT: return "banknote"
        case .PILGRIMAGE: return "mappin.and.ellipse"
        case .UMRAH: return "figure.walk.motion"
        case .JERUSALEM: return "building.2"
        case .FAMILY: return "person.3"
        case .RAMADAN: return "star.and.crescent"
        case .EDUCATION: return "book"
        case .HISTORY: return "clock.arrow.circlepath"
        case .OTHER: return "doc.text"
        }
    }
}

struct Author {
    let name: String
    let imageUrl: String?
}

struct GuideImage {
    let url: String
    let caption: String?
} 