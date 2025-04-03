//
//  DiyanetAPPApp.swift
//  DiyanetAPP
//
//  Created by Güçlü Ceyhan on 4/2/25.
//

import SwiftUI
import Foundation
import CoreLocation
import Combine
import MapKit

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
    
    // İki konum arasındaki mesafeyi hesapla (km cinsinden)
    func distance(to location: Location) -> Double {
        let from = CLLocation(latitude: latitude, longitude: longitude)
        let to = CLLocation(latitude: location.latitude, longitude: location.longitude)
        return from.distance(from: to) / 1000.0 // metre -> km
    }
}

struct Mosque: Identifiable {
    let id: String
    let name: String
    let location: Location
    let address: Address
    let services: [String]
    let rating: Double?
    let reviewCount: Int
    var distance: Double? = nil // Kullanıcı konumuna olan mesafe (km)
    
    // Kullanıcı konumuna göre mesafe formatı
    var formattedDistance: String {
        guard let distance = distance else {
            return ""
        }
        
        if distance < 1.0 {
            return "\(Int(distance * 1000)) metre mesafede"
        } else {
            return String(format: "%.1f km mesafede", distance)
        }
    }
}

struct Address {
    let street: String
    let district: String
    let city: String
    let postalCode: String
    let country: String
    let formattedAddress: String
}

// NOT: Guide modelini burada tekrar tanımlamıyoruz, Core/Common/Models/Guide.swift dosyasında tanımlanmıştır

// HomeViewModel için geçici basit rehber modeli
struct HomeGuide: Identifiable {
    let id: String
    let title: String
    let description: String
    let content: String
    let author: String
    let category: String
    let tags: [String]
    let readTime: Int
    let createdAt: Date
    let updatedAt: Date
    var isBookmarked: Bool
}

// MARK: - View Models

