import SwiftUI
import MapKit
import Foundation

struct MapsView: View {
    @StateObject private var viewModel = MapsViewModel()
    @State private var showFilters = false
    @State private var mapStyle: MapStyle = .standard
    @State private var showList = false
    @State private var selectedTab = 0
    
    private let tabTitles = ["Harita", "Liste"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - Search Bar and Filter Button
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(Color.gray)
                        
                        TextField("Cami ara...", text: $viewModel.searchText)
                            .foregroundStyle(Color.primary)
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    Button {
                        showFilters.toggle()
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.accentColor)
                    }
                    .sheet(isPresented: $showFilters) {
                        FiltersView(viewModel: viewModel)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                // MARK: - View Tabs
                HStack(spacing: 0) {
                    ForEach(0..<tabTitles.count, id: \.self) { index in
                        Text(tabTitles[index])
                            .fontWeight(selectedTab == index ? .bold : .regular)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(selectedTab == index ? Color.accentColor.opacity(0.1) : Color.clear)
                            .cornerRadius(8)
                            .onTapGesture {
                                withAnimation(.easeInOut) {
                                    selectedTab = index
                                }
                            }
                    }
                    Spacer()
                }
                .padding(.horizontal)
                
                Divider()
                
                // MARK: - Content
                ZStack {
                    // MARK: - Map View
                    if selectedTab == 0 {
                        ZStack {
                            Map(coordinateRegion: $viewModel.region, showsUserLocation: true, annotationItems: viewModel.filteredMosques) { mosque in
                                MapAnnotation(coordinate: mosque.location.coordinates) {
                                    MosqueAnnotationView(mosque: mosque, selected: viewModel.selectedMosque?.id == mosque.id)
                                        .onTapGesture {
                                            viewModel.selectMosque(mosque)
                                        }
                                }
                            }
                            .edgesIgnoringSafeArea(.bottom)
                            
                            VStack {
                                HStack {
                                    Spacer()
                                    
                                    VStack(spacing: 8) {
                                        Button {
                                            viewModel.centerOnUserLocation()
                                        } label: {
                                            Image(systemName: "location")
                                                .font(.system(size: 22))
                                                .padding(8)
                                                .background(Color.white)
                                                .clipShape(Circle())
                                                .shadow(radius: 2)
                                        }
                                        
                                        Menu {
                                            Button("Standart", action: { mapStyle = .standard })
                                            Button("Uydu", action: { mapStyle = .hybrid })
                                        } label: {
                                            Image(systemName: "map")
                                                .font(.system(size: 22))
                                                .padding(8)
                                                .background(Color.white)
                                                .clipShape(Circle())
                                                .shadow(radius: 2)
                                        }
                                        
                                        Button {
                                            viewModel.refreshMosques()
                                        } label: {
                                            Image(systemName: "arrow.clockwise")
                                                .font(.system(size: 22))
                                                .padding(8)
                                                .background(Color.white)
                                                .clipShape(Circle())
                                                .shadow(radius: 2)
                                        }
                                    }
                                    .padding(8)
                                }
                                
                                Spacer()
                                
                                // MARK: - Mosque Detail Card
                                if let mosque = viewModel.selectedMosque {
                                    MosqueDetailCard(mosque: mosque) {
                                        viewModel.getDirections(to: mosque)
                                    } onInfoAction: {
                                        viewModel.selectedMosqueForDetailView = mosque
                                    }
                                    .transition(.move(edge: .bottom))
                                }
                            }
                            .padding(.top, 8)
                        }
                    }
                    // MARK: - List View
                    else {
                        MosqueListView(viewModel: viewModel)
                    }
                    
                    // MARK: - Loading View
                    if viewModel.isLoading {
                        LoadingView()
                    }
                }
                
                // MARK: - Error Alert
                .alert(item: Binding<AlertItem?>(
                    get: { viewModel.error != nil ? AlertItem(message: viewModel.error!) : nil },
                    set: { _ in viewModel.error = nil }
                )) { alert in
                    Alert(title: Text("Hata"), message: Text(alert.message), dismissButton: .default(Text("Tamam")))
                }
            }
            .navigationTitle("Camiler")
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(item: $viewModel.selectedMosqueForDetailView) { mosque in
                MosqueDetailView(mosque: mosque)
            }
        }
        .onAppear {
            viewModel.fetchMosques()
        }
    }
}

