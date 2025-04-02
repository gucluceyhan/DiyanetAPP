import SwiftUI

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

// MARK: - Preview
struct FeaturedGuidesSection_Previews: PreviewProvider {
    static var previews: some View {
        FeaturedGuidesSection(guides: [
            Guide(
                id: "1",
                title: "Namaz Nasıl Kılınır?",
                description: "İslam'ın beş şartından biri olan namazın kılınışı hakkında detaylı rehber.",
                content: "Namazın kılınışı şu adımlardan oluşur...",
                category: .prayer,
                author: Author(
                    id: "1",
                    name: "Ahmet Yılmaz",
                    title: "Din Görevlisi",
                    bio: nil,
                    avatarUrl: nil,
                    socialMedia: nil
                ),
                tags: ["namaz", "ibadet", "rehber"],
                images: nil,
                videoUrl: nil,
                readTime: 10,
                createdAt: Date(),
                updatedAt: Date(),
                isBookmarked: false
            )
        ])
        .previewLayout(.sizeThatFits)
        .padding()
    }
} 