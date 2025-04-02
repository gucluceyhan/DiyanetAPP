import SwiftUI

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

// MARK: - Preview
struct NearbyMosquesSection_Previews: PreviewProvider {
    static var previews: some View {
        NearbyMosquesSection(mosques: [
            Mosque(
                id: "1",
                name: "Süleymaniye Camii",
                arabicName: "جامع السليمانية",
                location: MosqueLocation(
                    coordinates: CLLocationCoordinate2D(
                        latitude: 41.0162,
                        longitude: 28.9639
                    ),
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
            )
        ])
        .previewLayout(.sizeThatFits)
        .padding()
    }
} 