// MARK: - Support Views

struct MosqueAnnotationView: View {
    let mosque: Mosque
    let selected: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: selected ? 36 : 30))
                    .foregroundStyle(selected ? Color.green : Color.accentColor)
                
                if selected {
                    Image(systemName: "building.columns.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.white)
                        .offset(y: -4)
                }
            }
            
            if selected {
                Text(mosque.name)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(4)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(4)
                    .shadow(radius: 1)
            }
        }
    }
}

struct MosqueDetailCard: View {
    let mosque: Mosque
    let onDirectionsAction: () -> Void
    let onInfoAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(mosque.name)
                        .font(.headline)
                    
                    if let arabicName = mosque.arabicName {
                        Text(arabicName)
                            .font(.subheadline)
                            .foregroundStyle(Color.gray)
                    }
                    
                    HStack {
                        ForEach(0..<Int(mosque.rating ?? 0), id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .foregroundStyle(Color.yellow)
                                .font(.system(size: 12))
                        }
                        
                        if let rating = mosque.rating, rating.truncatingRemainder(dividingBy: 1) >= 0.5 {
                            Image(systemName: "star.leadinghalf.filled")
                                .foregroundStyle(Color.yellow)
                                .font(.system(size: 12))
                        }
                        
                        Text(String(format: "%.1f", mosque.rating ?? 0))
                            .font(.caption)
                            .foregroundStyle(Color.gray)
                        
                        if let reviewCount = mosque.reviewCount {
                            Text("(\(reviewCount))")
                                .font(.caption)
                                .foregroundStyle(Color.gray)
                        }
                    }
                }
                
                Spacer()
                
                VStack(spacing: 12) {
                    Button {
                        onInfoAction()
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.system(size: 18))
                            .foregroundStyle(Color.accentColor)
                    }
                    
                    Button {
                        onDirectionsAction()
                    } label: {
                        Image(systemName: "arrow.triangle.turn.up.right.circle")
                            .font(.system(size: 18))
                            .foregroundStyle(Color.accentColor)
                    }
                }
            }
            
            Text(mosque.address.formattedAddress)
                .font(.footnote)
                .foregroundStyle(Color.secondary)
            
            HStack(spacing: 10) {
                MosqueServiceIcon(
                    iconName: "wand.and.stars",
                    available: mosque.services.hasFridayPrayer,
                    label: "Cuma"
                )
                
                MosqueServiceIcon(
                    iconName: "drop.fill",
                    available: mosque.services.hasWuduFacilities,
                    label: "Abdest"
                )
                
                MosqueServiceIcon(
                    iconName: "car.fill",
                    available: mosque.services.hasParking,
                    label: "Otopark"
                )
                
                MosqueServiceIcon(
                    iconName: "person.fill",
                    available: mosque.services.hasWomenSection,
                    label: "Kadın Bölümü"
                )
                
                MosqueServiceIcon(
                    iconName: "figure.roll",
                    available: mosque.services.hasWheelchairAccess,
                    label: "Erişilebilir"
                )
                
                Spacer()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 4)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
}

struct MosqueServiceIcon: View {
    let iconName: String
    let available: Bool
    let label: String
    
    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: iconName)
                .font(.system(size: 14))
                .foregroundStyle(available ? Color.accentColor : Color.gray.opacity(0.5))
            
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(available ? Color.primary : Color.gray.opacity(0.5))
        }
    }
}