class HomeViewModel: NSObject, ObservableObject {
    @Published var prayerTimes: PrayerTimes?
    @Published var nearbyMosques: [Mosque] = []
    @Published var featuredGuides: [HomeGuide] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var currentLocation: CLLocation?
    @Published var locationAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    
    private let locationManager = CLLocationManager()
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        setupLocationManager()
        fetchFeaturedGuides() // Bunlar konum gerekmediği için hemen yükleyebiliriz
    }
    
    func refreshData() {
        isLoading = true
        error = nil
        
        // Konum servislerini sıfırla ve yeniden başlat
        if CLLocationManager.locationServicesEnabled() &&
            (locationAuthorizationStatus == .authorizedWhenInUse || 
             locationAuthorizationStatus == .authorizedAlways) {
            
            // Mevcut konumu temizle ve yeniden alma işlemini başlat
            currentLocation = nil
            locationManager.stopUpdatingLocation()
            locationManager.startUpdatingLocation()
            
            // 10 saniye sonra hala konum alınamadıysa varsayılan konuma geç
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { [weak self] in
                guard let self = self else { return }
                if self.currentLocation == nil && !self.isLoading {
                    self.error = "Konum alınamadı, varsayılan konum kullanılıyor."
                    // İstanbul'un konumunu varsayılan olarak kullan
                    let defaultLocation = CLLocation(latitude: 41.0082, longitude: 28.9784)
                    self.fetchPrayerTimes(for: defaultLocation)
                    self.fetchNearbyMosques(near: defaultLocation)
                    self.isLoading = false
                }
            }
        } else {
            fetchData()
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 500 // 500 metre aralıklarla konum güncellemesi al
        
        // Konum izin durumunu kontrol et
        locationAuthorizationStatus = locationManager.authorizationStatus
        
        // Konum servislerinin etkin olup olmadığını kontrol et
        if !CLLocationManager.locationServicesEnabled() {
            error = "Konum servisleri kapalı. Lütfen cihaz ayarlarınızdan konum servislerini etkinleştirin."
            // Varsayılan konum kullan
            let defaultLocation = CLLocation(latitude: 41.0082, longitude: 28.9784)
            fetchPrayerTimes(for: defaultLocation)
            fetchNearbyMosques(near: defaultLocation)
            return
        }
        
        // Konum izni istenmediyse, iste
        if locationAuthorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if locationAuthorizationStatus == .authorizedWhenInUse || 
                  locationAuthorizationStatus == .authorizedAlways {
            locationManager.startUpdatingLocation()
            
            // 5 saniye sonra hala konum almadıysak, varsayılan konum kullanılıyor
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
                guard let self = self else { return }
                if self.currentLocation == nil {
                    self.error = "Konum bilginiz alınamadı. Varsayılan konum kullanılıyor."
                    let defaultLocation = CLLocation(latitude: 41.0082, longitude: 28.9784)
                    self.fetchPrayerTimes(for: defaultLocation)
                    self.fetchNearbyMosques(near: defaultLocation)
                }
            }
        }
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func fetchData() {
        isLoading = true
        error = nil
        
        if let location = currentLocation {
            fetchPrayerTimes(for: location)
            fetchNearbyMosques(near: location)
        } else {
            // Eğer konum yoksa, kullanıcıdan izin iste veya varsayılan konum kullan
            if locationAuthorizationStatus == .denied || locationAuthorizationStatus == .restricted {
                error = "Konum izni verilmedi. Namaz vakitleri ve yakındaki camiler konum bilgisi olmadan gösterilemiyor."
                // İstanbul'un konumunu varsayılan olarak kullan
                let defaultLocation = CLLocation(latitude: 41.0082, longitude: 28.9784)
                fetchPrayerTimes(for: defaultLocation)
                fetchNearbyMosques(near: defaultLocation)
            } else {
                // Konum alınmaya çalışılıyor olabilir, bir hata mesajı göster
                error = "Konum bilgisi alınıyor. Lütfen bekleyin."
            }
        }
        
        // Normal bir durumda API çağrıları yapılır, şimdilik gecikme ekliyoruz
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
        }
    }
    
    private func fetchPrayerTimes(for location: CLLocation) {
        // API'den namaz vakitlerini çekmek yerine şimdilik sahte veri kullanıyoruz
        // Gerçek API entegrasyonu için burayı değiştirmek gerekiyor
        
        // Geocoder ile konum adını bul
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            
            if let error = error {
                self.error = "Konum adı alınamadı: \(error.localizedDescription)"
                return
            }
            
            if let placemark = placemarks?.first, 
               let city = placemark.locality,
               let country = placemark.country {
                
                let calendar = Calendar.current
                let baseDate = calendar.startOfDay(for: Date())
                
                self.prayerTimes = PrayerTimes(
                    id: UUID().uuidString,
                    location: Location(
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude,
                        city: city,
                        country: country
                    ),
                    date: Date(),
                    fajr: calendar.date(byAdding: .hour, value: 5, to: baseDate)!,
                    sunrise: calendar.date(byAdding: .hour, value: 6, to: baseDate)!,
                    dhuhr: calendar.date(byAdding: .hour, value: 12, to: baseDate)!,
                    asr: calendar.date(byAdding: .hour, value: 15, to: baseDate)!,
                    maghrib: calendar.date(byAdding: .hour, value: 18, to: baseDate)!,
                    isha: calendar.date(byAdding: .hour, value: 20, to: baseDate)!
                )
            } else {
                self.error = "Konum bilgisi çözümlenemedi"
            }
        }
    }
    
    private func fetchNearbyMosques(near location: CLLocation) {
        // API'den yakındaki camileri çekmek yerine şimdilik sahte veri kullanıyoruz
        // Gerçek API entegrasyonu için burayı değiştirmek gerekiyor
        
        // Geocoder ile konum adını bul
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            
            if let error = error {
                self.error = "Konum adı alınamadı: \(error.localizedDescription)"
                return
            }
            
            if let placemark = placemarks?.first, 
               let city = placemark.locality ?? placemark.administrativeArea,
               let country = placemark.country {
                
                // Gerçek yakındaki cami konumları (daha gerçekçi veriler)
                // Kullanıcının etrafında rastgele cami konumları oluşturuyoruz
                let userLocation = Location(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude,
                    city: city,
                    country: country
                )
                
                // İstanbul'daki önemli camileri getirelim (gerçek koordinatlar)
                var mosques: [Mosque] = [
                    // Süleymaniye Camii (gerçek konum)
                    createMosque(
                        id: "1",
                        name: "Süleymaniye Camii",
                        latitude: 41.0165,
                        longitude: 28.9639,
                        city: "İstanbul",
                        country: "Türkiye",
                        district: "Fatih",
                        services: ["namaz", "eğitim", "dini sohbet", "turist ziyareti"],
                        rating: 4.8,
                        reviewCount: 1250,
                        userLocation: userLocation
                    ),
                    
                    // Sultan Ahmet Camii (gerçek konum)
                    createMosque(
                        id: "2",
                        name: "Sultan Ahmet Camii",
                        latitude: 41.0054,
                        longitude: 28.9768,
                        city: "İstanbul",
                        country: "Türkiye",
                        district: "Fatih",
                        services: ["namaz", "turist rehberliği", "müze"],
                        rating: 4.9,
                        reviewCount: 2500,
                        userLocation: userLocation
                    ),
                    
                    // Eyüp Sultan Camii (gerçek konum)
                    createMosque(
                        id: "3",
                        name: "Eyüp Sultan Camii",
                        latitude: 41.0481,
                        longitude: 28.9334,
                        city: "İstanbul",
                        country: "Türkiye",
                        district: "Eyüp",
                        services: ["namaz", "türbe", "dini sohbet"],
                        rating: 4.7,
                        reviewCount: 1850,
                        userLocation: userLocation
                    ),
                    
                    // Ortaköy Camii (gerçek konum)
                    createMosque(
                        id: "4",
                        name: "Ortaköy Camii",
                        latitude: 41.0471,
                        longitude: 29.0275,
                        city: "İstanbul",
                        country: "Türkiye",
                        district: "Beşiktaş",
                        services: ["namaz", "turistik gezi"],
                        rating: 4.6,
                        reviewCount: 1200,
                        userLocation: userLocation
                    ),
                    
                    // Kullanıcının yakınında birkaç yerel cami
                    createMosque(
                        id: "5",
                        name: "Yerel Merkez Camii",
                        latitude: location.coordinate.latitude + 0.005,
                        longitude: location.coordinate.longitude + 0.005,
                        city: city,
                        country: country,
                        district: placemark.subLocality ?? "Merkez",
                        services: ["namaz", "Kuran kursu"],
                        rating: 4.4,
                        reviewCount: 120,
                        userLocation: userLocation
                    ),
                    
                    createMosque(
                        id: "6",
                        name: "Mahalle Camii",
                        latitude: location.coordinate.latitude - 0.003,
                        longitude: location.coordinate.longitude - 0.002,
                        city: city,
                        country: country,
                        district: placemark.subLocality ?? "Mahalle",
                        services: ["namaz"],
                        rating: 4.3,
                        reviewCount: 85,
                        userLocation: userLocation
                    )
                ]
                
                // Camileri mesafeye göre sırala (en yakın önce)
                mosques.sort { (mosque1, mosque2) -> Bool in
                    guard let distance1 = mosque1.distance, let distance2 = mosque2.distance else {
                        return false
                    }
                    return distance1 < distance2
                }
                
                self.nearbyMosques = mosques
            } else {
                self.error = "Konum bilgisi çözümlenemedi"
            }
        }
    }
    
    // Yardımcı fonksiyon: Cami oluştur ve mesafeyi hesapla
    private func createMosque(id: String, name: String, latitude: Double, longitude: Double,
                              city: String, country: String, district: String, services: [String],
                              rating: Double, reviewCount: Int, userLocation: Location) -> Mosque {
        
        let location = Location(
            latitude: latitude,
            longitude: longitude,
            city: city,
            country: country
        )
        
        // Kullanıcı konumuna mesafeyi hesapla
        let distance = location.distance(to: userLocation)
        
        var formattedAddress = "\(district), \(city)"
        if city != userLocation.city {
            formattedAddress += ", \(country)"
        }
        
        let address = Address(
            street: "\(district) bölgesi",
            district: district,
            city: city,
            postalCode: "00000", // Bilinmiyor
            country: country,
            formattedAddress: formattedAddress
        )
        
        var mosque = Mosque(
            id: id,
            name: name,
            location: location,
            address: address,
            services: services,
            rating: rating,
            reviewCount: reviewCount
        )
        
        mosque.distance = distance
        return mosque
    }
    
    private func fetchFeaturedGuides() {
        // Öne çıkan rehberler
        featuredGuides = [
            HomeGuide(
                id: "1",
                title: "Namaz Nasıl Kılınır?",
                description: "Namazın kılınışı, şartları ve çeşitleri hakkında kapsamlı bir rehber.",
                content: "Namaz, İslam'ın beş şartından biridir ve günde beş vakit olarak kılınır...",
                author: "İmam Ahmet Yılmaz",
                category: "worship",
                tags: ["namaz", "ibadet", "abdest"],
                readTime: 15,
                createdAt: Date().addingTimeInterval(-86400 * 7),
                updatedAt: Date().addingTimeInterval(-86400),
                isBookmarked: false
            ),
            HomeGuide(
                id: "2",
                title: "Ramazan Ayı Hazırlıkları",
                description: "Ramazan ayı için ruhsal ve fiziksel hazırlık önerileri.",
                content: "Ramazan ayı, Müslümanlar için en kutsal aylardan biridir...",
                author: "Dr. Mehmet Kartal",
                category: "holiday",
                tags: ["ramazan", "oruç", "iftar"],
                readTime: 10,
                createdAt: Date().addingTimeInterval(-86400 * 14),
                updatedAt: Date().addingTimeInterval(-86400 * 2),
                isBookmarked: true
            )
        ]
    }
}

