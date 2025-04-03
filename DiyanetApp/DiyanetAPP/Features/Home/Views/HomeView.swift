import SwiftUI
import MapKit

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
            // Cami Görseli
            ZStack {
                // Cami ID'sine göre örnek görseller (gerçek uygulamada API'den gelen resimler kullanılır)
                Image("Mosques/mosque\(mosque.id)")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 150)
                    .clipped()
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                // Cami bilgi etiketi
                VStack {
                    Spacer()
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(mosque.name)
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                            
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(Color.yellow)
                                    .font(.system(size: 10))
                                Text(String(format: "%.1f", mosque.rating))
                                    .font(.system(size: 10))
                                    .foregroundStyle(.white)
                            }
                        }
                        Spacer()
                    }
                    .padding(8)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.black.opacity(0.7), Color.black.opacity(0)]),
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .cornerRadius(10)
                }
            }
            
            // Cami bilgileri
            VStack(alignment: .leading, spacing: 6) {
                Text(mosque.name)
                    .font(.headline)
                    .lineLimit(1)
                
                // Cami Uzaklığı
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundStyle(Color.accentColor)
                        .font(.caption)
                    
                    Text(mosque.address.formattedAddress)
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .lineLimit(1)
                }
                
                // Hizmetler
                HStack(spacing: 8) {
                    if mosque.services.hasFridayPrayer {
                        Image(systemName: "calendar")
                            .foregroundStyle(Color.green)
                            .font(.caption)
                    }
                    
                    if mosque.services.hasWuduFacilities {
                        Image(systemName: "drop.fill")
                            .foregroundStyle(Color.blue)
                            .font(.caption)
                    }
                    
                    if mosque.services.hasParking {
                        Image(systemName: "car.fill")
                            .foregroundStyle(Color.purple)
                            .font(.caption)
                    }
                    
                    if mosque.services.hasWomenSection {
                        Image(systemName: "person.2.fill")
                            .foregroundStyle(Color.pink)
                            .font(.caption)
                    }
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 4)
            .padding(.top, 4)
        }
        .frame(width: 200)
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
        )
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

// MARK: - Preview Helpers

struct MosqueDetailView: View {
    let mosque: Mosque
    @Environment(\.presentationMode) var presentationMode
    @State private var showMap = false
    @State private var showFullMap = false
    @State private var region: MKCoordinateRegion
    