struct MosqueListView: View {
    @ObservedObject var viewModel: MapsViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if viewModel.filteredMosques.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.gray)
                        
                        Text("Arama kriterlerine uygun cami bulunamadı.")
                            .font(.headline)
                        
                        Button {
                            viewModel.resetFilters()
                            viewModel.searchText = ""
                        } label: {
                            Text("Filtreleri Temizle")
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.accentColor)
                                .foregroundStyle(Color.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.top, 40)
                } else {
                    ForEach(viewModel.filteredMosques) { mosque in
                        MosqueListItem(mosque: mosque) {
                            viewModel.selectedMosqueForDetailView = mosque
                        } onSelectAction: {
                            viewModel.selectMosque(mosque)
                            withAnimation {
                                viewModel.selectedTab = 0
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
}

struct MosqueListItem: View {
    let mosque: Mosque
    let onInfoAction: () -> Void
    let onSelectAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(mosque.name)
                        .font(.headline)
                    
                    if let arabicName = mosque.arabicName {
                        Text(arabicName)
                            .font(.subheadline)
                            .foregroundStyle(Color.gray)
                    }
                }
                
                Spacer()
                
                HStack {
                    if let rating = mosque.rating {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .foregroundStyle(Color.yellow)
                                .font(.system(size: 12))
                            
                            Text(String(format: "%.1f", rating))
                                .font(.footnote)
                                .foregroundStyle(Color.secondary)
                        }
                    }
                }
            }
            
            Text(mosque.address.formattedAddress)
                .font(.footnote)
                .foregroundStyle(Color.secondary)
            
            HStack {
                HStack(spacing: 8) {
                    if mosque.services.hasFridayPrayer {
                        Label("Cuma", systemImage: "wand.and.stars")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.accentColor.opacity(0.1))
                            .cornerRadius(4)
                    }
                    
                    if mosque.services.hasWuduFacilities {
                        Label("Abdest", systemImage: "drop.fill")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.accentColor.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button {
                        onSelectAction()
                    } label: {
                        Image(systemName: "location")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.accentColor)
                    }
                    
                    Button {
                        onInfoAction()
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.accentColor)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct FiltersView: View {
    @ObservedObject var viewModel: MapsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var tempFilterOptions: FilterOptions
    
    init(viewModel: MapsViewModel) {
        self.viewModel = viewModel
        _tempFilterOptions = State(initialValue: viewModel.filterOptions)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Mesafe")) {
                    VStack {
                        HStack {
                            Text("En fazla mesafe:")
                            Spacer()
                            Text(tempFilterOptions.maxDistance == Double.infinity ? "Limitsiz" : "\(Int(tempFilterOptions.maxDistance)) km")
                                .foregroundStyle(Color.secondary)
                        }
                        
                        Slider(value: Binding(
                            get: { tempFilterOptions.maxDistance == Double.infinity ? 20 : tempFilterOptions.maxDistance },
                            set: { tempFilterOptions.maxDistance = $0 >= 20 ? Double.infinity : $0 }
                        ), in: 1...20, step: 1)
                    }
                }
                
                Section(header: Text("Değerlendirme")) {
                    HStack {
                        Text("En az yıldız:")
                        Spacer()
                        HStack {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= Int(tempFilterOptions.minRating) ? "star.fill" : "star")
                                    .foregroundStyle(star <= Int(tempFilterOptions.minRating) ? Color.yellow : Color.gray)
                                    .onTapGesture {
                                        tempFilterOptions.minRating = Double(star)
                                    }
                            }
                        }
                    }
                }
                
                Section(header: Text("Hizmetler")) {
                    Toggle("Cuma Namazı", isOn: $tempFilterOptions.hasFridayPrayer)
                    Toggle("Abdest Alma Yeri", isOn: $tempFilterOptions.hasWuduFacilities)
                    Toggle("Otopark", isOn: $tempFilterOptions.hasParking)
                    Toggle("Kadınlar Bölümü", isOn: $tempFilterOptions.hasWomenSection)
                    Toggle("Engelli Erişimi", isOn: $tempFilterOptions.hasWheelchairAccess)
                }
                
                Section {
                    Button("Filtreleri Temizle") {
                        tempFilterOptions = FilterOptions()
                    }
                }
            }
            .navigationTitle("Filtreler")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Uygula") {
                        viewModel.filterOptions = tempFilterOptions
                        viewModel.applyFilters()
                        dismiss()
                    }
                }
            }
        }
    }
}

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                    .padding()
                
                Text("Yükleniyor...")
                    .foregroundStyle(Color.white)
                    .font(.headline)
            }
            .padding(24)
            .background(Color(.systemGray6).opacity(0.8))
            .cornerRadius(12)
        }
    }
}