// MARK: - CLLocationManagerDelegate
extension HomeViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationAuthorizationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            error = "Konum izni reddedildi. Yakındaki camileri ve namaz vakitlerini görmek için konum izni gerekiyor."
            // Varsayılan bir konum kullanarak veri yükle (örn. İstanbul)
            let defaultLocation = CLLocation(latitude: 41.0082, longitude: 28.9784)
            fetchPrayerTimes(for: defaultLocation)
            fetchNearbyMosques(near: defaultLocation)
        case .notDetermined:
            // Belirlenmediğinde hiçbir şey yapma, kullanıcı izin isteyene kadar bekle
            break
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Geçersiz konumları filtrele (0,0 gibi)
        if location.coordinate.latitude == 0 && location.coordinate.longitude == 0 {
            return
        }
        
        // Konum güncellenince bildirilecek
        currentLocation = location
        
        // Konum almayı durdur (pil tasarrufu için)
        // Sürekli güncellemeler yerine tek bir konum alıyoruz
        manager.stopUpdatingLocation()
        
        // Konum bilgisi ile verileri yeniden yükle
        fetchPrayerTimes(for: location)
        fetchNearbyMosques(near: location)
        
        // Hata mesajını temizle
        if error?.contains("Konum") == true {
            error = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Hata tipine göre farklı işlemler yap
        let clError = error as? CLError
        
        switch clError?.code {
        case .denied:
            self.error = "Konum izni reddedildi. Yakındaki camileri ve namaz vakitlerini görmek için konum izni gerekiyor."
        case .network:
            self.error = "Ağ bağlantısı olmadan konum tespit edilemiyor."
        case .locationUnknown:
            self.error = "Konum şu anda tespit edilemiyor, tekrar deneniyor..."
            // Bu durumda konum servisi çalışmaya devam eder
            return
        default:
            self.error = "Konum alınamadı: \(error.localizedDescription)"
        }
        
        // Hatadan sonra varsayılan konuma geç
        let defaultLocation = CLLocation(latitude: 41.0082, longitude: 28.9784)
        fetchPrayerTimes(for: defaultLocation)
        fetchNearbyMosques(near: defaultLocation)
    }
}

