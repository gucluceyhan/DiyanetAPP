import SwiftUI
import Foundation
import MapKit

struct PrayersView: View {
    @StateObject private var viewModel = PrayersViewModel()
    @State private var selectedTab = 0
    @State private var showLocationPicker = false
    @State private var showQiblaDirection = false
    @State private var showHolidays = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Üst Bilgi Kartı
            if let prayerTimes = viewModel.prayerTimes {
                PrayerTimesHeaderCard(prayerTimes: prayerTimes, hijriDate: viewModel.hijriDate)
                    .padding()
            } else {
                // Veri yüklenmediyse
                VStack(spacing: 10) {
                    Text("Namaz vakitleri yükleniyor...")
                        .font(.headline)
                    
                    // Yükleniyor göstergesi
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                        .padding()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemBackground))
                .cornerRadius(15)
                .shadow(radius: 5)
                .padding()
            }
            
            // Konum Seçici
            HStack {
                Text("Bölge Seçiniz:")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                
                Spacer()
                
                Button {
                    showLocationPicker = true
                } label: {
                    HStack {
                        Text("\(viewModel.selectedCity), \(viewModel.selectedDistrict)")
                            .font(.subheadline)
                            .foregroundStyle(.accentColor)
                        
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundStyle(.accentColor)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 5)
            
            // Kıble ve Dini Günler Butonları
            HStack(spacing: 15) {
                Button {
                    showQiblaDirection = true
                } label: {
                    HStack {
                        Image(systemName: "arrow.up.left")
                        Text("Kıble Yönü")
                    }
                    .font(.subheadline)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.accentColor.opacity(0.1))
                    .foregroundStyle(Color.accentColor)
                    .cornerRadius(8)
                }
                
                Button {
                    showHolidays = true
                } label: {
                    HStack {
                        Image(systemName: "calendar")
                        Text("Dinî Günler")
                    }
                    .font(.subheadline)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.accentColor.opacity(0.1))
                    .foregroundStyle(Color.accentColor)
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            
            // Tab Seçici
            Picker("Görünüm", selection: $selectedTab) {
                Text("Günlük").tag(0)
                Text("Haftalık").tag(1)
                Text("Aylık").tag(2)
                Text("Yıllık").tag(3)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // Tab İçeriği
            TabView(selection: $selectedTab) {
                // Günlük Görünüm
                if let prayerTimes = viewModel.prayerTimes {
                    DailyPrayerView(prayerTimes: prayerTimes)
                        .tag(0)
                } else {
                    Text("Namaz vakitleri yükleniyor...")
                        .tag(0)
                }
                
                // Haftalık Görünüm
                if !viewModel.weeklyPrayerTimes.isEmpty {
                    WeeklyPrayerView(prayerTimes: viewModel.weeklyPrayerTimes)
                        .tag(1)
                } else {
                    Text("Haftalık namaz vakitleri yükleniyor...")
                        .tag(1)
                }
                
                // Aylık Görünüm
                if !viewModel.monthlyPrayerTimes.isEmpty {
                    MonthlyPrayerView(prayerTimes: viewModel.monthlyPrayerTimes)
                        .tag(2)
                } else {
                    Text("Aylık namaz vakitleri yükleniyor...")
                        .tag(2)
                }
                
                // Yıllık Görünüm
                if !viewModel.yearlyPrayerTimes.isEmpty {
                    YearlyPrayerView(prayerTimes: viewModel.yearlyPrayerTimes)
                        .tag(3)
                } else {
                    Text("Yıllık namaz vakitleri yükleniyor...")
                        .tag(3)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            Spacer() // Ekranın alt kısmını doldurmak için
        }
        .navigationTitle("Namaz Vakitleri")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.refreshData()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .imageScale(.large)
                }
            }
        }
        .refreshable {
            viewModel.refreshData()
        }
        .overlay {
            if viewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.5)
                        
                        Text("Yükleniyor...")
                            .foregroundStyle(.white)
                            .padding(.top)
                    }
                    .padding()
                    .background(Color(.systemBackground).opacity(0.8))
                    .cornerRadius(10)
                }
            }
        }
        .alert(item: Binding(
            get: { viewModel.error.map { ErrorWrapper(message: $0) } },
            set: { _ in viewModel.error = nil }
        )) { error in
            Alert(
                title: Text("Hata"),
                message: Text(error.message),
                dismissButton: .default(Text("Tamam"))
            )
        }
        .sheet(isPresented: $showLocationPicker) {
            LocationPickerView(viewModel: viewModel, isPresented: $showLocationPicker)
        }
        .sheet(isPresented: $showQiblaDirection) {
            QiblaDirectionView(qiblaDirection: viewModel.qiblaDirection, qiblaTime: viewModel.qiblaTime)
        }
        .sheet(isPresented: $showHolidays) {
            ReligiousHolidaysView(holidays: viewModel.upcomingHolidays)
        }
        .onAppear {
            // Veri yoksa yeniden yükle
            if viewModel.prayerTimes == nil {
                viewModel.refreshData()
            }
        }
    }
}

