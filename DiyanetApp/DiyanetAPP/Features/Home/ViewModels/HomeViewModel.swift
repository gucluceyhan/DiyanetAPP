import Foundation
import Combine
import CoreLocation
import MapKit

class HomeViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var prayerTimes: PrayerTimes?
    @Published var nearbyMosques: [Mosque] = []
    @Published var featuredGuides: [Guide] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var userLocation: CLLocation?
    
    private let locationManager = CLLocationManager()
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        setupLocationManager()
        fetchData()
    }
    
    func refreshData() {
        fetchData()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    private func fetchData() {
        isLoading = true
        error = nil
        
        // Namaz vakitlerini çek
        fetchPrayerTimes()
        
        // Öne çıkan rehberleri çek
        fetchFeaturedGuides()
        
        // Normal bir durumda API çağrıları yapılır, şimdilik gecikme ekliyoruz
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
        }
    }
    
    private func fetchPrayerTimes() {
        // Namaz vakitleri
        let calendar = Calendar.current
        let baseDate = calendar.startOfDay(for: Date())
        
        prayerTimes = PrayerTimes(
            id: UUID().uuidString,
            location: Location(
                latitude: userLocation?.coordinate.latitude ?? 41.0082,
                longitude: userLocation?.coordinate.longitude ?? 28.9784,
                city: "İstanbul", // İdeal olarak ters geocoding ile alınır
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
    }
    
    private func fetchNearbyMosques() {
        guard let userLocation = userLocation else {
            // Kullanıcı konumu yoksa varsayılan camileri göster
            generateMockMosques()
            return
        }
        
        // Gerçek bir uygulamada burada API çağrısı yapılır
        // Örneğin:
        // let endpoint = "https://api.diyanet.gov.tr/mosques/nearby?lat=\(userLocation.coordinate.latitude)&lng=\(userLocation.coordinate.longitude)&radius=5000"
        
        // Şimdilik mock veri kullanıyoruz, ama kullanıcının konumuna yakın camileri simüle ediyoruz
        let userCoordinate = userLocation.coordinate
        
        // Yakındaki cami konumları oluştur (kullanıcıya yakın rastgele konumlar)
        let mosque1Coordinate = CLLocationCoordinate2D(
            latitude: userCoordinate.latitude + (Double.random(in: 0.001...0.005) * (Bool.random() ? 1 : -1)),
            longitude: userCoordinate.longitude + (Double.random(in: 0.001...0.005) * (Bool.random() ? 1 : -1))
        )
        
        let mosque2Coordinate = CLLocationCoordinate2D(
            latitude: userCoordinate.latitude + (Double.random(in: 0.001...0.005) * (Bool.random() ? 1 : -1)),
            longitude: userCoordinate.longitude + (Double.random(in: 0.001...0.005) * (Bool.random() ? 1 : -1))
        )
        
        let mosque3Coordinate = CLLocationCoordinate2D(
            latitude: userCoordinate.latitude + (Double.random(in: 0.001...0.005) * (Bool.random() ? 1 : -1)),
            longitude: userCoordinate.longitude + (Double.random(in: 0.001...0.005) * (Bool.random() ? 1 : -1))
        )
        
        // Cami konumundan kullanıcı konumuna olan mesafeyi hesapla
        let mosque1Location = CLLocation(latitude: mosque1Coordinate.latitude, longitude: mosque1Coordinate.longitude)
        let mosque2Location = CLLocation(latitude: mosque2Coordinate.latitude, longitude: mosque2Coordinate.longitude)
        let mosque3Location = CLLocation(latitude: mosque3Coordinate.latitude, longitude: mosque3Coordinate.longitude)
        
        let mosque1Distance = userLocation.distance(from: mosque1Location)
        let mosque2Distance = userLocation.distance(from: mosque2Location)
        let mosque3Distance = userLocation.distance(from: mosque3Location)
        
        // Cami nesnelerini oluştur
        let mosque1 = Mosque(
            id: "1",
            name: "Merkez Camii",
            arabicName: "جامع المركز",
            location: MosqueLocation(
                coordinates: mosque1Coordinate,
                type: "Point"
            ),
            address: MosqueAddress(
                street: "Merkez Mah.",
                city: "İstanbul",
                state: "İstanbul",
                country: "Türkiye",
                postalCode: "34100",
                formattedAddress: "\(Int(mosque1Distance)) metre uzaklıkta"
            ),
            contact: nil,
            services: MosqueServices(
                hasFridayPrayer: true,
                hasWuduFacilities: true,
                hasParking: true,
                hasWomenSection: true,
                hasWheelchairAccess: true,
                hasAirConditioning: true,
                hasHeating: true,
                hasLibrary: false,
                hasQuranClasses: true
            ),
            images: nil,
            rating: 4.7,
            reviewCount: 120,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        let mosque2 = Mosque(
            id: "2",
            name: "Yeni Camii",
            arabicName: "الجامع الجديد",
            location: MosqueLocation(
                coordinates: mosque2Coordinate,
                type: "Point"
            ),
            address: MosqueAddress(
                street: "Yeni Mah.",
                city: "İstanbul",
                state: "İstanbul",
                country: "Türkiye",
                postalCode: "34100",
                formattedAddress: "\(Int(mosque2Distance)) metre uzaklıkta"
            ),
            contact: nil,
            services: MosqueServices(
                hasFridayPrayer: true,
                hasWuduFacilities: true,
                hasParking: false,
                hasWomenSection: true,
                hasWheelchairAccess: false,
                hasAirConditioning: false,
                hasHeating: true,
                hasLibrary: false,
                hasQuranClasses: true
            ),
            images: nil,
            rating: 4.5,
            reviewCount: 85,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        let mosque3 = Mosque(
            id: "3",
            name: "Fatih Camii",
            arabicName: "جامع الفاتح",
            location: MosqueLocation(
                coordinates: mosque3Coordinate,
                type: "Point"
            ),
            address: MosqueAddress(
                street: "Fatih Mah.",
                city: "İstanbul",
                state: "İstanbul",
                country: "Türkiye",
                postalCode: "34100",
                formattedAddress: "\(Int(mosque3Distance)) metre uzaklıkta"
            ),
            contact: nil,
            services: MosqueServices(
                hasFridayPrayer: true,
                hasWuduFacilities: true,
                hasParking: true,
                hasWomenSection: true,
                hasWheelchairAccess: true,
                hasAirConditioning: true,
                hasHeating: true,
                hasLibrary: true,
                hasQuranClasses: true
            ),
            images: nil,
            rating: 4.9,
            reviewCount: 210,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        // Mesafeye göre sırala ve yakınımdaki camiler listesini güncelle
        nearbyMosques = [mosque1, mosque2, mosque3].sorted { m1, m2 in
            let m1Location = CLLocation(latitude: m1.location.coordinates.latitude, longitude: m1.location.coordinates.longitude)
            let m2Location = CLLocation(latitude: m2.location.coordinates.latitude, longitude: m2.location.coordinates.longitude)
            return userLocation.distance(from: m1Location) < userLocation.distance(from: m2Location)
        }
    }
    
    private func fetchFeaturedGuides() {
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
    
    private func generateMockMosques() {
        // Yakındaki camiler
        nearbyMosques = [
            Mosque(
                id: "1",
                name: "Süleymaniye Camii",
                arabicName: "جامع السليمانية",
                location: MosqueLocation(
                    coordinates: CLLocationCoordinate2D(latitude: 41.0165, longitude: 28.9639),
                    type: "Point"
                ),
                address: MosqueAddress(
                    street: "Süleymaniye Mah.",
                    city: "İstanbul",
                    state: "Fatih",
                    country: "Türkiye",
                    postalCode: "34116",
                    formattedAddress: "Süleymaniye Mah., Fatih, İstanbul"
                ),
                contact: nil,
                services: MosqueServices(
                    hasFridayPrayer: true,
                    hasWuduFacilities: true,
                    hasParking: true,
                    hasWomenSection: true,
                    hasWheelchairAccess: true,
                    hasAirConditioning: true,
                    hasHeating: true,
                    hasLibrary: true,
                    hasQuranClasses: true
                ),
                images: nil,
                rating: 4.8,
                reviewCount: 1250,
                createdAt: Date(),
                updatedAt: Date()
            ),
            Mosque(
                id: "2",
                name: "Sultan Ahmet Camii",
                arabicName: "جامع السلطان أحمد",
                location: MosqueLocation(
                    coordinates: CLLocationCoordinate2D(latitude: 41.0054, longitude: 28.9768),
                    type: "Point"
                ),
                address: MosqueAddress(
                    street: "Sultan Ahmet Mah.",
                    city: "İstanbul",
                    state: "Fatih",
                    country: "Türkiye",
                    postalCode: "34122",
                    formattedAddress: "Sultan Ahmet Mah., Fatih, İstanbul"
                ),
                contact: nil,
                services: MosqueServices(
                    hasFridayPrayer: true,
                    hasWuduFacilities: true,
                    hasParking: true,
                    hasWomenSection: true,
                    hasWheelchairAccess: true,
                    hasAirConditioning: true,
                    hasHeating: true,
                    hasLibrary: true,
                    hasQuranClasses: true
                ),
                images: nil,
                rating: 4.9,
                reviewCount: 2500,
                createdAt: Date(),
                updatedAt: Date()
            )
        ]
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location
        
        // Konum güncellendiğinde yakınımdaki camileri yeniden çek
        fetchNearbyMosques()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.error = "Konum alınamadı: \(error.localizedDescription)"
        generateMockMosques()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            error = "Konum izni reddedildi. Lütfen ayarlardan konum iznini etkinleştirin."
            generateMockMosques()
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
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
    let arabicName: String
    let location: MosqueLocation
    let address: MosqueAddress
    let contact: String?
    let services: MosqueServices
    let images: [String]?
    let rating: Double
    let reviewCount: Int
    let createdAt: Date
    let updatedAt: Date
}

struct MosqueLocation {
    let coordinates: CLLocationCoordinate2D
    let type: String
}

struct MosqueAddress {
    let street: String
    let city: String
    let state: String
    let country: String
    let postalCode: String
    let formattedAddress: String
}

struct MosqueServices {
    let hasFridayPrayer: Bool
    let hasWuduFacilities: Bool
    let hasParking: Bool
    let hasWomenSection: Bool
    let hasWheelchairAccess: Bool
    let hasAirConditioning: Bool
    let hasHeating: Bool
    let hasLibrary: Bool
    let hasQuranClasses: Bool
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