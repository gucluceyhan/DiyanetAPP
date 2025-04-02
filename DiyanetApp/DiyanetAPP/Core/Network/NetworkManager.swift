import Foundation
import Combine

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    private let baseURL = "https://api.example.com"
    
    func getPrayerTimes(lat: Double, lng: Double, date: Date) -> AnyPublisher<PrayerTimes, Error> {
        // Gerçek uygulamada API çağrısı yapılır
        // Şimdilik sahte veri döndürelim
        return Just(generateMockPrayerTimes(lat: lat, lng: lng, date: date))
            .setFailureType(to: Error.self)
            .delay(for: 1.5, scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func getNearbyMosques(lat: Double, lng: Double, radius: Int = 5000) -> AnyPublisher<[Mosque], Error> {
        // Gerçek uygulamada API çağrısı yapılır
        // Şimdilik sahte veri döndürelim
        return Just(generateMockMosques())
            .setFailureType(to: Error.self)
            .delay(for: 1.5, scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func getFeaturedGuides() -> AnyPublisher<[Guide], Error> {
        // Gerçek uygulamada API çağrısı yapılır
        // Şimdilik sahte veri döndürelim
        return Just(generateMockGuides())
            .setFailureType(to: Error.self)
            .delay(for: 1.5, scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Mock Data Generators
    private func generateMockPrayerTimes(lat: Double, lng: Double, date: Date) -> PrayerTimes {
        let calendar = Calendar.current
        let baseDate = calendar.startOfDay(for: date)
        
        return PrayerTimes(
            id: UUID().uuidString,
            location: Location(
                latitude: lat,
                longitude: lng,
                city: "İstanbul",
                country: "Türkiye"
            ),
            date: date,
            fajr: calendar.date(byAdding: .hour, value: 5, to: baseDate)!,
            sunrise: calendar.date(byAdding: .hour, value: 6, to: baseDate)!,
            dhuhr: calendar.date(byAdding: .hour, value: 12, to: baseDate)!,
            asr: calendar.date(byAdding: .hour, value: 15, to: baseDate)!,
            maghrib: calendar.date(byAdding: .hour, value: 18, to: baseDate)!,
            isha: calendar.date(byAdding: .hour, value: 20, to: baseDate)!
        )
    }
    
    private func generateMockMosques() -> [Mosque] {
        return [
            Mosque(
                id: "1",
                name: "Süleymaniye Camii",
                location: Location(
                    latitude: 41.0165,
                    longitude: 28.9639,
                    city: "İstanbul",
                    country: "Türkiye"
                ),
                address: Address(
                    street: "Süleymaniye Mah.",
                    district: "Fatih",
                    city: "İstanbul",
                    postalCode: "34116",
                    country: "Türkiye",
                    formattedAddress: "Süleymaniye Mah., Fatih, İstanbul"
                ),
                services: ["namaz", "eğitim", "dini sohbet"],
                rating: 4.8,
                reviewCount: 1250
            ),
            Mosque(
                id: "2",
                name: "Sultan Ahmet Camii",
                location: Location(
                    latitude: 41.0054,
                    longitude: 28.9768,
                    city: "İstanbul",
                    country: "Türkiye"
                ),
                address: Address(
                    street: "Sultan Ahmet Mah.",
                    district: "Fatih",
                    city: "İstanbul",
                    postalCode: "34122",
                    country: "Türkiye",
                    formattedAddress: "Sultan Ahmet Mah., Fatih, İstanbul"
                ),
                services: ["namaz", "turist rehberliği", "müze"],
                rating: 4.9,
                reviewCount: 2500
            )
        ]
    }
    
    private func generateMockGuides() -> [Guide] {
        return [
            Guide(
                id: "1",
                title: "Namaz Nasıl Kılınır?",
                description: "Namazın kılınışı, şartları ve çeşitleri hakkında kapsamlı bir rehber.",
                content: "Namaz, İslam'ın beş şartından biridir ve günde beş vakit olarak kılınır...",
                author: "İmam Ahmet Yılmaz",
                category: .worship,
                tags: ["namaz", "ibadet", "abdest"],
                readTime: 15,
                createdAt: Date().addingTimeInterval(-86400 * 7),
                updatedAt: Date().addingTimeInterval(-86400),
                isBookmarked: false
            ),
            Guide(
                id: "2",
                title: "Ramazan Ayı Hazırlıkları",
                description: "Ramazan ayı için ruhsal ve fiziksel hazırlık önerileri.",
                content: "Ramazan ayı, Müslümanlar için en kutsal aylardan biridir...",
                author: "Dr. Mehmet Kartal",
                category: .holiday,
                tags: ["ramazan", "oruç", "iftar"],
                readTime: 10,
                createdAt: Date().addingTimeInterval(-86400 * 14),
                updatedAt: Date().addingTimeInterval(-86400 * 2),
                isBookmarked: true
            ),
            Guide(
                id: "3",
                title: "Kuran-ı Kerim'i Doğru Okuma Teknikleri",
                description: "Tecvid kuralları ve Kuran okuma yöntemleri hakkında bilgiler.",
                content: "Kuran-ı Kerim'i tecvid kurallarına uygun okumak önemlidir...",
                author: "Hafız Ahmet Kaya",
                category: .education,
                tags: ["kuran", "tecvid", "okuma"],
                readTime: 20,
                createdAt: Date().addingTimeInterval(-86400 * 30),
                updatedAt: Date().addingTimeInterval(-86400 * 5),
                isBookmarked: false
            )
        ]
    }
}

// MARK: - Models
struct PrayerTimes: Identifiable {
    let id: String
    let location: Location
    let date: Date
    let fajr: Date
    let sunrise: Date
    let dhuhr: Date
    let asr: Date
    let maghrib: Date
    let isha: Date
}

struct Location {
    let latitude: Double
    let longitude: Double
    let city: String
    let country: String
}

struct Mosque: Identifiable {
    let id: String
    let name: String
    let location: Location
    let address: Address
    let services: [String]
    let rating: Double?
    let reviewCount: Int
}

struct Address {
    let street: String
    let district: String
    let city: String
    let postalCode: String
    let country: String
    let formattedAddress: String
}

struct Guide: Identifiable {
    let id: String
    let title: String
    let description: String
    let content: String
    let author: String
    let category: GuideCategory
    let tags: [String]
    let readTime: Int
    let createdAt: Date
    let updatedAt: Date
    var isBookmarked: Bool
    var images: [String]? = nil
    var videoUrl: String? = nil
}

enum GuideCategory: String {
    case worship = "ibadet"
    case education = "eğitim"
    case history = "tarih"
    case holiday = "bayram"
    case family = "aile"
}

enum NetworkError: Error {
    case invalidResponse
    case invalidURL
    case decodingError
    case serverError
    case networkError
    case unknown
} 