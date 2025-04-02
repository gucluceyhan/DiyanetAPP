import Foundation
import Combine
import CoreLocation

class HomeViewModel: ObservableObject {
    @Published var prayerTimes: PrayerTimes?
    @Published var nearbyMosques: [Mosque] = []
    @Published var featuredGuides: [Guide] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let locationManager = CLLocationManager()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupLocationManager()
        fetchData()
    }
    
    func refreshData() {
        fetchData()
    }
    
    private func setupLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    private func fetchData() {
        isLoading = true
        error = nil
        
        // Sahte veri oluştur
        generateMockData()
        
        // Normal bir durumda API çağrıları yapılır, şimdilik gecikme ekliyoruz
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
        }
    }
    
    private func generateMockData() {
        // Namaz vakitleri
        let calendar = Calendar.current
        let baseDate = calendar.startOfDay(for: Date())
        
        prayerTimes = PrayerTimes(
            id: UUID().uuidString,
            location: Location(
                latitude: 41.0082,
                longitude: 28.9784,
                city: "İstanbul",
                country: "Türkiye"
            ),
            date: Date(),
            fajr: calendar.date(byAdding: .hour, value: 5, to: baseDate)!,
            sunrise: calendar.date(byAdding: .hour, value: 6, to: baseDate)!,
            dhuhr: calendar.date(byAdding: .hour, value: 12, to: baseDate)!,
            asr: calendar.date(byAdding: .hour, value: 15, to: baseDate)!,
            maghrib: calendar.date(byAdding: .hour, value: 18, to: baseDate)!,
            isha: calendar.date(byAdding: .hour, value: 20, to: baseDate)!
        )
        
        // Yakındaki camiler
        nearbyMosques = [
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
        
        // Öne çıkan rehberler
        featuredGuides = [
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

// MARK: - Preview Helpers

struct MosqueDetailView: View {
    let mosque: Mosque
    
    var body: some View {
        Text("Cami Detayları: \(mosque.name)")
    }
}

struct GuideDetailView: View {
    let guide: Guide
    
    var body: some View {
        Text("Rehber Detayları: \(guide.title)")
    }
} 