struct MosqueDetailView: View {
    let mosque: Mosque
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // MARK: - Hero Image
                    ZStack(alignment: .topTrailing) {
                        Image("mosque_placeholder")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                        
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 30))
                                .padding(16)
                                .foregroundStyle(Color.white)
                                .shadow(radius: 2)
                        }
                    }
                    
                    // MARK: - Mosque Information
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(mosque.name)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            if let arabicName = mosque.arabicName {
                                Text(arabicName)
                                    .font(.title2)
                                    .foregroundStyle(Color.secondary)
                            }
                            
                            HStack {
                                ForEach(0..<Int(mosque.rating ?? 0), id: \.self) { _ in
                                    Image(systemName: "star.fill")
                                        .foregroundStyle(Color.yellow)
                                }
                                
                                if let rating = mosque.rating, rating.truncatingRemainder(dividingBy: 1) >= 0.5 {
                                    Image(systemName: "star.leadinghalf.filled")
                                        .foregroundStyle(Color.yellow)
                                }
                                
                                Text(String(format: "%.1f", mosque.rating ?? 0))
                                    .foregroundStyle(Color.secondary)
                                
                                if let reviewCount = mosque.reviewCount {
                                    Text("(\(reviewCount) değerlendirme)")
                                        .foregroundStyle(Color.secondary)
                                }
                            }
                        }
                        
                        Divider()
                        
                        // MARK: - Address
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Adres", systemImage: "mappin.and.ellipse")
                                .font(.headline)
                            
                            Text(mosque.address.formattedAddress)
                                .foregroundStyle(Color.secondary)
                            
                            Button {
                                let destination = MKMapItem(placemark: MKPlacemark(coordinate: mosque.location.coordinates))
                                destination.name = mosque.name
                                
                                MKMapItem.openMaps(
                                    with: [destination],
                                    launchOptions: nil
                                )
                            } label: {
                                Text("Haritada Göster")
                                    .font(.subheadline)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(Color.accentColor)
                                    .foregroundStyle(Color.white)
                                    .cornerRadius(8)
                            }
                        }
                        
                        Divider()
                        
                        // MARK: - Services
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Hizmetler", systemImage: "list.bullet")
                                .font(.headline)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 16) {
                                ServiceItem(
                                    iconName: "wand.and.stars",
                                    title: "Cuma Namazı",
                                    available: mosque.services.hasFridayPrayer
                                )
                                
                                ServiceItem(
                                    iconName: "drop.fill",
                                    title: "Abdest Alma Yeri",
                                    available: mosque.services.hasWuduFacilities
                                )
                                
                                ServiceItem(
                                    iconName: "car.fill",
                                    title: "Otopark",
                                    available: mosque.services.hasParking
                                )
                                
                                ServiceItem(
                                    iconName: "person.fill",
                                    title: "Kadınlar Bölümü",
                                    available: mosque.services.hasWomenSection
                                )
                                
                                ServiceItem(
                                    iconName: "figure.roll",
                                    title: "Engelli Erişimi",
                                    available: mosque.services.hasWheelchairAccess
                                )
                                
                                ServiceItem(
                                    iconName: "snowflake",
                                    title: "Klima",
                                    available: mosque.services.hasAirConditioning
                                )
                                
                                ServiceItem(
                                    iconName: "flame.fill",
                                    title: "Isıtma",
                                    available: mosque.services.hasHeating
                                )
                                
                                ServiceItem(
                                    iconName: "books.vertical.fill",
                                    title: "Kütüphane",
                                    available: mosque.services.hasLibrary
                                )
                                
                                ServiceItem(
                                    iconName: "book.fill",
                                    title: "Kuran Kursları",
                                    available: mosque.services.hasQuranClasses
                                )
                            }
                        }
                        
                        Divider()
                        
                        // MARK: - Prayer Times Section
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Namaz Vakitleri", systemImage: "clock")
                                .font(.headline)
                            
                            // Bu kısım örnek veri içerir. Gerçek bir API'den alınacak verilerle değiştirilmelidir.
                            VStack(spacing: 12) {
                                PrayerTimeRow(name: "İmsak", time: "05:12")
                                PrayerTimeRow(name: "Güneş", time: "06:45")
                                PrayerTimeRow(name: "Öğle", time: "13:06")
                                PrayerTimeRow(name: "İkindi", time: "16:32")
                                PrayerTimeRow(name: "Akşam", time: "19:21")
                                PrayerTimeRow(name: "Yatsı", time: "20:54")
                            }
                            
                            Text("* Namaz vakitleri gösterge amaçlıdır. Kesin zamanlar için görevlilere danışınız.")
                                .font(.caption)
                                .foregroundStyle(Color.secondary)
                                .padding(.top, 4)
                        }
                        
                        Divider()
                        
                        // MARK: - About
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Hakkında", systemImage: "info.circle")
                                .font(.headline)
                            
                            // Bu kısım örnek veri içerir. Gerçek bir API'den alınacak verilerle değiştirilmelidir.
                            if mosque.name.contains("Süleymaniye") {
                                Text("Süleymaniye Camii, İstanbul'un en büyük camilerinden biridir. 1550-1557 yılları arasında, Kanuni Sultan Süleyman adına Mimar Sinan tarafından inşa edilmiştir. Osmanlı camilerinin en önemli örneklerinden biri olarak kabul edilir. Caminin dört minaresi vardır ve kubbe yüksekliği 53 metredir.")
                                    .foregroundStyle(Color.secondary)
                            } else if mosque.name.contains("Sultan Ahmet") {
                                Text("Sultan Ahmet Camii, 1609-1617 yılları arasında Sultan I. Ahmed tarafından yaptırılmıştır. Altı minaresi vardır ve dış kısmında kullanılan İznik çinilerinin mavi rengi nedeniyle Batı dünyasında 'Mavi Camii' olarak da bilinir. İstanbul'un sembol yapılarından biridir.")
                                    .foregroundStyle(Color.secondary)
                            } else if mosque.name.contains("Fatih") {
                                Text("Fatih Camii, İstanbul'un fethinden sonra Fatih Sultan Mehmed tarafından 1463-1470 yılları arasında yaptırılmıştır. 1766 depreminde yıkılan cami, III. Mustafa döneminde yeniden inşa edilmiştir. Fatih Sultan Mehmed'in türbesi de bu caminin bahçesinde bulunmaktadır.")
                                    .foregroundStyle(Color.secondary)
                            } else if mosque.name.contains("Eyüp") {
                                Text("Eyüp Sultan Camii, İstanbul'un en kutsal mekânlarından biridir. Hz. Muhammed'in sancaktarı Ebu Eyyub el-Ensari'nin kabri üzerine inşa edilmiştir. İlk olarak Fatih Sultan Mehmed tarafından yaptırılan cami, 1800'lerde III. Selim tarafından yenilenmiştir. Müslümanlar için önemli bir ziyaret yeridir.")
                                    .foregroundStyle(Color.secondary)
                            } else {
                                Text("Bu cami hakkında detaylı bilgi bulunmamaktadır. Diyanet İşleri Başkanlığı veritabanından daha fazla bilgi eklenecektir.")
                                    .foregroundStyle(Color.secondary)
                            }
                        }
                        
                        Divider()
                        
                        // MARK: - Contact and Directions
                        HStack {
                            Button {
                                // Yol tarifi
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
                            } label: {
                                Label("Yol Tarifi", systemImage: "arrow.triangle.turn.up.right.circle")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.accentColor)
                                    .foregroundStyle(Color.white)
                                    .cornerRadius(8)
                            }
                            
                            if let _ = mosque.contact?.phone {
                                Button {
                                    // Arama fonksiyonu
                                    if let phone = mosque.contact?.phone,
                                       let url = URL(string: "tel://\(phone)") {
                                        UIApplication.shared.open(url)
                                    }
                                } label: {
                                    Label("Ara", systemImage: "phone.fill")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.green)
                                        .foregroundStyle(Color.white)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .edgesIgnoringSafeArea(.top)
            .navigationBarHidden(true)
        }
    }
}

struct ServiceItem: View {
    let iconName: String
    let title: String
    let available: Bool
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundStyle(available ? Color.accentColor : Color.gray.opacity(0.5))
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
                .foregroundStyle(available ? Color.primary : Color.gray.opacity(0.5))
            
            Spacer()
            
            if available {
                Image(systemName: "checkmark")
                    .foregroundStyle(Color.green)
            } else {
                Image(systemName: "xmark")
                    .foregroundStyle(Color.red.opacity(0.7))
            }
        }
        .padding(.vertical, 4)
    }
}

struct PrayerTimeRow: View {
    let name: String
    let time: String
    
    var body: some View {
        HStack {
            Text(name)
                .font(.subheadline)
                .foregroundStyle(Color.primary)
                .frame(width: 80, alignment: .leading)
            
            Spacer()
            
            Text(time)
                .font(.subheadline)
                .foregroundStyle(Color.primary)
                .fontWeight(.medium)
        }
    }
}

struct AlertItem: Identifiable {
    let id = UUID()
    let message: String
}

struct MapsView_Previews: PreviewProvider {
    static var previews: some View {
        MapsView()
    }
} 