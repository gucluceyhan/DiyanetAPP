import SwiftUI

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

// MARK: - Preview
struct PrayerTimesCard_Previews: PreviewProvider {
    static var previews: some View {
        PrayerTimesCard(prayerTimes: PrayerTimes(
            date: Date(),
            fajr: Date(),
            sunrise: Date(),
            dhuhr: Date(),
            asr: Date(),
            maghrib: Date(),
            isha: Date(),
            location: Location(
                latitude: 41.0082,
                longitude: 28.9784,
                city: "İstanbul",
                country: "Türkiye",
                timezone: "Europe/Istanbul"
            )
        ))
        .previewLayout(.sizeThatFits)
        .padding()
    }
} 