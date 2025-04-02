import SwiftUI

struct PrayersView: View {
    @StateObject private var viewModel = PrayersViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack {
                // Üst Bilgi Kartı
                if let prayerTimes = viewModel.prayerTimes {
                    PrayerTimesHeaderCard(prayerTimes: prayerTimes)
                        .padding()
                }
                
                // Tab Seçici
                Picker("Görünüm", selection: $selectedTab) {
                    Text("Günlük").tag(0)
                    Text("Haftalık").tag(1)
                    Text("Aylık").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Tab İçeriği
                TabView(selection: $selectedTab) {
                    // Günlük Görünüm
                    if let prayerTimes = viewModel.prayerTimes {
                        DailyPrayerView(prayerTimes: prayerTimes)
                            .tag(0)
                    }
                    
                    // Haftalık Görünüm
                    WeeklyPrayerView(prayerTimes: viewModel.weeklyPrayerTimes)
                        .tag(1)
                    
                    // Aylık Görünüm
                    MonthlyPrayerView(prayerTimes: viewModel.monthlyPrayerTimes)
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Namaz Vakitleri")
            .navigationBarItems(trailing: locationButton)
            .refreshable {
                viewModel.refreshData()
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
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
        }
    }
    
    private var locationButton: some View {
        Button(action: {
            // TODO: Konum seçme sayfasına yönlendir
        }) {
            Image(systemName: "location")
                .imageScale(.large)
        }
    }
}

// MARK: - Supporting Views
struct PrayerTimesHeaderCard: View {
    let prayerTimes: PrayerTimes
    
    var body: some View {
        VStack(spacing: 10) {
            Text(prayerTimes.location.city)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(formatDate(prayerTimes.date))
                .font(.subheadline)
                .foregroundStyle(.gray)
            
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
                
                Text(formatTimeRemaining(timeRemaining))
                    .font(.headline)
                    .foregroundStyle(.blue)
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
        List {
            PrayerTimeRow(name: "İmsak", time: prayerTimes.fajr)
            PrayerTimeRow(name: "Güneş", time: prayerTimes.sunrise)
            PrayerTimeRow(name: "Öğle", time: prayerTimes.dhuhr)
            PrayerTimeRow(name: "İkindi", time: prayerTimes.asr)
            PrayerTimeRow(name: "Akşam", time: prayerTimes.maghrib)
            PrayerTimeRow(name: "Yatsı", time: prayerTimes.isha)
        }
    }
}

struct PrayerTimeRow: View {
    let name: String
    let time: Date
    
    var body: some View {
        HStack {
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
        List(prayerTimes, id: \.date) { times in
            VStack(alignment: .leading, spacing: 10) {
                Text(formatDate(times.date))
                    .font(.headline)
                
                VStack(spacing: 5) {
                    PrayerTimeRow(name: "İmsak", time: times.fajr)
                    PrayerTimeRow(name: "Güneş", time: times.sunrise)
                    PrayerTimeRow(name: "Öğle", time: times.dhuhr)
                    PrayerTimeRow(name: "İkindi", time: times.asr)
                    PrayerTimeRow(name: "Akşam", time: times.maghrib)
                    PrayerTimeRow(name: "Yatsı", time: times.isha)
                }
            }
            .padding(.vertical, 5)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy, EEEE"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }
}

struct MonthlyPrayerView: View {
    let prayerTimes: [PrayerTimes]
    
    var body: some View {
        List(prayerTimes, id: \.date) { times in
            NavigationLink(destination: DailyPrayerView(prayerTimes: times)) {
                HStack {
                    Text(formatDate(times.date))
                        .font(.subheadline)
                    Spacer()
                    Text(formatTime(times.fajr))
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Preview
struct PrayersView_Previews: PreviewProvider {
    static var previews: some View {
        PrayersView()
    }
} 