@main
struct DiyanetAPPApp: App {
    @StateObject private var persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Ana Sayfa", systemImage: "house.fill")
                }
            
            NavigationView {
                GuidesPlaceholder()
            }
            .tabItem {
                Label("Rehberler", systemImage: "book.fill")
            }
            
            MapsView()
                .tabItem {
                    Label("Camiler", systemImage: "building.columns.fill")
                }
            
            PrayersView()
                .tabItem {
                    Label("Vakitler", systemImage: "clock.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label("Hesabım", systemImage: "person.fill")
                }
        }
        .accentColor(.accentColor)
    }
}

// GuidesView yerine geçici bir görünüm
struct GuidesPlaceholder: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Rehberler")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 20)
            
            Text("Aşağıdaki rehberlerden birini seçin:")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            NavigationLink(destination: HajjGuideView()) {
                rehberButonu(baslik: "Hac Rehberi", aciklama: "Hac ibadeti için kapsamlı rehber", ikon: "mappin.and.ellipse")
            }
            
            NavigationLink(destination: UmrahGuideView()) {
                rehberButonu(baslik: "Umre Rehberi", aciklama: "Umre ziyareti için detaylı bilgiler", ikon: "building.columns")
            }
            
            NavigationLink(destination: JerusalemGuideView()) {
                rehberButonu(baslik: "Kudüs Rehberi", aciklama: "Mescid-i Aksa ve Kudüs ziyareti", ikon: "building.2")
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Dini Rehberler")
    }
    
    private func rehberButonu(baslik: String, aciklama: String, ikon: String) -> some View {
        HStack {
            Image(systemName: ikon)
                .font(.title2)
                .frame(width: 40, height: 40)
                .foregroundStyle(Color.accentColor)
                .background(Color.accentColor.opacity(0.2))
                .cornerRadius(10)
            
            VStack(alignment: .leading) {
                Text(baslik)
                    .font(.headline)
                Text(aciklama)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.gray)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// Auth View Model
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var error: String?
    
    init() {
        // Demo amaçlı otomatik giriş
        checkAuthenticationStatus()
    }
    
    func checkAuthenticationStatus() {
        self.isAuthenticated = true
        self.currentUser = User(
            id: "user1",
            name: "Demo Kullanıcı",
            email: "demo@example.com"
        )
    }
    
    func login(email: String, password: String) {
        isLoading = true
        
        // Giriş simülasyonu
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
            self.isAuthenticated = true
            self.currentUser = User(
                id: "user1",
                name: "Demo Kullanıcı",
                email: email
            )
        }
    }
    
    func register(name: String, email: String, password: String) {
        isLoading = true
        
        // Kayıt simülasyonu
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
            self.isAuthenticated = true
            self.currentUser = User(
                id: "user1",
                name: name,
                email: email
            )
        }
    }
    
    func logout() {
        self.isAuthenticated = false
        self.currentUser = nil
    }
}

