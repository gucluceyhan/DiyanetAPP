import Foundation
import Combine
import CoreLocation
import SwiftUI

class PrayersViewModel: ObservableObject, CLLocationManagerDelegate {
    @Published var prayerTimes: PrayerTimes?
    @Published var weeklyPrayerTimes: [PrayerTimes] = []
    @Published var monthlyPrayerTimes: [PrayerTimes] = []
    @Published var yearlyPrayerTimes: [PrayerTimes] = []
    @Published var selectedDate = Date()
    @Published var isLoading = false
    @Published var error: String?
    
    // Konum verileri
    @Published var selectedCountry = "TÜRKİYE"
    @Published var selectedCity = "İSTANBUL"
    @Published var selectedDistrict = "ÜSKÜDAR"
    @Published var availableCities: [String] = []
    @Published var availableDistricts: [String] = []
    
    // Kıble bilgileri
    @Published var qiblaDirection: Double = 0.0
    @Published var qiblaTime: String = ""
    
    // İmsakiye bilgileri
    @Published var hijriDate: String = ""
    @Published var upcomingHolidays: [ReligiousHoliday] = []
    
    private let locationManager = CLLocationManager()
    private let networkManager = NetworkManager.shared
    private var cancellables = Set<AnyCancellable>()
    private var isInitialSetupComplete = false
    
