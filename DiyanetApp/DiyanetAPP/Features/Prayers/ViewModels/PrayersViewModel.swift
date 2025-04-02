import Foundation
import Combine
import CoreLocation

class PrayersViewModel: ObservableObject {
    @Published var prayerTimes: PrayerTimes?
    @Published var weeklyPrayerTimes: [PrayerTimes] = []
    @Published var monthlyPrayerTimes: [PrayerTimes] = []
    @Published var selectedDate = Date()
    @Published var isLoading = false
    @Published var error: String?
    
    private let locationManager = CLLocationManager()
    private let networkManager = NetworkManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupLocationManager()
        fetchData()
    }
    
    // MARK: - Public Methods
    func fetchData() {
        isLoading = true
        error = nil
        
        let group = DispatchGroup()
        
        // Günlük namaz vakitlerini çek
        group.enter()
        fetchDailyPrayerTimes { [weak self] in
            group.leave()
        }
        
        // Haftalık namaz vakitlerini çek
        group.enter()
        fetchWeeklyPrayerTimes { [weak self] in
            group.leave()
        }
        
        // Aylık namaz vakitlerini çek
        group.enter()
        fetchMonthlyPrayerTimes { [weak self] in
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.isLoading = false
        }
    }
    
    func refreshData() {
        fetchData()
    }
    
    func selectDate(_ date: Date) {
        selectedDate = date
        // TODO: Seçilen tarihe göre namaz vakitlerini güncelle
    }
    
    // MARK: - Private Methods
    private func setupLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func fetchDailyPrayerTimes(completion: @escaping () -> Void) {
        guard let location = locationManager.location else {
            self.error = "Konum bilgisi alınamadı"
            completion()
            return
        }
        
        // TODO: API'den günlük namaz vakitlerini çek
        // Örnek veri
        let mockPrayerTimes = PrayerTimes(
            date: Date(),
            fajr: Calendar.current.date(bySettingHour: 5, minute: 30, second: 0, of: Date()) ?? Date(),
            sunrise: Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date()) ?? Date(),
            dhuhr: Calendar.current.date(bySettingHour: 12, minute: 30, second: 0, of: Date()) ?? Date(),
            asr: Calendar.current.date(bySettingHour: 15, minute: 45, second: 0, of: Date()) ?? Date(),
            maghrib: Calendar.current.date(bySettingHour: 18, minute: 15, second: 0, of: Date()) ?? Date(),
            isha: Calendar.current.date(bySettingHour: 19, minute: 45, second: 0, of: Date()) ?? Date(),
            location: Location(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                city: "İstanbul",
                country: "Türkiye",
                timezone: "Europe/Istanbul"
            )
        )
        
        self.prayerTimes = mockPrayerTimes
        completion()
    }
    
    private func fetchWeeklyPrayerTimes(completion: @escaping () -> Void) {
        // TODO: API'den haftalık namaz vakitlerini çek
        // Şimdilik günlük vakitleri 7 gün için çoğaltıyoruz
        guard let dailyTimes = prayerTimes else {
            completion()
            return
        }
        
        var weeklyTimes: [PrayerTimes] = []
        for dayOffset in 0...6 {
            let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: Date()) ?? Date()
            var times = dailyTimes
            times.date = date
            weeklyTimes.append(times)
        }
        
        self.weeklyPrayerTimes = weeklyTimes
        completion()
    }
    
    private func fetchMonthlyPrayerTimes(completion: @escaping () -> Void) {
        // TODO: API'den aylık namaz vakitlerini çek
        // Şimdilik günlük vakitleri 30 gün için çoğaltıyoruz
        guard let dailyTimes = prayerTimes else {
            completion()
            return
        }
        
        var monthlyTimes: [PrayerTimes] = []
        for dayOffset in 0...29 {
            let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: Date()) ?? Date()
            var times = dailyTimes
            times.date = date
            monthlyTimes.append(times)
        }
        
        self.monthlyPrayerTimes = monthlyTimes
        completion()
    }
} 