    init(mosque: Mosque) {
        self.mosque = mosque
        _region = State(initialValue: MKCoordinateRegion(
            center: mosque.location.coordinates,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Cami Görseli
                ZStack(alignment: .topTrailing) {
                    Image("Mosques/mosque\(mosque.id)")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 250)
                        .clipped()
                        .cornerRadius(10)
                    
                    // Yıldız puanı
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundStyle(Color.yellow)
                        Text(String(format: "%.1f", mosque.rating))
                            .fontWeight(.bold)
                        Text("(\(mosque.reviewCount))")
                            .foregroundStyle(.white)
                    }
                    .padding(8)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(20)
                    .padding(12)
                }
                
                // Cami İsmi
                VStack(alignment: .leading, spacing: 4) {
                    Text(mosque.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if let arabicName = mosque.arabicName {
                        Text(arabicName)
                            .font(.title3)
                            .foregroundStyle(.gray)
                    }
                }
                .padding(.horizontal)
                
                // Mini Harita Önizlemesi ve Adres
                VStack(alignment: .leading, spacing: 10) {
                    // Mini harita
                    ZStack(alignment: .bottomTrailing) {
                        Map(coordinateRegion: $region, interactionModes: [], annotationItems: [mosque]) { mosque in
                            MapAnnotation(coordinate: mosque.location.coordinates) {
                                Image(systemName: "building.columns.fill")
                                    .font(.title)
                                    .foregroundStyle(Color.accentColor)
                            }
                        }
                        .frame(height: 150)
                        .cornerRadius(10)
                        .disabled(true)
                        .onTapGesture {
                            showFullMap = true
                        }
                        
                        Button(action: {
                            showFullMap = true
                        }) {
                            Text("Büyüt")
                                .font(.footnote)
                                .padding(8)
                                .background(Color.black.opacity(0.6))
                                .foregroundStyle(.white)
                                .cornerRadius(8)
                        }
                        .padding(8)
                    }
                    
                    // Adres
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Adres", systemImage: "mappin.and.ellipse")
                            .font(.headline)
                        
                        Text(mosque.address.street)
                            .font(.body)
                        Text("\(mosque.address.city), \(mosque.address.state)")
                            .font(.body)
                            .foregroundStyle(.secondary)
                        
                        HStack {
                            Button(action: {
                                showFullMap = true
                            }) {
                                Label("Haritada Göster", systemImage: "map")
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .foregroundStyle(.white)
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                            
                            Button(action: getDirections) {
                                Label("Yol Tarifi Al", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .foregroundStyle(.white)
                                    .background(Color.green)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.top, 4)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Hizmetler ve Özellikler
                VStack(alignment: .leading, spacing: 8) {
                    Label("Hizmetler", systemImage: "checkmark.circle")
                        .font(.headline)
                        .padding(.bottom, 4)
                    
                    ServicesGridView(services: mosque.services)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Namaz Vakitleri (Bu bölüm gerçek uygulamada o camiye ait namaz vakitlerini gösterebilir)
                VStack(alignment: .leading, spacing: 8) {
                    Label("Namaz Vakitleri", systemImage: "clock")
                        .font(.headline)
                    
                    HStack {
                        PrayerTimeItem(name: "Sabah", time: "05:45")
                        Spacer()
                        PrayerTimeItem(name: "Öğle", time: "13:05")
                        Spacer()
                        PrayerTimeItem(name: "İkindi", time: "16:20")
                    }
                    
                    HStack {
                        PrayerTimeItem(name: "Akşam", time: "19:15")
                        Spacer()
                        PrayerTimeItem(name: "Yatsı", time: "20:45")
                        Spacer()
                        PrayerTimeItem(name: "Cuma", time: "13:30")
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationBarTitle("", displayMode: .inline)
        .sheet(isPresented: $showFullMap) {
            MosqueMapView(mosque: mosque)
        }
    }
    
    func getDirections() {
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: mosque.location.coordinates))
        destination.name = mosque.name
        
        MKMapItem.openMaps(
            with: [destination],
            launchOptions: [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
            ]
        )
    }
}

struct ServicesGridView: View {
    let services: MosqueServices
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            if services.hasFridayPrayer {
                ServiceItem(icon: "calendar", title: "Cuma Namazı", color: .green)
            }
            
            if services.hasWuduFacilities {
                ServiceItem(icon: "drop.fill", title: "Abdesthane", color: .blue)
            }
            
            if services.hasParking {
                ServiceItem(icon: "car.fill", title: "Otopark", color: .purple)
            }
            
            if services.hasWomenSection {
                ServiceItem(icon: "person.2.fill", title: "Kadınlar Bölümü", color: .pink)
            }
            
            if services.hasWheelchairAccess {
                ServiceItem(icon: "figure.roll", title: "Engelli Erişimi", color: .orange)
            }
            
            if services.hasAirConditioning {
                ServiceItem(icon: "snowflake", title: "Klima", color: .cyan)
            }
            
            if services.hasHeating {
                ServiceItem(icon: "flame.fill", title: "Isıtma", color: .red)
            }
            
            if services.hasLibrary {
                ServiceItem(icon: "book.fill", title: "Kütüphane", color: .brown)
            }
            
            if services.hasQuranClasses {
                ServiceItem(icon: "text.book.closed.fill", title: "Kur'an Kursları", color: .indigo)
            }
        }
    }
}

struct ServiceItem: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 30)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.primary)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct MosqueMapView: View {
    let mosque: Mosque
    @Environment(\.presentationMode) var presentationMode
    @State private var region: MKCoordinateRegion
    
    init(mosque: Mosque) {
        self.mosque = mosque
        _region = State(initialValue: MKCoordinateRegion(
            center: mosque.location.coordinates,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        NavigationView {
            Map(coordinateRegion: $region, annotationItems: [mosque]) { mosque in
                MapAnnotation(coordinate: mosque.location.coordinates) {
                    VStack {
                        Image(systemName: "building.columns.fill")
                            .font(.title)
                            .foregroundStyle(Color.blue)
                        
                        Text(mosque.name)
                            .font(.caption)
                            .padding(5)
                            .background(Color.white)
                            .cornerRadius(5)
                    }
                }
            }
            .ignoresSafeArea()
            .navigationBarTitle(mosque.name, displayMode: .inline)
            .navigationBarItems(trailing: Button("Kapat") {
                presentationMode.wrappedValue.dismiss()
            })
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button(action: getDirections) {
                        Label("Yol Tarifi Al", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
        }
    }
    
    func getDirections() {
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: mosque.location.coordinates))
        destination.name = mosque.name
        
        MKMapItem.openMaps(
            with: [destination],
            launchOptions: [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
            ]
        )
    }
} 