    init() {
        print("PrayersViewModel - init başladı")
        setupLocationManager()
        loadDefaultLocations()
        
        // Verileri hemen yüklemeden önce bir anlık bekleyerek UI'nin hazırlanmasını sağla
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.fetchData()
        }
        print("PrayersViewModel - init tamamlandı")
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("PrayersViewModel - Konum izni durumu değişti: \(manager.authorizationStatus.rawValue)")
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            // Konum izni verildi, konum verilerini alabilirsiniz
            print("PrayersViewModel - Konum izni verildi")
            // Sadece ilk kez veri yüklenmemişse yükle
            if !isInitialSetupComplete {
                isInitialSetupComplete = true
                fetchData()
            }
        case .denied, .restricted:
            // Konum izni reddedildi veya kısıtlandı
            print("PrayersViewModel - Konum izni reddedildi")
            self.error = "Konum izni reddedildi. Lütfen ayarlardan konum erişimine izin verin."
        case .notDetermined:
            // Kullanıcı henüz karar vermedi
            print("PrayersViewModel - Konum izni durumu belirlenmedi")
        @unknown default:
            print("PrayersViewModel - Bilinmeyen konum izni durumu")
        }
    }
    
    // MARK: - Public Methods
    func fetchData() {
        print("PrayersViewModel - fetchData başladı")
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
        
        // Yıllık namaz vakitlerini çek
        group.enter()
        fetchYearlyPrayerTimes { [weak self] in
            group.leave()
        }
        
        // Kıble yönünü hesapla
        group.enter()
        calculateQiblaDirection { [weak self] in
            group.leave()
        }
        
        // Dini günleri çek
        group.enter()
        fetchReligiousHolidays { [weak self] in
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            print("PrayersViewModel - Tüm veriler yüklendi")
            self?.isLoading = false
        }
    }
    
    func refreshData() {
        fetchData()
    }
    
    func selectDate(_ date: Date) {
        selectedDate = date
        // Seçilen tarihe göre namaz vakitlerini filtrele
        if let dayPrayer = monthlyPrayerTimes.first(where: { 
            Calendar.current.isDate($0.date, inSameDayAs: date)
        }) {
            self.prayerTimes = dayPrayer
        }
    }
    
    func loadCities(forCountry country: String) {
        // Diyanet API'sinden ülkeye göre şehirleri çek
        print("PrayersViewModel - \(country) için şehirler yükleniyor")
        let wasLoading = isLoading
        if !wasLoading { isLoading = true }
        
        // Örnek olarak sadece Türkiye illeri (UI block etmemek için arka planda yap)
        DispatchQueue.global().async { [weak self] in
            let cities = ["ADANA", "ADIYAMAN", "AFYONKARAHİSAR", "AĞRI", "AKSARAY", "AMASYA", 
                          "ANKARA", "ANTALYA", "ARDAHAN", "ARTVİN", "AYDIN", "BALIKESİR", 
                          "BARTIN", "BATMAN", "BAYBURT", "BİLECİK", "BİNGÖL", "BİTLİS", 
                          "BOLU", "BURDUR", "BURSA", "ÇANAKKALE", "ÇANKIRI", "ÇORUM", 
                          "DENİZLİ", "DİYARBAKIR", "DÜZCE", "EDİRNE", "ELAZIĞ", "ERZİNCAN", 
                          "ERZURUM", "ESKİŞEHİR", "GAZİANTEP", "GİRESUN", "GÜMÜŞHANE", 
                          "HAKKARİ", "HATAY", "IĞDIR", "ISPARTA", "İSTANBUL", "İZMİR", 
                          "KAHRAMANMARAŞ", "KARABÜK", "KARAMAN", "KARS", "KASTAMONU", 
                          "KAYSERİ", "KİLİS", "KIRIKKALE", "KIRKLARELİ", "KIRŞEHİR", 
                          "KOCAELİ", "KONYA", "KÜTAHYA", "MALATYA", "MANİSA", "MARDİN", 
                          "MERSİN", "MUĞLA", "MUŞ", "NEVŞEHİR", "NİĞDE", "ORDU", 
                          "OSMANİYE", "RİZE", "SAKARYA", "SAMSUN", "ŞANLIURFA", "SİİRT", 
                          "SİNOP", "ŞIRNAK", "SİVAS", "TEKİRDAĞ", "TOKAT", "TRABZON", 
                          "TUNCELİ", "UŞAK", "VAN", "YALOVA", "YOZGAT", "ZONGULDAK"]
            
            DispatchQueue.main.async {
                self?.availableCities = cities
                if !wasLoading { self?.isLoading = false }
                print("PrayersViewModel - Şehirler yüklendi: \(cities.count) adet")
            }
        }
    }
    
    func loadDistricts(forCity city: String) {
        // Diyanet API'sinden şehire göre ilçeleri çek
        print("PrayersViewModel - \(city) için ilçeler yükleniyor")
        let wasLoading = isLoading
        if !wasLoading { isLoading = true }
        
        // UI block etmemek için arka planda yap
        DispatchQueue.global().async { [weak self] in
            var districts: [String] = []
            
            // Örnek olarak Ankara ilçeleri (gerçek API entegrasyonunda burası dinamik olacak)
            if city == "ANKARA" {
                districts = ["AKYURT", "ANKARA", "AYAŞ", "BALA", "BEYPAZARI", "ÇAMLIDERE", 
                             "CUBUK", "ELMADAĞ", "EVREN", "GÜDÜL", "HAYMANA", 
                             "KAHRAMANKAZAN", "KALECİK", "KIZILCAHAMAM", "NALLIHAN", 
                             "POLATLI", "ŞEREFLİKOÇHİSAR"]
            } else if city == "İSTANBUL" {
                districts = ["ADALAR", "ARNAVUTKÖY", "ATAŞEHİR", "AVCILAR", "BAĞCILAR", 
                             "BAHÇELİEVLER", "BAKIRKÖY", "BAŞAKŞEHİR", "BAYRAMPAŞA", 
                             "BEŞİKTAŞ", "BEYKOZ", "BEYLİKDÜZÜ", "BEYOĞLU", "BÜYÜKÇEKMECE", 
                             "ÇATALCA", "ÇEKMEKÖY", "ESENLER", "ESENYURT", "EYÜPSULTAN", 
                             "FATİH", "GAZİOSMANPAŞA", "GÜNGÖREN", "KADIKÖY", "KAĞITHANE", 
                             "KARTAL", "KÜÇÜKÇEKMECE", "MALTEPE", "PENDİK", "SANCAKTEPE", 
                             "SARIYER", "SİLİVRİ", "SULTANBEYLİ", "SULTANGAZİ", "ŞİLE", 
                             "ŞİŞLİ", "TUZLA", "ÜMRANİYE", "ÜSKÜDAR", "ZEYTİNBURNU"]
            } else {
                // Diğer şehirler için varsayılan ilçe listesi
                districts = ["MERKEZ"]
            }
            
            DispatchQueue.main.async {
                self?.availableDistricts = districts
                if !wasLoading { self?.isLoading = false }
                print("PrayersViewModel - İlçeler yüklendi: \(districts.count) adet")
            }
        }
    }
    
    func updateLocation(country: String, city: String, district: String) {
        print("PrayersViewModel - Konum güncelleniyor: \(country), \(city), \(district)")
        self.selectedCountry = country
        self.selectedCity = city
        self.selectedDistrict = district
        
        // Yeni verileri yükle (gecikmeli olarak çağır - view güncellemelerini önlemek için)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.fetchData()
        }
    }
    
    // MARK: - Private Methods
    private func setupLocationManager() {
        print("PrayersViewModel - setupLocationManager başladı")
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        // Ana thread'de requestWhenInUseAuthorization çağrısı yapmıyoruz
        // Bunun yerine delegate'i bekliyoruz
        let authStatus = locationManager.authorizationStatus
        
        print("PrayersViewModel - Mevcut konum izni durumu: \(authStatus.rawValue)")
        
        // Konum izni zaten varsa delegate metodu otomatik çağrılmayacak
        // bu nedenle manuel olarak kontrol ediyoruz
        if authStatus == .authorizedWhenInUse || authStatus == .authorizedAlways {
            print("PrayersViewModel - Konum izni zaten var")
            isInitialSetupComplete = true
        } else if authStatus == .notDetermined {
            // Konum izni henüz belirlenmemiş, UI hazır olduğunda isteyeceğiz
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                print("PrayersViewModel - Konum izni isteniyor")
                self?.locationManager.requestWhenInUseAuthorization()
            }
        }
    }
    
    private func loadDefaultLocations() {
        loadCities(forCountry: selectedCountry)
        loadDistricts(forCity: selectedCity)
    }
    
    private func fetchDailyPrayerTimes(completion: @escaping () -> Void) {
        print("PrayersViewModel - fetchDailyPrayerTimes başladı")
        // Diyanet API'ye istek atmak yerine şimdilik sabit veriler kullanıyoruz
        // Gerçek uygulamada burada API isteği yapılacak
        
        // Örnek günlük vakit verisi
        let today = Date()
        let calendar = Calendar.current
        
        // Varsayılan vakitler (Gerçek API entegrasyonunda burası API'den alınacak)
        let mockPrayerTimes = PrayerTimes(
            date: today,
            fajr: calendar.date(bySettingHour: 4, minute: 56, second: 0, of: today) ?? today,
            sunrise: calendar.date(bySettingHour: 6, minute: 23, second: 0, of: today) ?? today,
            dhuhr: calendar.date(bySettingHour: 12, minute: 57, second: 0, of: today) ?? today,
            asr: calendar.date(bySettingHour: 16, minute: 32, second: 0, of: today) ?? today,
            maghrib: calendar.date(bySettingHour: 19, minute: 21, second: 0, of: today) ?? today,
            isha: calendar.date(bySettingHour: 20, minute: 42, second: 0, of: today) ?? today,
            location: Location(
                latitude: 41.015137,
                longitude: 28.979530,
                city: selectedCity,
                country: selectedCountry,
                timezone: "Europe/Istanbul"
            )
        )
        
        // Main thread'de tüm @Published değişkenlerini güncelle
        DispatchQueue.main.async { [weak self] in
            self?.prayerTimes = mockPrayerTimes
            // Hicri tarihi ayarla
            self?.hijriDate = "5 Şevval 1446"
            completion()
        }
    }
    
    private func fetchWeeklyPrayerTimes(completion: @escaping () -> Void) {
        // Şimdilik sabit veriler kullanıyoruz
        guard let dailyTimes = prayerTimes else {
            completion()
            return
        }
        
        var weeklyTimes: [PrayerTimes] = []
        let calendar = Calendar.current
        
        DispatchQueue.global().async { [weak self] in
            for dayOffset in 0...6 {
                let date = calendar.date(byAdding: .day, value: dayOffset, to: Date()) ?? Date()
                
                // Her gün için vakitleri biraz değiştirerek gerçekçi hale getiriyoruz
                let fajrMinuteOffset = Int.random(in: -2...2)
                let sunriseMinuteOffset = Int.random(in: -2...2)
                let dhuhrMinuteOffset = Int.random(in: -1...1)
                let asrMinuteOffset = Int.random(in: -1...1)
                let maghribMinuteOffset = Int.random(in: -2...2)
                let ishaMinuteOffset = Int.random(in: -2...2)
                
                let times = PrayerTimes(
                    date: date,
                    fajr: calendar.date(byAdding: .minute, value: fajrMinuteOffset, to: dailyTimes.fajr) ?? dailyTimes.fajr,
                    sunrise: calendar.date(byAdding: .minute, value: sunriseMinuteOffset, to: dailyTimes.sunrise) ?? dailyTimes.sunrise,
                    dhuhr: calendar.date(byAdding: .minute, value: dhuhrMinuteOffset, to: dailyTimes.dhuhr) ?? dailyTimes.dhuhr,
                    asr: calendar.date(byAdding: .minute, value: asrMinuteOffset, to: dailyTimes.asr) ?? dailyTimes.asr,
                    maghrib: calendar.date(byAdding: .minute, value: maghribMinuteOffset, to: dailyTimes.maghrib) ?? dailyTimes.maghrib,
                    isha: calendar.date(byAdding: .minute, value: ishaMinuteOffset, to: dailyTimes.isha) ?? dailyTimes.isha,
                    location: dailyTimes.location
                )
                
                weeklyTimes.append(times)
            }
            
            DispatchQueue.main.async {
                self?.weeklyPrayerTimes = weeklyTimes
                completion()
            }
        }
    }
    
    private func fetchMonthlyPrayerTimes(completion: @escaping () -> Void) {
        // Şimdilik sabit veriler kullanıyoruz
        guard let dailyTimes = prayerTimes else {
            completion()
            return
        }
        
        DispatchQueue.global().async { [weak self] in
            var monthlyTimes: [PrayerTimes] = []
            let calendar = Calendar.current
            
            for dayOffset in 0...29 {
                let date = calendar.date(byAdding: .day, value: dayOffset, to: Date()) ?? Date()
                
                // Her gün için vakitleri biraz değiştirerek gerçekçi hale getiriyoruz
                let fajrMinuteOffset = Int.random(in: -5...5)
                let sunriseMinuteOffset = Int.random(in: -5...5)
                let dhuhrMinuteOffset = Int.random(in: -2...2)
                let asrMinuteOffset = Int.random(in: -3...3)
                let maghribMinuteOffset = Int.random(in: -5...5)
                let ishaMinuteOffset = Int.random(in: -5...5)
                
                let times = PrayerTimes(
                    date: date,
                    fajr: calendar.date(byAdding: .minute, value: fajrMinuteOffset, to: dailyTimes.fajr) ?? dailyTimes.fajr,
                    sunrise: calendar.date(byAdding: .minute, value: sunriseMinuteOffset, to: dailyTimes.sunrise) ?? dailyTimes.sunrise,
                    dhuhr: calendar.date(byAdding: .minute, value: dhuhrMinuteOffset, to: dailyTimes.dhuhr) ?? dailyTimes.dhuhr,
                    asr: calendar.date(byAdding: .minute, value: asrMinuteOffset, to: dailyTimes.asr) ?? dailyTimes.asr,
                    maghrib: calendar.date(byAdding: .minute, value: maghribMinuteOffset, to: dailyTimes.maghrib) ?? dailyTimes.maghrib,
                    isha: calendar.date(byAdding: .minute, value: ishaMinuteOffset, to: dailyTimes.isha) ?? dailyTimes.isha,
                    location: dailyTimes.location
                )
                
                monthlyTimes.append(times)
            }
            
            DispatchQueue.main.async {
                self?.monthlyPrayerTimes = monthlyTimes
                completion()
            }
        }
    }
    
    private func fetchYearlyPrayerTimes(completion: @escaping () -> Void) {
        // Şimdilik sabit veriler kullanıyoruz
        guard let dailyTimes = prayerTimes else {
            completion()
            return
        }
        
        DispatchQueue.global().async { [weak self] in
            var yearlyTimes: [PrayerTimes] = []
            let calendar = Calendar.current
            
            // Şimdilik sadece birkaç aylık veri oluşturuyoruz
            for dayOffset in 0...90 {
                let date = calendar.date(byAdding: .day, value: dayOffset, to: Date()) ?? Date()
                
                // Her gün için vakitleri değiştirerek gerçekçi hale getiriyoruz
                // Mevsimlere göre değişim ekleyerek daha gerçekçi hale getiriyoruz
                let monthFactor = Double(calendar.component(.month, from: date))
                
                // Kış aylarında güneş daha geç doğar, erken batar 
                // Yaz aylarında güneş erken doğar, geç batar
                let seasonalOffset = monthFactor <= 6 ? monthFactor - 3 : 9 - monthFactor
                
                let fajrMinuteOffset = Int(seasonalOffset * -3) + Int.random(in: -5...5)
                let sunriseMinuteOffset = Int(seasonalOffset * -2) + Int.random(in: -5...5)
                let dhuhrMinuteOffset = Int.random(in: -2...2)
                let asrMinuteOffset = Int(seasonalOffset * 1) + Int.random(in: -3...3)
                let maghribMinuteOffset = Int(seasonalOffset * 2) + Int.random(in: -5...5)
                let ishaMinuteOffset = Int(seasonalOffset * 2) + Int.random(in: -5...5)
                
                let times = PrayerTimes(
                    date: date,
                    fajr: calendar.date(byAdding: .minute, value: fajrMinuteOffset, to: dailyTimes.fajr) ?? dailyTimes.fajr,
                    sunrise: calendar.date(byAdding: .minute, value: sunriseMinuteOffset, to: dailyTimes.sunrise) ?? dailyTimes.sunrise,
                    dhuhr: calendar.date(byAdding: .minute, value: dhuhrMinuteOffset, to: dailyTimes.dhuhr) ?? dailyTimes.dhuhr,
                    asr: calendar.date(byAdding: .minute, value: asrMinuteOffset, to: dailyTimes.asr) ?? dailyTimes.asr,
                    maghrib: calendar.date(byAdding: .minute, value: maghribMinuteOffset, to: dailyTimes.maghrib) ?? dailyTimes.maghrib,
                    isha: calendar.date(byAdding: .minute, value: ishaMinuteOffset, to: dailyTimes.isha) ?? dailyTimes.isha,
                    location: dailyTimes.location
                )
                
                yearlyTimes.append(times)
            }
            
            DispatchQueue.main.async {
                self?.yearlyPrayerTimes = yearlyTimes
                completion()
            }
        }
    }
    
    private func calculateQiblaDirection(completion: @escaping () -> Void) {
        // Kabe'nin koordinatları
        let kaabaLat = 21.4225
        let kaabaLon = 39.8262
        
        // Kullanıcının konumu
        let userLat = 41.015137 // Örnek olarak İstanbul
        let userLon = 28.979530
        
        DispatchQueue.global().async { [weak self] in
            // Kıble açısını hesapla (basit formül)
            let dLon = kaabaLon - userLon
            
            let y = sin(dLon.degreesToRadians)
            let x = cos(userLat.degreesToRadians) * tan(kaabaLat.degreesToRadians) - sin(userLat.degreesToRadians) * cos(dLon.degreesToRadians)
            
            var qiblaAngle = atan2(y, x).radiansToDegrees
            if qiblaAngle < 0 {
                qiblaAngle += 360.0
            }
            
            DispatchQueue.main.async {
                self?.qiblaDirection = qiblaAngle
                self?.qiblaTime = "12:06" // Öğle vakti civarı
                completion()
            }
        }
    }
    
    private func fetchReligiousHolidays(completion: @escaping () -> Void) {
        DispatchQueue.global().async { [weak self] in
            // Dini günleri getir (örnek veriler)
            let holidays = [
                ReligiousHoliday(name: "Ramazan Bayramı", date: Calendar.current.date(from: DateComponents(year: 2025, month: 3, day: 30)) ?? Date(), description: "1 Şevval 1446"),
                ReligiousHoliday(name: "Kurban Bayramı", date: Calendar.current.date(from: DateComponents(year: 2024, month: 6, day: 16)) ?? Date(), description: "10 Zilhicce 1445"),
                ReligiousHoliday(name: "Mevlid Kandili", date: Calendar.current.date(from: DateComponents(year: 2024, month: 9, day: 14)) ?? Date(), description: "12 Rebiülevvel 1446")
            ]
            
            DispatchQueue.main.async {
                self?.upcomingHolidays = holidays
                completion()
            }
        }
    }
}

// MARK: - Yardımcı Veri Yapıları
struct ReligiousHoliday: Identifiable {
    let id = UUID()
    let name: String
    let date: Date
    let description: String
}

// MARK: - Yardımcı Uzantılar
extension Double {
    var degreesToRadians: Double {
        return self * .pi / 180
    }
    
    var radiansToDegrees: Double {
        return self * 180 / .pi
    }
} 