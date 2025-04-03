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
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784), // İstanbul
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
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
        isLoading = true
        
        // Cami arama sorgusu oluştur
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "cami OR mosque OR mescit"
        
        // Kullanıcının etrafında arama yap
        let searchRadius: CLLocationDistance = 5000 // 5 km
        let region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: searchRadius,
            longitudinalMeters: searchRadius
        )
        request.region = region
        
        // UI bölgesi güncelle
        DispatchQueue.main.async {
            self.region = region
        }
        
        // Aramayı başlat
        let search = MKLocalSearch(request: request)
        search.start { [weak self] (response, error) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.error = "Camiler yüklenirken bir hata oluştu: \(error.localizedDescription)"
                    return
                }
                
                if let response = response {
                    let userLocation = Location(
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude,
                        city: "",
                        country: ""
                    )
                    
                    // Bulunan cami bilgilerini dönüştür
                    var mosques = [Mosque]()
                    
                    for item in response.mapItems {
                        let placemark = item.placemark
                        
                        let mosque = self.createMosqueFromMapItem(
                            item: item,
                            userLocation: userLocation
                        )
                        
                        mosques.append(mosque)
                    }
                    
                    // Camileri mesafeye göre sırala
                    mosques.sort { (mosque1, mosque2) -> Bool in
                        guard let distance1 = mosque1.distance, let distance2 = mosque2.distance else {
                            return false
                        }
                        return distance1 < distance2
                    }
                    
                    self.nearbyMosques = mosques
                    
                    if mosques.isEmpty {
                        self.error = "Yakında bulunan cami bulunamadı. Arama yarıçapını genişletin veya başka bir bölgede arayın."
                    }
                } else {
                    self.error = "Yakında cami bulunamadı."
                }
            }
        }
    }
    
    // MapKit arama sonuçlarını Mosque nesnesine dönüştürme
    private func createMosqueFromMapItem(item: MKMapItem, userLocation: Location) -> Mosque {
        let placemark = item.placemark
        let coordinate = placemark.coordinate
        
        // Adres bilgilerini al
        let street = placemark.thoroughfare ?? ""
        let district = placemark.subLocality ?? placemark.subAdministrativeArea ?? ""
        let city = placemark.locality ?? placemark.administrativeArea ?? ""
        let postalCode = placemark.postalCode ?? ""
        let country = placemark.country ?? ""
        
        // Formatlı adres oluştur
        var formattedAddress = ""
        if !street.isEmpty {
            formattedAddress += street
        }
        if !district.isEmpty {
            if !formattedAddress.isEmpty { formattedAddress += ", " }
            formattedAddress += district
        }
        if !city.isEmpty {
            if !formattedAddress.isEmpty { formattedAddress += ", " }
            formattedAddress += city
        }
        if !country.isEmpty && country != "Türkiye" {
            if !formattedAddress.isEmpty { formattedAddress += ", " }
            formattedAddress += country
        }
        
        // Konum objesini oluştur
        let location = Location(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            city: city,
            country: country
        )
        
        // Kullanıcı konumuna mesafeyi hesapla
        let distance = location.distance(to: userLocation)
        
        // Adres objesini oluştur
        let address = Address(
            street: street,
            district: district,
            city: city,
            postalCode: postalCode,
            country: country,
            formattedAddress: formattedAddress
        )
        
        // Caminin adını al, yoksa varsayılan ad kullan
        let name = item.name ?? "Cami"
        
        // Cami nesnesini oluştur ve döndür
        var mosque = Mosque(
            id: UUID().uuidString,
            name: name,
            location: location,
            address: address,
            services: ["namaz"], // Varsayılan hizmet
            rating: nil, // MapKit derecelendirme bilgisi sağlamıyor
            reviewCount: 0
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
struct DiyanetAPP: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(AuthViewModel())
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
            
            NavigationView {
                PrayersView()
            }
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
            
            NavigationLink(destination: Text("Hac Rehberi").navigationTitle("Hac Rehberi")) {
                rehberButonu(baslik: "Hac Rehberi", aciklama: "Hac ibadeti için kapsamlı rehber", ikon: "mappin.and.ellipse")
            }
            
            NavigationLink(destination: Text("Umre Rehberi").navigationTitle("Umre Rehberi")) {
                rehberButonu(baslik: "Umre Rehberi", aciklama: "Umre ziyareti için detaylı bilgiler", ikon: "building.columns")
            }
            
            NavigationLink(destination: Text("Kudüs Rehberi").navigationTitle("Kudüs Rehberi")) {
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
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedMosque: Mosque?
    @State private var userTrackingMode: MapUserTrackingMode = .follow
    @State private var showingDetail = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Harita
                Map(coordinateRegion: $viewModel.region,
                    interactionModes: .all,
                    showsUserLocation: true,
                    userTrackingMode: $userTrackingMode,
                    annotationItems: viewModel.nearbyMosques) { mosque in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(
                        latitude: mosque.location.latitude,
                        longitude: mosque.location.longitude
                    )) {
                        Button {
                            selectedMosque = mosque
                            showingDetail = true
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(.white)
                                    .frame(width: 32, height: 32)
                                    .shadow(radius: 2)
                                
                                // Özel cami ikonu
                                ZStack {
                                    // Ana kubbe
                                    Circle()
                                        .fill(Color.accentColor)
                                        .frame(width: 16, height: 16)
                                    
                                    // Ana bina
                                    Rectangle()
                                        .fill(Color.accentColor)
                                        .frame(width: 22, height: 12)
                                        .offset(y: 8)
                                    
                                    // Minareler
                                    HStack(spacing: 26) {
                                        Rectangle()
                                            .fill(Color.accentColor)
                                            .frame(width: 3, height: 20)
                                        
                                        Rectangle()
                                            .fill(Color.accentColor)
                                            .frame(width: 3, height: 20)
                                    }
                                }
                                .frame(width: 26, height: 26)
                            }
                        }
                    }
                }
                .ignoresSafeArea(edges: .bottom)
                
                VStack {
                    Spacer()
                    
                    // Yakındaki camileri gösteren liste
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(viewModel.nearbyMosques) { mosque in
                                Button {
                                    // Cami konumuna git
                                    withAnimation {
                                        viewModel.region.center = CLLocationCoordinate2D(
                                            latitude: mosque.location.latitude,
                                            longitude: mosque.location.longitude
                                        )
                                        viewModel.region.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                    }
                                    selectedMosque = mosque
                                } label: {
                                    MosqueCard(mosque: mosque)
                                        .frame(width: 200)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 250)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(.systemBackground))
                            .shadow(radius: 5)
                    )
                    .padding(.bottom)
                    .padding(.horizontal)
                }
                
                // Konum açık değilse veya yükleniyor
                if viewModel.isLoading && viewModel.nearbyMosques.isEmpty {
                    ProgressView("Camiler yükleniyor...")
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                } else if viewModel.error != nil && viewModel.nearbyMosques.isEmpty {
                    VStack {
                        Text(viewModel.error!)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.red)
                            .padding()
                        
                        Button("Tekrar Dene") {
                            viewModel.refreshData()
                        }
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding()
                }
                
                // Harita kontrolü butonları
                VStack {
                    HStack {
                        Spacer()
                        
                        VStack(spacing: 10) {
                            Button {
                                // Kullanıcı konumuna git
                                if let location = viewModel.currentLocation {
                                    withAnimation {
                                        viewModel.region.center = location.coordinate
                                        viewModel.region.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                    }
                                }
                            } label: {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 20))
                                    .padding(10)
                                    .background(Color(.systemBackground))
                                    .clipShape(Circle())
                                    .shadow(radius: 3)
                            }
                            
                            Button {
                                // Haritayı yakınlaştır
                                withAnimation {
                                    viewModel.region.span = MKCoordinateSpan(
                                        latitudeDelta: max(viewModel.region.span.latitudeDelta * 0.5, 0.001),
                                        longitudeDelta: max(viewModel.region.span.longitudeDelta * 0.5, 0.001)
                                    )
                                }
                            } label: {
                                Image(systemName: "plus")
                                    .font(.system(size: 20))
                                    .padding(10)
                                    .background(Color(.systemBackground))
                                    .clipShape(Circle())
                                    .shadow(radius: 3)
                            }
                            
                            Button {
                                // Haritayı uzaklaştır
                                withAnimation {
                                    viewModel.region.span = MKCoordinateSpan(
                                        latitudeDelta: min(viewModel.region.span.latitudeDelta * 2.0, 50),
                                        longitudeDelta: min(viewModel.region.span.longitudeDelta * 2.0, 50)
                                    )
                                }
                            } label: {
                                Image(systemName: "minus")
                                    .font(.system(size: 20))
                                    .padding(10)
                                    .background(Color(.systemBackground))
                                    .clipShape(Circle())
                                    .shadow(radius: 3)
                            }
                        }
                        .padding(.trailing)
                    }
                    
                    Spacer()
                }
                .padding(.top)
            }
            .navigationTitle("Camiler")
            .sheet(isPresented: $showingDetail) {
                if let mosque = selectedMosque {
                    MosqueDetailSheet(mosque: mosque)
                        .presentationDetents([.medium, .large])
                }
            }
            .onAppear {
                if viewModel.nearbyMosques.isEmpty {
                    viewModel.refreshData()
                }
                
                // Kullanıcı konumu alındıysa merkezi konumu güncelle
                if let location = viewModel.currentLocation {
                    viewModel.region.center = location.coordinate
                }
            }
        }
    }
}