// User Model
struct User: Identifiable {
    var id: String
    var name: String
    var email: String
}

// MARK: - Views

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Diyanet")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            TextField("E-posta", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
            
            SecureField("Şifre", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button("Giriş Yap") {
                authViewModel.login(email: email, password: password)
            }
            .buttonStyle(.borderedProminent)
            .disabled(authViewModel.isLoading)
            
            if authViewModel.isLoading {
                ProgressView()
            }
        }
        .padding()
    }
}

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Konum durumu ve hata mesajı
                    Group {
                        if viewModel.isLoading && viewModel.prayerTimes == nil {
                            HStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                Text("Konum bilgisi alınıyor...")
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemBackground))
                            .cornerRadius(15)
                            .shadow(radius: 5)
                        } else if viewModel.error != nil {
                            VStack {
                                Text(viewModel.error!)
                                    .foregroundStyle(.red)
                                    .multilineTextAlignment(.center)
                                    .padding()
                                
                                if viewModel.locationAuthorizationStatus == .denied || 
                                   viewModel.locationAuthorizationStatus == .restricted {
                                    Button("Konum Ayarlarını Aç") {
                                        if let url = URL(string: UIApplication.openSettingsURLString) {
                                            UIApplication.shared.open(url)
                                        }
                                    }
                                    .buttonStyle(.borderedProminent)
                                } else if viewModel.locationAuthorizationStatus == .notDetermined {
                                    Button("Konum İzni Ver") {
                                        viewModel.requestLocationPermission()
                                    }
                                    .buttonStyle(.borderedProminent)
                                } else {
                                    Button("Konumu Yeniden Dene") {
                                        viewModel.refreshData()
                                    }
                                    .buttonStyle(.borderedProminent)
                                }
                            }
                            .background(Color(.systemBackground))
                            .cornerRadius(15)
                            .shadow(radius: 5)
                        } else if let location = viewModel.currentLocation, let prayerTimes = viewModel.prayerTimes {
                            // Konum bilgisi başarılı bir şekilde alındı
                            HStack {
                                Image(systemName: "location.fill")
                                    .foregroundStyle(.green)
                                Text("\(prayerTimes.location.city), \(prayerTimes.location.country) bölgesi için veriler gösteriliyor")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Namaz Vakitleri Kartı
                    if let prayerTimes = viewModel.prayerTimes {
                        PrayerTimesCard(prayerTimes: prayerTimes)
                    }
                    
                    // Yakındaki Camiler
                    if !viewModel.nearbyMosques.isEmpty {
                        NearbyMosquesSection(mosques: viewModel.nearbyMosques)
                    }
                    
                    // Öne Çıkan Rehberler
                    if !viewModel.featuredGuides.isEmpty {
                        FeaturedGuidesSection(guides: viewModel.featuredGuides)
                    }
                }
                .padding()
            }
            .navigationTitle("Diyanet")
            .refreshable {
                viewModel.refreshData()
            }
            .overlay {
                if viewModel.isLoading && (viewModel.prayerTimes != nil || !viewModel.nearbyMosques.isEmpty) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                }
            }
            .onAppear {
                viewModel.refreshData()
            }
        }
    }
}

