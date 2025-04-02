import SwiftUI

struct GuideDetailView: View {
    let guide: Guide
    @Environment(\.presentationMode) var presentationMode
    @State private var showShareSheet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Başlık ve meta bilgiler
                VStack(alignment: .leading, spacing: 12) {
                    Text(guide.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    HStack {
                        // Kategori
                        Text(guide.category.title)
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.accentColor.opacity(0.2))
                            .foregroundStyle(Color.accentColor)
                            .clipShape(Capsule())
                        
                        Spacer()
                        
                        // Okuma süresi
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                            Text("\(guide.readTime) dk")
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)
                
                // Yazar bilgisi
                if let author = guide.author {
                    AuthorView(author: author)
                        .padding(.horizontal)
                }
                
                // İçerik
                Text(guide.content)
                    .font(.body)
                    .padding(.horizontal)
                
                // Etiketler
                if !guide.tags.isEmpty {
                    TagsView(tags: guide.tags)
                        .padding(.horizontal)
                }
                
                // Görseller
                if let images = guide.images {
                    ImagesGalleryView(images: images)
                }
                
                // Video
                if let videoUrl = guide.videoUrl {
                    VideoPlayerView(url: videoUrl)
                        .frame(height: 200)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: shareButton)
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [guide.title, guide.description])
        }
    }
    
    private var shareButton: some View {
        Button(action: {
            showShareSheet = true
        }) {
            Image(systemName: "square.and.arrow.up")
        }
    }
}

// MARK: - Supporting Views
struct AuthorView: View {
    let author: Author
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            if let avatarUrl = author.avatarUrl {
                AsyncImage(url: URL(string: avatarUrl)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .foregroundStyle(.gray)
                }
                .frame(width: 44, height: 44)
                .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 44, height: 44)
                    .foregroundStyle(.gray)
            }
            
            // Yazar bilgileri
            VStack(alignment: .leading, spacing: 4) {
                Text(author.name)
                    .font(.headline)
                
                Text(author.title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Sosyal medya bağlantıları
            if let socialMedia = author.socialMedia {
                ForEach(socialMedia, id: \.platform) { link in
                    Link(destination: URL(string: link.url)!) {
                        Image(systemName: link.platform.iconName)
                            .foregroundStyle(Color.accentColor)
                    }
                }
            }
        }
    }
}

struct TagsView: View {
    let tags: [String]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    Text("#\(tag)")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Capsule())
                }
            }
        }
    }
}

struct ImagesGalleryView: View {
    let images: [String]
    @State private var selectedImageIndex = 0
    
    var body: some View {
        TabView(selection: $selectedImageIndex) {
            ForEach(images.indices, id: \.self) { index in
                AsyncImage(url: URL(string: images[index])) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .frame(height: 200)
    }
}

struct VideoPlayerView: View {
    let url: String
    
    var body: some View {
        // TODO: Video oynatıcı implementasyonu
        Color.black
            .overlay(
                Image(systemName: "play.circle.fill")
                    .resizable()
                    .frame(width: 44, height: 44)
                    .foregroundStyle(.white)
            )
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview
struct GuideDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GuideDetailView(guide: Guide(
                id: "1",
                title: "Namaz Nasıl Kılınır?",
                description: "İslam'ın beş şartından biri olan namazın kılınışı hakkında detaylı rehber.",
                content: "Namazın kılınışı hakkında detaylı bilgiler...",
                category: .prayer,
                author: Author(
                    id: "1",
                    name: "Ahmet Yılmaz",
                    title: "Din Görevlisi",
                    bio: "20 yıllık din görevlisi",
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
            ))
        }
    }
} 