struct MosqueDetailSheet: View {
    let mosque: Mosque
    @State private var isShowingDirections = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                // Cami ikonu
                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 50, height: 50)
                    
                    // Cami ikonu
                    ZStack {
                        // Ana kubbe
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 40, height: 40)
                        
                        // Ana bina
                        Rectangle()
                            .fill(Color.accentColor)
                            .frame(width: 56, height: 32)
                            .offset(y: 20)
                        
                        // Minareler
                        HStack(spacing: 64) {
                            Rectangle()
                                .fill(Color.accentColor)
                                .frame(width: 6, height: 48)
                            
                            Rectangle()
                                .fill(Color.accentColor)
                                .frame(width: 6, height: 48)
                        }
                    }
                    .frame(height: 64)
                }
                .frame(width: 50, height: 50)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(mosque.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if let distance = mosque.distance {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundStyle(Color.accentColor)
                            Text(mosque.formattedDistance)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    Text("Adres")
                        .font(.headline)
                    
                    Text(mosque.address.formattedAddress)
                        .foregroundStyle(.secondary)
                    
                    Divider()
                    
                    if !mosque.services.isEmpty {
                        Text("Hizmetler")
                            .font(.headline)
                        
                        HStack {
                            ForEach(mosque.services, id: \.self) { service in
                                Text(service.capitalized)
                                    .font(.caption)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.accentColor.opacity(0.1))
                                    .cornerRadius(10)
                            }
                        }
                        
                        Divider()
                    }
                    
                    if let rating = mosque.rating {
                        HStack {
                            Text("Değerlendirme")
                                .font(.headline)
                            
                            Spacer()
                            
                            HStack {
                                ForEach(0..<5) { i in
                                    Image(systemName: i < Int(rating) ? "star.fill" : "star")
                                        .foregroundStyle(.yellow)
                                }
                                
                                Text(String(format: "%.1f", rating))
                                    .fontWeight(.bold)
                                
                                Text("(\(mosque.reviewCount))")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Divider()
                    }
                    
                    // Yol tarifi butonu
                    Button {
                        // Harita uygulamasını aç
                        let url = URL(string: "maps://?daddr=\(mosque.location.latitude),\(mosque.location.longitude)")
                        if let url = url, UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "map.fill")
                            Text("Yol Tarifi Al")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                    }
                }
            }
        }
        .padding()
        .navigationTitle(mosque.name)
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
            // Cami Görseli
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 120)
                
                // Cami ikonu
                ZStack {
                    // Ana kubbe
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 40, height: 40)
                    
                    // Ana bina
                    Rectangle()
                        .fill(Color.accentColor)
                        .frame(width: 56, height: 32)
                        .offset(y: 20)
                    
                    // Minareler
                    HStack(spacing: 64) {
                        Rectangle()
                            .fill(Color.accentColor)
                            .frame(width: 6, height: 48)
                        
                        Rectangle()
                            .fill(Color.accentColor)
                            .frame(width: 6, height: 48)
                    }
                }
                .frame(height: 64)
            }
            .frame(width: 200, height: 120)
            .cornerRadius(10)
            
            Text(mosque.name)
                .font(.headline)
                .lineLimit(1)
            
            Text(mosque.address.formattedAddress)
                .font(.caption)
                .foregroundStyle(.gray)
                .lineLimit(2)
            
            // Mesafe bilgisi
            if let distance = mosque.distance {
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
