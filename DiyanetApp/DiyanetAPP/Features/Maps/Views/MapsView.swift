import SwiftUI
import MapKit

struct MapsView: View {
    @StateObject private var viewModel = MapsViewModel()
    @State private var showMosqueList = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                // Harita
                Map(coordinateRegion: $viewModel.region,
                    showsUserLocation: true,
                    annotationItems: viewModel.filteredMosques) { mosque in
                    MapAnnotation(coordinate: mosque.location.coordinates) {
                        MosqueAnnotationView(mosque: mosque, isSelected: viewModel.selectedMosque?.id == mosque.id) {
                            viewModel.selectMosque(mosque)
                        }
                    }
                }
                .ignoresSafeArea()
                
                // Arama Çubuğu
                SearchBar(text: $viewModel.searchText)
                    .padding()
                
                // Cami Listesi Butonu
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showMosqueList.toggle()
                        }) {
                            Image(systemName: "list.bullet")
                                .font(.title2)
                                .padding()
                                .background(Color(.systemBackground))
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        .padding()
                    }
                }
                
                // Seçili Cami Detayı
                if let mosque = viewModel.selectedMosque {
                    VStack {
                        Spacer()
                        MosqueDetailCard(mosque: mosque) {
                            viewModel.getDirections(to: mosque)
                        }
                    }
                }
            }
            .navigationTitle("Camiler")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showMosqueList) {
                MosqueListView(mosques: viewModel.filteredMosques, selectedMosque: $viewModel.selectedMosque)
            }
            .onAppear {
                viewModel.fetchMosques()
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
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.gray)
            
            TextField("Cami ara...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.gray)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct MosqueAnnotationView: View {
    let mosque: Mosque
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Image(systemName: "building.columns.fill")
                    .font(.system(size: isSelected ? 24 : 20))
                    .foregroundStyle(isSelected ? .blue : .gray)
                
                Image(systemName: "triangle.fill")
                    .font(.system(size: isSelected ? 12 : 10))
                    .rotationEffect(.degrees(180))
                    .offset(y: -5)
                    .foregroundStyle(isSelected ? .blue : .gray)
            }
        }
    }
}

struct MosqueDetailCard: View {
    let mosque: Mosque
    let getDirections: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading) {
                    Text(mosque.name)
                        .font(.headline)
                    
                    if let arabicName = mosque.arabicName {
                        Text(arabicName)
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    }
                }
                
                Spacer()
                
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
            
            Text(mosque.address.formattedAddress)
                .font(.caption)
                .foregroundStyle(.gray)
            
            // Hizmetler
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    if mosque.services.hasFridayPrayer {
                        ServiceTag(icon: "clock.fill", text: "Cuma Namazı")
                    }
                    if mosque.services.hasWuduFacilities {
                        ServiceTag(icon: "drop.fill", text: "Abdesthane")
                    }
                    if mosque.services.hasParking {
                        ServiceTag(icon: "car.fill", text: "Otopark")
                    }
                    if mosque.services.hasWomenSection {
                        ServiceTag(icon: "person.2.fill", text: "Kadınlar Bölümü")
                    }
                    if mosque.services.hasWheelchairAccess {
                        ServiceTag(icon: "figure.roll", text: "Engelli Erişimi")
                    }
                }
            }
            
            Button(action: getDirections) {
                HStack {
                    Image(systemName: "location.fill")
                    Text("Yol Tarifi Al")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundStyle(.white)
                .cornerRadius(10)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding()
    }
}

struct ServiceTag: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

struct MosqueListView: View {
    let mosques: [Mosque]
    @Binding var selectedMosque: Mosque?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List(mosques) { mosque in
                Button(action: {
                    selectedMosque = mosque
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(mosque.name)
                                .font(.headline)
                            Text(mosque.address.formattedAddress)
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                        
                        Spacer()
                        
                        if let rating = mosque.rating {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(.yellow)
                                Text(String(format: "%.1f", rating))
                            }
                            .font(.caption)
                        }
                    }
                }
            }
            .navigationTitle("Yakındaki Camiler")
            .navigationBarItems(trailing: Button("Kapat") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// MARK: - Preview
struct MapsView_Previews: PreviewProvider {
    static var previews: some View {
        MapsView()
    }
} 