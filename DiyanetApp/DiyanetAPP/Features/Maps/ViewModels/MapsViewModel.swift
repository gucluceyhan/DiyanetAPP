import Foundation
import Combine
import CoreLocation
import MapKit

class MapsViewModel: NSObject, ObservableObject {
    @Published var mosques: [Mosque] = []
    @Published var filteredMosques: [Mosque] = []
    @Published var selectedMosque: Mosque?
    @Published var selectedMosqueForDetailView: Mosque?
    @Published var userLocation: CLLocation?
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @Published var isLoading = false
    @Published var error: String?
    @Published var searchText = ""
    @Published var filterOptions = FilterOptions()
    
    private let locationManager = CLLocationManager()
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        setupLocationManager()
        setupSearchSubscription()
    }
    
    // MARK: - Public Methods
    
    func fetchMosques() {
        isLoading = true
        error = nil
        
        // Gerçek bir API çağrısı yapılabilir burada
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            self.generateMockMosques()
            self.isLoading = false
        }
    }
    
    func refreshMosques() {
        // Konum veya filtreleri yenilemek için
        isLoading = true
        selectedMosque = nil
        
        // Kullanıcının konumunu yenile
        locationManager.requestLocation()
        
        // Camileri yeniden al
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            self.generateMockMosques()
            self.applyFilters()
            self.isLoading = false
        }
    }
    
    func centerOnUserLocation() {
        if let userLocation = userLocation {
            withAnimation {
                region = MKCoordinateRegion(
                    center: userLocation.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            }
        } else {
            locationManager.requestLocation()
        }
    }
    
    func selectMosque(_ mosque: Mosque) {
        withAnimation {
            selectedMosque = mosque
            region = MKCoordinateRegion(
                center: mosque.location.coordinates,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    }
    
    func getDirections(to mosque: Mosque) {
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: mosque.location.coordinates))
        destination.name = mosque.name
        
        MKMapItem.openMaps(
            with: [
                MKMapItem.forCurrentLocation(),
                destination
            ],
            launchOptions: [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
            ]
        )
    }
    
    func performSearch() {
        if searchText.isEmpty {
            applyFilters() // Sadece filtreleri uygula
        } else {
            // Hem arama hem de filtreleri uygula
            let searchResults = mosques.filter { mosque in
                mosque.name.localizedCaseInsensitiveContains(searchText) ||
                (mosque.arabicName?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                mosque.address.formattedAddress.localizedCaseInsensitiveContains(searchText)
            }
            filteredMosques = applyFiltersToMosques(searchResults)
        }
    }
    
    func applyFilters() {
        filteredMosques = applyFiltersToMosques(mosques)
    }
    
    func resetFilters() {
        filterOptions = FilterOptions()
        applyFilters()
    }
    
    // MARK: - Private Methods
    
    private func applyFiltersToMosques(_ mosqueList: [Mosque]) -> [Mosque] {
        let filtered = mosqueList.filter { mosque in
            // Hizmet filtreleri
            let servicesMatch = (!filterOptions.hasFridayPrayer || mosque.services.hasFridayPrayer) &&
                                (!filterOptions.hasWuduFacilities || mosque.services.hasWuduFacilities) &&
                                (!filterOptions.hasParking || mosque.services.hasParking) &&
                                (!filterOptions.hasWomenSection || mosque.services.hasWomenSection) &&
                                (!filterOptions.hasWheelchairAccess || mosque.services.hasWheelchairAccess)
            
            // Puan filtresi
            let ratingMatch = (mosque.rating ?? 0) >= filterOptions.minRating
            
            // Mesafe filtresi
            var distanceMatch = true
            if let userLocation = userLocation, filterOptions.maxDistance < Double.infinity {
                let mosqueLocation = CLLocation(latitude: mosque.location.coordinates.latitude, 
                                               longitude: mosque.location.coordinates.longitude)
                let distance = userLocation.distance(from: mosqueLocation) / 1000 // metre -> km
                distanceMatch = distance <= filterOptions.maxDistance
            }
            
            return servicesMatch && ratingMatch && distanceMatch
        }
        
        // Mesafeye göre sırala (eğer konum varsa)
        if let userLocation = userLocation {
            return filtered.sorted { m1, m2 in
                let loc1 = CLLocation(latitude: m1.location.coordinates.latitude, longitude: m1.location.coordinates.longitude)
                let loc2 = CLLocation(latitude: m2.location.coordinates.latitude, longitude: m2.location.coordinates.longitude)
                return userLocation.distance(from: loc1) < userLocation.distance(from: loc2)
            }
        }
        
        return filtered
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func setupSearchSubscription() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.performSearch()
            }
            .store(in: &cancellables)
    }
    
    private func generateMockMosques() {
        // Kullanıcı konumuna dayalı rastgele cami konumları oluştur
        var generatedMosques: [Mosque] = []
        let baseLocation = userLocation?.coordinate ?? CLLocationCoordinate2D(latitude: 41.0162, longitude: 28.9639)
        
        // Önceden tanımlanmış cami bilgileri
        let presetMosques = [
            (name: "Süleymaniye Camii", arabicName: "جامع السليمانية", lat: 41.0162, lng: 28.9639, rating: 4.9, reviewCount: 1250),
            (name: "Sultan Ahmet Camii", arabicName: "جامع السلطان أحمد", lat: 41.0054, lng: 28.9768, rating: 4.8, reviewCount: 2000),
            (name: "Fatih Camii", arabicName: "جامع الفاتح", lat: 41.0195, lng: 28.9500, rating: 4.7, reviewCount: 1100),
            (name: "Eyüp Sultan Camii", arabicName: "جامع أيوب سلطان", lat: 41.0477, lng: 28.9344, rating: 4.9, reviewCount: 1850),
            (name: "Yeni Cami", arabicName: "الجامع الجديد", lat: 41.0169, lng: 28.9700, rating: 4.6, reviewCount: 950)
        ]
        
        // Önceden tanımlanmış camileri ekle
        for i in 0..<presetMosques.count {
            let mosque = presetMosques[i]
            
            generatedMosques.append(
                Mosque(
                    id: String(i + 1),
                    name: mosque.name,
                    arabicName: mosque.arabicName,
                    location: MosqueLocation(
                        coordinates: CLLocationCoordinate2D(latitude: mosque.lat, longitude: mosque.lng),
                        type: "Point"
                    ),
                    address: MosqueAddress(
                        street: "Örnek Sokak No: \(i+1)",
                        city: "İstanbul",
                        state: "İstanbul",
                        country: "Türkiye",
                        postalCode: "341\(i)0",
                        formattedAddress: "Örnek Sokak No: \(i+1), İstanbul"
                    ),
                    contact: nil,
                    services: MosqueServices(
                        hasFridayPrayer: true,
                        hasWuduFacilities: i % 5 != 0, // Bazı camilerde olsun, bazılarında olmasın
                        hasParking: i % 3 == 0,
                        hasWomenSection: i % 2 == 0,
                        hasWheelchairAccess: i % 4 == 0,
                        hasAirConditioning: i % 3 == 1,
                        hasHeating: true,
                        hasLibrary: i % 3 == 2,
                        hasQuranClasses: i % 2 == 1
                    ),
                    images: nil,
                    rating: mosque.rating,
                    reviewCount: mosque.reviewCount,
                    createdAt: Date(),
                    updatedAt: Date()
                )
            )
        }
        
        // Rastgele 15 cami daha oluştur
        for i in presetMosques.count..<presetMosques.count + 15 {
            // Rastgele konum ofsetleri (±0.05 derece)
            let latOffset = Double.random(in: -0.05...0.05)
            let lngOffset = Double.random(in: -0.05...0.05)
            
            let mosqueCoordinate = CLLocationCoordinate2D(
                latitude: baseLocation.latitude + latOffset,
                longitude: baseLocation.longitude + lngOffset
            )
            
            // Rastgele cami ismi oluştur
            let randomMosqueNames = ["Merkez", "Yeni", "Ulu", "Selimiye", "Mimar Sinan", "Hacı Bayram", "Şehitler", "Yeşil", "Kurtuluş", "Cumhuriyet"]
            let randomMosqueTypes = ["Camii", "Mescidi", "Camisi"]
            
            let randomName = "\(randomMosqueNames.randomElement() ?? "Yeni") \(randomMosqueTypes.randomElement() ?? "Camii")"
            
            generatedMosques.append(
                Mosque(
                    id: String(i + 1),
                    name: randomName,
                    arabicName: nil, // Rastgele camilerin Arapça ismi olmayabilir
                    location: MosqueLocation(
                        coordinates: mosqueCoordinate,
                        type: "Point"
                    ),
                    address: MosqueAddress(
                        street: "Diyanet Sokak No: \(i+1)",
                        city: "İstanbul",
                        state: "İstanbul",
                        country: "Türkiye",
                        postalCode: "341\(i)0",
                        formattedAddress: "Diyanet Sokak No: \(i+1), İstanbul"
                    ),
                    contact: nil,
                    services: MosqueServices(
                        hasFridayPrayer: Bool.random(),
                        hasWuduFacilities: Bool.random(),
                        hasParking: Bool.random(),
                        hasWomenSection: Bool.random(),
                        hasWheelchairAccess: Bool.random(),
                        hasAirConditioning: Bool.random(),
                        hasHeating: true,
                        hasLibrary: Bool.random(),
                        hasQuranClasses: Bool.random()
                    ),
                    images: nil,
                    rating: Double.random(in: 3.0...5.0).rounded(to: 1),
                    reviewCount: Int.random(in: 10...500),
                    createdAt: Date(),
                    updatedAt: Date()
                )
            )
        }
        
        // Kullanıcı konumuna göre mesafeyi güncelle
        if let userLocation = userLocation {
            for i in 0..<generatedMosques.count {
                let mosqueLocation = CLLocation(
                    latitude: generatedMosques[i].location.coordinates.latitude,
                    longitude: generatedMosques[i].location.coordinates.longitude
                )
                let distance = userLocation.distance(from: mosqueLocation) / 1000 // metre -> kilometre
                
                // Formatlı mesafe
                let formattedAddress: String
                if distance < 1.0 {
                    formattedAddress = "\(Int(distance * 1000)) metre mesafede - \(generatedMosques[i].address.street)"
                } else {
                    formattedAddress = String(format: "%.1f km mesafede - %@", distance, generatedMosques[i].address.street)
                }
                
                // Adresi güncelle
                let updatedAddress = MosqueAddress(
                    street: generatedMosques[i].address.street,
                    city: generatedMosques[i].address.city,
                    state: generatedMosques[i].address.state,
                    country: generatedMosques[i].address.country,
                    postalCode: generatedMosques[i].address.postalCode,
                    formattedAddress: formattedAddress
                )
                
                // Mesafe ile güncellenmiş cami
                generatedMosques[i] = Mosque(
                    id: generatedMosques[i].id,
                    name: generatedMosques[i].name,
                    arabicName: generatedMosques[i].arabicName,
                    location: generatedMosques[i].location,
                    address: updatedAddress,
                    contact: generatedMosques[i].contact,
                    services: generatedMosques[i].services,
                    images: generatedMosques[i].images,
                    rating: generatedMosques[i].rating,
                    reviewCount: generatedMosques[i].reviewCount,
                    createdAt: generatedMosques[i].createdAt,
                    updatedAt: generatedMosques[i].updatedAt
                )
            }
            
            // Mesafeye göre sırala
            generatedMosques.sort { m1, m2 in
                let loc1 = CLLocation(latitude: m1.location.coordinates.latitude, longitude: m1.location.coordinates.longitude)
                let loc2 = CLLocation(latitude: m2.location.coordinates.latitude, longitude: m2.location.coordinates.longitude)
                return userLocation.distance(from: loc1) < userLocation.distance(from: loc2)
            }
        }
        
        self.mosques = generatedMosques
        self.filteredMosques = generatedMosques
    }
}

// MARK: - CLLocationManagerDelegate
extension MapsViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Daha önce konum yoksa veya konum önemli ölçüde değiştiyse
        if userLocation == nil || userLocation!.distance(from: location) > 500 {
            userLocation = location
            
            if selectedMosque == nil {
                withAnimation {
                    region = MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                }
            }
            
            // Mesafe bilgilerini güncelle
            if !mosques.isEmpty {
                applyFilters() // Bu, mesafeleri de güncelleyecek
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.error = "Konum alınamadı: \(error.localizedDescription)"
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            error = "Konum izni reddedildi. Lütfen ayarlardan konum iznini etkinleştirin."
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
}

// MARK: - Helper Extensions
extension Double {
    func rounded(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

// MARK: - Filter Options
struct FilterOptions {
    var hasFridayPrayer: Bool = false
    var hasWuduFacilities: Bool = false
    var hasParking: Bool = false
    var hasWomenSection: Bool = false
    var hasWheelchairAccess: Bool = false
    var maxDistance: Double = Double.infinity
    var minRating: Double = 0.0
} 