import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
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
            .navigationBarItems(trailing: profileButton)
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
    
    private var profileButton: some View {
        NavigationLink(destination: ProfileView()) {
            Image(systemName: "person.circle")
                .imageScale(.large)
        }
    }
}

// MARK: - Supporting Views
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
                        NavigationLink(destination: MosqueDetailView(mosque: mosque)) {
                            MosqueCard(mosque: mosque)
                        }
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
    let guides: [Guide]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Öne Çıkan Rehberler")
                .font(.title2)
                .fontWeight(.bold)
            
            ForEach(guides) { guide in
                NavigationLink(destination: GuideDetailView(guide: guide)) {
                    GuideCard(guide: guide)
                }
            }
        }
    }
}

struct GuideCard: View {
    let guide: Guide
    
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
                Label(guide.category.rawValue.capitalized, systemImage: "book")
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

// MARK: - Helper Types
struct ErrorWrapper: Identifiable {
    let id = UUID()
    let message: String
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
} 