// MARK: - Location Picker View
struct LocationPickerView: View {
    @ObservedObject var viewModel: PrayersViewModel
    @Binding var isPresented: Bool
    
    @State private var selectedCountry = "TÜRKİYE"
    @State private var selectedCity = ""
    @State private var selectedDistrict = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Ülke")) {
                        Picker("Ülke", selection: $selectedCountry) {
                            Text("TÜRKİYE").tag("TÜRKİYE")
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    Section(header: Text("Şehir")) {
                        Picker("Şehir", selection: $selectedCity) {
                            ForEach(viewModel.availableCities, id: \.self) { city in
                                Text(city).tag(city)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .onChange(of: selectedCity) { newValue in
                            viewModel.loadDistricts(forCity: newValue)
                            selectedDistrict = viewModel.availableDistricts.first ?? ""
                        }
                    }
                    
                    Section(header: Text("İlçe")) {
                        Picker("İlçe", selection: $selectedDistrict) {
                            ForEach(viewModel.availableDistricts, id: \.self) { district in
                                Text(district).tag(district)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                
                Button(action: {
                    viewModel.updateLocation(country: selectedCountry, city: selectedCity, district: selectedDistrict)
                    isPresented = false
                }) {
                    Text("Seç")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Konum Seçimi")
            .navigationBarItems(trailing: Button("Kapat") {
                isPresented = false
            })
            .onAppear {
                selectedCountry = viewModel.selectedCountry
                selectedCity = viewModel.selectedCity
                selectedDistrict = viewModel.selectedDistrict
            }
        }
    }
}

// MARK: - Qibla Direction View
struct QiblaDirectionView: View {
    let qiblaDirection: Double
    let qiblaTime: String
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Kıble Açısı")
                    .font(.headline)
                
                // Kıble yönü göstergesi
                ZStack {
                    // Pusula çemberi
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 4)
                        .frame(width: 250, height: 250)
                    
                    // Yön çizgileri
                    ForEach(0..<4) { index in
                        Rectangle()
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 2, height: 250)
                            .rotationEffect(.degrees(Double(index) * 45))
                    }
                    
                    // Kuzey işareti
                    VStack {
                        Text("K")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .frame(height: 270)
                    
                    // Güney işareti
                    VStack {
                        Spacer()
                        Text("G")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .frame(height: 270)
                    
                    // Doğu işareti
                    HStack {
                        Spacer()
                        Text("D")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .frame(width: 270)
                    
                    // Batı işareti
                    HStack {
                        Text("B")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .frame(width: 270)
                    
                    // Kıble oku
                    VStack {
                        Image(systemName: "location.north.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundStyle(.red)
                        
                        Spacer()
                    }
                    .frame(height: 220)
                    .rotationEffect(.degrees(qiblaDirection))
                }
                .frame(width: 300, height: 300)
                .padding(.vertical, 20)
                
                // Kıble açısı bilgisi
                VStack(spacing: 10) {
                    Text("Kıble Açısı: \(Int(qiblaDirection))°")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("Kıble Zamanı: \(qiblaTime)")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                    
                    Text("Haritada tam kıble yönü için kıble zamanında pusulanız ile bu açıya yönelin.")
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Kıble Yönü")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Religious Holidays View
struct ReligiousHolidaysView: View {
    let holidays: [ReligiousHoliday]
    
    var body: some View {
        NavigationView {
            List(holidays) { holiday in
                VStack(alignment: .leading, spacing: 5) {
                    Text(holiday.name)
                        .font(.headline)
                    
                    Text(formatDate(holiday.date))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text(holiday.description)
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
                .padding(.vertical, 5)
            }
            .navigationTitle("Dinî Günler")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy, EEEE"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Views
struct PrayerTimesHeaderCard: View {
    let prayerTimes: PrayerTimes
    let hijriDate: String
    
    var body: some View {
        VStack(spacing: 10) {
            // Şehir
            Text(prayerTimes.location.city)
                .font(.title2)
                .fontWeight(.bold)
            
            // Tarih bilgileri
            HStack {
                Text(formatDate(prayerTimes.date))
                    .font(.subheadline)
                
                Text("•")
                    .foregroundStyle(.gray)
                
                Text(hijriDate)
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }
            
            // Ay durumu (image placeholder)
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 32))
                .foregroundStyle(.orange)
                .padding(.vertical, 5)
            
            // Bir sonraki namaz vakti
            NextPrayerTimeView(prayerTimes: prayerTimes)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy, EEEE"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }
}

struct NextPrayerTimeView: View {
    let prayerTimes: PrayerTimes
    @State private var nextPrayer: (name: String, time: Date)?
    @State private var timeRemaining: TimeInterval = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 5) {
            if let prayer = nextPrayer {
                Text("Bir Sonraki Namaz")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                Text(prayer.name)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                HStack {
                    Text(formatTimeRemaining(timeRemaining))
                        .font(.headline)
                        .foregroundStyle(.blue)
                    
                    Text("kaldı")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
            }
        }
        .onAppear(perform: updateNextPrayer)
        .onReceive(timer) { _ in
            updateTimeRemaining()
        }
    }
    
    private func updateNextPrayer() {
        let now = Date()
        let prayers = [
            ("İmsak", prayerTimes.fajr),
            ("Güneş", prayerTimes.sunrise),
            ("Öğle", prayerTimes.dhuhr),
            ("İkindi", prayerTimes.asr),
            ("Akşam", prayerTimes.maghrib),
            ("Yatsı", prayerTimes.isha)
        ]
        
        nextPrayer = prayers.first { $0.1 > now }
        updateTimeRemaining()
    }
    
    private func updateTimeRemaining() {
        guard let prayer = nextPrayer else { return }
        timeRemaining = prayer.time.timeIntervalSince(Date())
    }
    
    private func formatTimeRemaining(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = Int(interval) / 60 % 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

struct DailyPrayerView: View {
    let prayerTimes: PrayerTimes
    
    var body: some View {
        VStack {
            List {
                PrayerTimeRow(name: "İmsak", time: prayerTimes.fajr, icon: "moon.stars.fill")
                PrayerTimeRow(name: "Güneş", time: prayerTimes.sunrise, icon: "sunrise.fill")
                PrayerTimeRow(name: "Öğle", time: prayerTimes.dhuhr, icon: "sun.max.fill")
                PrayerTimeRow(name: "İkindi", time: prayerTimes.asr, icon: "sun.haze.fill")
                PrayerTimeRow(name: "Akşam", time: prayerTimes.maghrib, icon: "sunset.fill")
                PrayerTimeRow(name: "Yatsı", time: prayerTimes.isha, icon: "moon.fill")
            }
            
            // Astronomik bilgiler
            VStack(spacing: 10) {
                Text("Astronomik Bilgiler")
                    .font(.headline)
                    .padding(.top)
                
                HStack(spacing: 20) {
                    VStack {
                        Text("Güneş Doğuş")
                            .font(.caption)
                            .foregroundStyle(.gray)
                        Text(formatTime(prayerTimes.sunrise))
                            .font(.subheadline)
                    }
                    
                    VStack {
                        Text("Güneş Batış")
                            .font(.caption)
                            .foregroundStyle(.gray)
                        Text(formatTime(prayerTimes.maghrib))
                            .font(.subheadline)
                    }
                }
                .padding(.bottom)
            }
            .background(Color(.systemBackground))
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

struct PrayerTimeRow: View {
    let name: String
    let time: Date
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.orange)
                .frame(width: 30)
            
            Text(name)
                .font(.headline)
            
            Spacer()
            
            Text(formatTime(time))
                .font(.headline)
                .foregroundStyle(.blue)
        }
        .padding(.vertical, 5)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

struct WeeklyPrayerView: View {
    let prayerTimes: [PrayerTimes]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                ForEach(prayerTimes, id: \.date) { times in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(formatDate(times.date))
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text("İmsak")
                                    .frame(width: 60, alignment: .leading)
                                Text(formatTime(times.fajr))
                                
                                Spacer()
                                
                                Text("Güneş")
                                    .frame(width: 60, alignment: .leading)
                                Text(formatTime(times.sunrise))
                            }
                            
                            HStack {
                                Text("Öğle")
                                    .frame(width: 60, alignment: .leading)
                                Text(formatTime(times.dhuhr))
                                
                                Spacer()
                                
                                Text("İkindi")
                                    .frame(width: 60, alignment: .leading)
                                Text(formatTime(times.asr))
                            }
                            
                            HStack {
                                Text("Akşam")
                                    .frame(width: 60, alignment: .leading)
                                Text(formatTime(times.maghrib))
                                
                                Spacer()
                                
                                Text("Yatsı")
                                    .frame(width: 60, alignment: .leading)
                                Text(formatTime(times.isha))
                            }
                        }
                        .font(.subheadline)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 5)
                }
            }
            .padding(.vertical)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy, EEEE"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

struct MonthlyPrayerView: View {
    let prayerTimes: [PrayerTimes]
    
    var body: some View {
        List {
            ForEach(prayerTimes, id: \.date) { times in
                NavigationLink(destination: DailyDetailView(prayerTimes: times)) {
                    HStack {
                        Text(formatDate(times.date))
                            .font(.subheadline)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("İmsak: \(formatTime(times.fajr))")
                                .font(.caption)
                                .foregroundStyle(.gray)
                            
                            Text("Yatsı: \(formatTime(times.isha))")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy, EEEE"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

struct YearlyPrayerView: View {
    let prayerTimes: [PrayerTimes]
    
    var body: some View {
        List {
            ForEach(groupByMonth(), id: \.key) { month, times in
                Section(header: Text(month)) {
                    ForEach(times, id: \.date) { time in
                        NavigationLink(destination: DailyDetailView(prayerTimes: time)) {
                            HStack {
                                Text(formatDayOnly(time.date))
                                    .font(.subheadline)
                                
                                Spacer()
                                
                                HStack(spacing: 15) {
                                    VStack(alignment: .trailing) {
                                        Text("İmsak")
                                            .font(.caption2)
                                            .foregroundStyle(.gray)
                                        Text(formatTime(time.fajr))
                                            .font(.caption)
                                    }
                                    
                                    VStack(alignment: .trailing) {
                                        Text("Güneş")
                                            .font(.caption2)
                                            .foregroundStyle(.gray)
                                        Text(formatTime(time.sunrise))
                                            .font(.caption)
                                    }
                                    
                                    VStack(alignment: .trailing) {
                                        Text("Akşam")
                                            .font(.caption2)
                                            .foregroundStyle(.gray)
                                        Text(formatTime(time.maghrib))
                                            .font(.caption)
                                    }
                                }
                            }
                            .padding(.vertical, 3)
                        }
                    }
                }
            }
        }
    }
    
    private func groupByMonth() -> [(key: String, value: [PrayerTimes])] {
        let grouped = Dictionary(grouping: prayerTimes) { time -> String in
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            formatter.locale = Locale(identifier: "tr_TR")
            return formatter.string(from: time.date)
        }
        
        return grouped.sorted { pair1, pair2 in
            let date1 = pair1.value.first!.date
            let date2 = pair2.value.first!.date
            return date1 < date2
        }
    }
    
    private func formatDayOnly(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM, EEEE"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

struct DailyDetailView: View {
    let prayerTimes: PrayerTimes
    
    var body: some View {
        VStack {
            // Tarih Bilgisi
            Text(formatDate(prayerTimes.date))
                .font(.headline)
                .padding()
            
            // Namaz Vakitleri
            List {
                PrayerTimeRow(name: "İmsak", time: prayerTimes.fajr, icon: "moon.stars.fill")
                PrayerTimeRow(name: "Güneş", time: prayerTimes.sunrise, icon: "sunrise.fill")
                PrayerTimeRow(name: "Öğle", time: prayerTimes.dhuhr, icon: "sun.max.fill")
                PrayerTimeRow(name: "İkindi", time: prayerTimes.asr, icon: "sun.haze.fill")
                PrayerTimeRow(name: "Akşam", time: prayerTimes.maghrib, icon: "sunset.fill")
                PrayerTimeRow(name: "Yatsı", time: prayerTimes.isha, icon: "moon.fill")
            }
        }
        .navigationTitle("Namaz Vakitleri")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy, EEEE"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }
}

// MARK: - Error Wrapper
struct ErrorWrapper: Identifiable {
    let id = UUID()
    let message: String
}

struct PrayersView_Previews: PreviewProvider {
    static var previews: some View {
        PrayersView()
    }
} 