struct PrayerTimesCard: View {
    let prayerTimes: PrayerTimes
    
    var body: some View {
        VStack(spacing: 15) {
            Text(prayerTimes.location.city)
                .font(.title2)
                .fontWeight(.bold)
            
            HStack {
                PrayerTimeItem(name: "İmsak", time: formatTime(prayerTimes.fajr))
                Spacer()
                PrayerTimeItem(name: "Güneş", time: formatTime(prayerTimes.sunrise))
                Spacer()
                PrayerTimeItem(name: "Öğle", time: formatTime(prayerTimes.dhuhr))
            }
            
            HStack {
                PrayerTimeItem(name: "İkindi", time: formatTime(prayerTimes.asr))
                Spacer()
                PrayerTimeItem(name: "Akşam", time: formatTime(prayerTimes.maghrib))
                Spacer()
                PrayerTimeItem(name: "Yatsı", time: formatTime(prayerTimes.isha))
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

struct PrayerTimeItem: View {
    let name: String
    let time: String
    
    var body: some View {
        VStack(spacing: 5) {
            Text(name)
                .font(.caption)
                .foregroundStyle(.gray)
            Text(time)
                .font(.headline)
        }
    }
}

struct PrayersView: View {
    var body: some View {
        NavigationView {
            Text("Namaz Vakitleri")
                .navigationTitle("Vakitler")
        }
    }
}

struct MapsView: View {
    var body: some View {
        NavigationView {
            Text("Cami Haritası")
                .navigationTitle("Camiler")
        }
    }
}

struct ProfileView: View {
    var body: some View {
        NavigationView {
            Text("Profil")
                .navigationTitle("Hesabım")
        }
    }
}

struct NearbyMosquesSection: View {
    let mosques: [Mosque]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Yakındaki Camiler")
                .font(.title2)
                .fontWeight(.bold)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(mosques) { mosque in
                        MosqueCard(mosque: mosque)
                    }
                }
            }
        }
    }
}

struct MosqueCard: View {
    let mosque: Mosque
    
