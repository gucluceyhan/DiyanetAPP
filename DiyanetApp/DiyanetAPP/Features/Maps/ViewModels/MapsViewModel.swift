import Foundation
import Combine
import CoreLocation
import MapKit

class MapsViewModel: NSObject, ObservableObject {
    @Published var mosques: [Mosque] = []
    @Published var selectedMosque: Mosque?
    @Published var userLocation: CLLocation?
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @Published var isLoading = false
    @Published var error: String?
    @Published var searchText = ""
    @Published var filteredMosques: [Mosque] = []
    
    private let locationManager = CLLocationManager()
    private let networkManager = NetworkManager.shared
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
        
        // TODO: API'den camileri çek
        // Örnek veri
        let mockMosques = [
            Mosque(
                id: "1",
                name: "Süleymaniye Camii",
                arabicName: "جامع السليمانية",
                location: MosqueLocation(
                    coordinates: CLLocationCoordinate2D(latitude: 41.0162, longitude: 28.9639),
                    type: "Point"
                ),
                address: MosqueAddress(
                    street: "Süleymaniye Mah.",
                    city: "Fatih",
                    state: "İstanbul",
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
                rating: 4.9,
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
                    street: "Sultanahmet Mah.",
                    city: "Fatih",
                    state: "İstanbul",
                    country: "Türkiye",
                    postalCode: "34122",
                    formattedAddress: "Sultanahmet Mah., Fatih, İstanbul"
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
                reviewCount: 2000,
                createdAt: Date(),
                updatedAt: Date()
            )
        ]
        
        DispatchQueue.main.async {
            self.mosques = mockMosques
            self.filteredMosques = mockMosques
            self.isLoading = false
        }
    }
    
    func selectMosque(_ mosque: Mosque) {
        selectedMosque = mosque
        region = MKCoordinateRegion(
            center: mosque.location.coordinates,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }
    
    func getDirections(to mosque: Mosque) {
        guard let userLocation = userLocation else {
            error = "Konum bilgisi alınamadı"
            return
        }
        
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
    
    // MARK: - Private Methods
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
            .sink { [weak self] searchText in
                self?.filterMosques(searchText)
            }
            .store(in: &cancellables)
    }
    
    private func filterMosques(_ searchText: String) {
        if searchText.isEmpty {
            filteredMosques = mosques
        } else {
            filteredMosques = mosques.filter { mosque in
                mosque.name.localizedCaseInsensitiveContains(searchText) ||
                mosque.address.formattedAddress.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension MapsViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location
        
        if selectedMosque == nil {
            region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
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