    var body: some View {
        VStack(alignment: .leading) {
            // Cami Görseli (placeholder)
            Color.gray
                .frame(width: 200, height: 150)
                .cornerRadius(10)
            
            Text(mosque.name)
                .font(.headline)
                .lineLimit(1)
            
            Text(mosque.address.formattedAddress)
                .font(.caption)
                .foregroundStyle(.gray)
                .lineLimit(2)
            
            // Mesafe bilgisi
            if let _ = mosque.distance {
                Text(mosque.formattedDistance)
                    .font(.caption)
                    .foregroundStyle(.blue)
                    .padding(.top, 2)
            }
            
            if let rating = mosque.rating {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Text(String(format: "%.1f", rating))
                    Text("(\(mosque.reviewCount))")
                        .foregroundStyle(.gray)
                }
                .font(.caption)
            }
        }
        .frame(width: 200)
        .padding(10)
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

struct FeaturedGuidesSection: View {
    let guides: [HomeGuide]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Öne Çıkan Rehberler")
                .font(.title2)
                .fontWeight(.bold)
            
            ForEach(guides) { guide in
                FeaturedGuideCard(guide: guide)
            }
        }
    }
}

struct FeaturedGuideCard: View {
    let guide: HomeGuide
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(guide.title)
                .font(.headline)
            
            Text(guide.description)
                .font(.subheadline)
                .foregroundStyle(.gray)
                .lineLimit(2)
            
            HStack {
                Label("\(guide.readTime) dk", systemImage: "clock")
                Spacer()
                Label(guide.category.capitalized, systemImage: "book")
            }
            .font(.caption)
            .foregroundStyle(.gray)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

// Helper structures for Navigation Preview
struct MosqueDetailView: View {
    let mosque: Mosque
    
    var body: some View {
        Text("Cami Detayları: \(mosque.name)")
    }
}

// Rehber detay görünümünü yeniden adlandırıyoruz çünkü GuidesView.swift'te tanımlandı
struct OldGuideDetailView: View {
    let guide: HomeGuide
    
    var body: some View {
        Text("Rehber Detayları: \(guide.title)")
    }
}

// Helper for View previews
struct ErrorWrapper: Identifiable {
    let id = UUID()
    let message: String
}

// MARK: - Previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AuthViewModel())
    }
}

// MARK: - Guide Views
struct HajjGuideView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Hac Rehberi")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Text("Hac, İslam'ın beş şartından biridir ve her Müslümanın gücü yettiğinde hayatında bir kez yapması gereken bir ibadettir.")
                    .padding()
                
                Image("hajj_guide")
                    .resizable()
                    .scaledToFit()
                    .padding()
                
                Text("Bu rehber, hac ibadetinin detaylarını ve kutsal mekanlarda yapılması gerekenleri anlatır.")
                    .padding()
            }
        }
        .navigationTitle("Hac Rehberi")
    }
}

struct UmrahGuideView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Umre Rehberi")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Text("Umre, hac mevsimi dışında, herhangi bir zamanda Kabe'yi, Safa ve Merve tepelerini ziyaret etmek ve sa'y etmekten ibarettir.")
                    .padding()
                
                Image("umrah_guide")
                    .resizable()
                    .scaledToFit()
                    .padding()
                
                Text("Bu rehber, umre ziyaretinizde yapmanız gereken ibadetleri ve dikkat edilmesi gereken hususları anlatır.")
                    .padding()
            }
        }
        .navigationTitle("Umre Rehberi")
    }
}

struct JerusalemGuideView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Kudüs Rehberi")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Text("Kudüs, üç semavi din için kutsal sayılan kadim bir şehirdir. Mescid-i Aksa, Müslümanların ilk kıblesi olarak özel bir öneme sahiptir.")
                    .padding()
                
                Image("jerusalem_guide")
                    .resizable()
                    .scaledToFit()
                    .padding()
                
                Text("Bu rehber, Kudüs'teki kutsal mekanları ve ziyaret edilmesi gereken yerleri anlatır.")
                    .padding()
            }
        }
        .navigationTitle("Kudüs Rehberi")
    }
}
