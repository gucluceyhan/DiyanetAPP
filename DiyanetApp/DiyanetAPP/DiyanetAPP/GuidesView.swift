import SwiftUI

// MARK: - Models
enum GuideCategory: String, CaseIterable, Identifiable, Hashable {
    case worship = "ibadet"
    case education = "eğitim"
    case history = "tarih"
    case holiday = "bayram"
    case family = "aile"
    case PILGRIMAGE = "hac"
    case UMRAH = "umre"
    case JERUSALEM = "kudüs"
    
    var id: String { self.rawValue }
    
    var title: String {
        switch self {
        case .worship: return "İbadet"
        case .education: return "Eğitim"
        case .history: return "Tarih"
        case .holiday: return "Bayram"
        case .family: return "Aile"
        case .PILGRIMAGE: return "Hac"
        case .UMRAH: return "Umre"
        case .JERUSALEM: return "Kudüs"
        }
    }
    
    var iconName: String {
        switch self {
        case .worship: return "hands.sparkles"
        case .education: return "book"
        case .history: return "clock"
        case .holiday: return "gift"
        case .family: return "person.3"
        case .PILGRIMAGE: return "mappin.and.ellipse"
        case .UMRAH: return "building.columns"
        case .JERUSALEM: return "building.2"
        }
    }
}

struct Author: Identifiable {
    let id: String
    let name: String
    let title: String
    let avatarUrl: String?
}

struct GuideImage: Identifiable {
    let id: String
    let url: String
    let caption: String?
}

struct Guide: Identifiable {
    let id: String
    let title: String
    let description: String
    let content: String
    let category: GuideCategory
    let author: Author
    let tags: [String]
    let images: [GuideImage]
    let videoUrl: String?
    let readTime: Int
    let createdAt: Date
    let updatedAt: Date
    var isBookmarked: Bool
}

// MARK: - View Model
class GuidesViewModel: ObservableObject {
    @Published var guides: [Guide] = []
    @Published var featuredGuides: [Guide] = []
    @Published var categories: [GuideCategory] = GuideCategory.allCases
    @Published var selectedCategory: GuideCategory?
    @Published var searchText: String = ""
    @Published var showBookmarkedOnly: Bool = false
    @Published var isLoading: Bool = false
    @Published var error: String?
    
    // Özel rehberlerin yönetimi için değişkenler
    @Published var showSpecialGuideDetails = false
    @Published var selectedSpecialGuide: GuideCategory?
    
    var filteredGuides: [Guide] {
        var result = guides
        
        // Kategoriye göre filtrele
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        
        // Arama metnine göre filtrele
        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText) ||
                $0.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // Sadece favorileri göster
        if showBookmarkedOnly {
            result = result.filter { $0.isBookmarked }
        }
        
        return result
    }
    
    init() {
        fetchGuides()
    }
    
    func fetchGuides() {
        isLoading = true
        error = nil
        
        // API'dan rehberleri çekmek yerine şimdilik sahte veriler oluşturuyoruz
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.guides = self.generateSampleGuides()
            self.featuredGuides = Array(self.guides.prefix(2))
            self.isLoading = false
        }
    }
    
    func selectCategory(_ category: GuideCategory?) {
        self.selectedCategory = category
    }
    
    func toggleBookmark(for guide: Guide) {
        if let index = guides.firstIndex(where: { $0.id == guide.id }) {
            guides[index].isBookmarked.toggle()
        }
    }
    
    func showDetailView(for category: GuideCategory) {
        self.selectedSpecialGuide = category
        self.showSpecialGuideDetails = true
    }
    
    func resetSpecialGuideSelection() {
        self.selectedSpecialGuide = nil
        self.showSpecialGuideDetails = false
    }
    
    func isSpecialGuide(_ category: GuideCategory) -> Bool {
        return category == .PILGRIMAGE || category == .UMRAH || category == .JERUSALEM
    }
    
    private func generateSampleGuides() -> [Guide] {
        return [
            Guide(
                id: "1",
                title: "Namaz Nasıl Kılınır?",
                description: "Namazın kılınışı, şartları ve çeşitleri hakkında kapsamlı bir rehber.",
                content: "Namaz, İslam'ın beş şartından biridir ve her Müslümanın günde beş vakit yerine getirmesi gereken bir ibadettir. Bu rehber, namaz kılmayı adım adım anlatır ve tüm namazın şartları ve kuralları hakkında bilgi verir.",
                category: .worship,
                author: Author(
                    id: "author1",
                    name: "İmam Ahmet Yılmaz",
                    title: "Din İşleri Uzmanı",
                    avatarUrl: nil
                ),
                tags: ["namaz", "ibadet", "farz", "sünnet"],
                images: [
                    GuideImage(id: "img1", url: "namaz1", caption: "Namaz kılan bir kişi"),
                    GuideImage(id: "img2", url: "namaz2", caption: "Cami içinde namaz kılan cemaat")
                ],
                videoUrl: nil,
                readTime: 10,
                createdAt: Date().addingTimeInterval(-86400 * 30),
                updatedAt: Date().addingTimeInterval(-86400 * 5),
                isBookmarked: true
            ),
            Guide(
                id: "2",
                title: "Ramazan'a Nasıl Hazırlanmalı?",
                description: "Ramazan ayı öncesi ve sırasında yapılması gerekenler hakkında bilgiler.",
                content: "Ramazan, Müslümanlar için en kutsal aylardan biridir. Bu rehber, Ramazan ayı öncesinde ve sırasında yapılması gerekenleri, oruç tutmanın sağlık açısından faydalarını ve dikkat edilmesi gereken hususları açıklar.",
                category: .holiday,
                author: Author(
                    id: "author2",
                    name: "Dr. Mehmet Kartal",
                    title: "İlahiyat Profesörü",
                    avatarUrl: nil
                ),
                tags: ["ramazan", "oruç", "iftar", "sahur"],
                images: [
                    GuideImage(id: "img3", url: "ramazan1", caption: "İftar sofrası"),
                    GuideImage(id: "img4", url: "ramazan2", caption: "Teravih namazı")
                ],
                videoUrl: nil,
                readTime: 12,
                createdAt: Date().addingTimeInterval(-86400 * 20),
                updatedAt: Date().addingTimeInterval(-86400 * 2),
                isBookmarked: false
            ),
            Guide(
                id: "3",
                title: "Zekât Hesaplama Rehberi",
                description: "Zekât miktarını hesaplama ve kimlere verilmesi gerektiği hakkında bilgiler.",
                content: "Zekât, İslam'ın beş şartından biridir ve maddi durumu uygun olan her Müslümanın yılda bir kez vermesi gereken mali bir ibadettir. Bu rehber, zekât hesaplama yöntemlerini ve kimlere verilmesi gerektiğini açıklar.",
                category: .worship,
                author: Author(
                    id: "author3",
                    name: "Fatih Yıldız",
                    title: "Diyanet İşleri Uzmanı",
                    avatarUrl: nil
                ),
                tags: ["zekât", "sadaka", "mali ibadet"],
                images: [
                    GuideImage(id: "img5", url: "zekat1", caption: "Zekât verme")
                ],
                videoUrl: nil,
                readTime: 8,
                createdAt: Date().addingTimeInterval(-86400 * 15),
                updatedAt: Date().addingTimeInterval(-86400 * 1),
                isBookmarked: false
            ),
            Guide(
                id: "4",
                title: "Çocuklara Dini Eğitim",
                description: "Çocuklara dini bilgileri öğretmenin doğru yolları ve yöntemleri.",
                content: "Çocuklara dini eğitim vermek, ailelerin en önemli sorumluluklarından biridir. Bu rehber, çocuklara yaş gruplarına göre dini bilgileri nasıl öğretebileceğinize dair pratik bilgiler içerir.",
                category: .education,
                author: Author(
                    id: "author4",
                    name: "Prof. Dr. Zeynep Kaya",
                    title: "Eğitim Bilimleri Uzmanı",
                    avatarUrl: nil
                ),
                tags: ["çocuk eğitimi", "dini eğitim", "aile"],
                images: [
                    GuideImage(id: "img6", url: "cocuk_egitim1", caption: "Çocuklara Kuran öğretimi"),
                    GuideImage(id: "img7", url: "cocuk_egitim2", caption: "Aile içi dini sohbet")
                ],
                videoUrl: "https://example.com/videos/cocuk_egitim",
                readTime: 15,
                createdAt: Date().addingTimeInterval(-86400 * 10),
                updatedAt: Date().addingTimeInterval(-86400 * 3),
                isBookmarked: true
            )
        ]
    }
}

struct GuidesView: View {
    @StateObject private var viewModel = GuidesViewModel()
    @State private var searchText = ""
    @State private var showBookmarksOnly = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Ana İçerik
                VStack(spacing: 0) {
                    // Üst Arama Kısmı
                    VStack(spacing: 12) {
                        // Arama ve Filtre
                        HStack {
                            SearchBar(text: $searchText, placeholder: "Rehberlerde ara...")
                                .onChange(of: searchText) { newValue in
                                    viewModel.searchText = newValue
                                }
                            
                            Button(action: {
                                showBookmarksOnly.toggle()
                                viewModel.showBookmarkedOnly = showBookmarksOnly
                            }) {
                                Image(systemName: showBookmarksOnly ? "bookmark.fill" : "bookmark")
                                    .font(.system(size: 22))
                                    .foregroundStyle(showBookmarksOnly ? Color.accentColor : .primary)
                                    .frame(width: 44, height: 44)
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Kategori Seçici
                        CategoryPicker(selectedCategory: Binding(
                            get: { viewModel.selectedCategory },
                            set: { viewModel.selectCategory($0) }
                        ), categories: viewModel.categories)
                    }
                    .padding(.top)
                    .background(Color(.systemBackground))
                    
                    ScrollView {
                        // Özel Rehberler Bölümü
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Özel Rehberler")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                                .padding(.top)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    SpecialGuideCard(
                                        title: "Hac Rehberi",
                                        description: "Hac ibadeti için kapsamlı rehber",
                                        imageName: "hajj_guide",
                                        iconName: "mappin.and.ellipse",
                                        category: .PILGRIMAGE
                                    )
                                    .onTapGesture {
                                        viewModel.showDetailView(for: .PILGRIMAGE)
                                    }
                                    
                                    SpecialGuideCard(
                                        title: "Umre Rehberi",
                                        description: "Umre ziyareti için detaylı bilgiler",
                                        imageName: "umrah_guide",
                                        iconName: "building.columns",
                                        category: .UMRAH
                                    )
                                    .onTapGesture {
                                        viewModel.showDetailView(for: .UMRAH)
                                    }
                                    
                                    SpecialGuideCard(
                                        title: "Kudüs Rehberi",
                                        description: "Mescid-i Aksa ve Kudüs ziyareti",
                                        imageName: "jerusalem_guide",
                                        iconName: "building.2",
                                        category: .JERUSALEM
                                    )
                                    .onTapGesture {
                                        viewModel.showDetailView(for: .JERUSALEM)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Diğer Rehberler
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Tüm Rehberler")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                                .padding(.top)
                            
                            if viewModel.filteredGuides.isEmpty {
                                VStack(spacing: 20) {
                                    Image(systemName: "doc.text.magnifyingglass")
                                        .font(.system(size: 50))
                                        .foregroundStyle(.gray)
                                    
                                    Text("Hiç rehber bulunamadı")
                                        .font(.headline)
                                        .foregroundStyle(.secondary)
                                    
                                    Button("Filtreleri temizle") {
                                        searchText = ""
                                        viewModel.searchText = ""
                                        viewModel.selectCategory(nil)
                                        showBookmarksOnly = false
                                        viewModel.showBookmarkedOnly = false
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(Color.accentColor)
                                    .foregroundStyle(.white)
                                    .cornerRadius(8)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(12)
                                .padding(.horizontal)
                            } else {
                                // Rehber Listesi
                                VStack(spacing: 15) {
                                    ForEach(viewModel.filteredGuides) { guide in
                                        NavigationLink {
                                            if viewModel.isSpecialGuide(guide.category) {
                                                switch guide.category {
                                                case .PILGRIMAGE:
                                                    HajjGuideView()
                                                case .UMRAH:
                                                    UmrahGuideView()
                                                case .JERUSALEM:
                                                    JerusalemGuideView()
                                                default:
                                                    GuideDetailView(guide: guide)
                                                }
                                            } else {
                                                GuideDetailView(guide: guide)
                                            }
                                        } label: {
                                            GuideCard(guide: guide) {
                                                viewModel.toggleBookmark(for: guide)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.bottom, 80)
                    }
                }
                
                // Yükleniyor veya Hata Gösterimi
                if viewModel.isLoading {
                    LoadingOverlay()
                }
            }
            .navigationTitle("Dini Rehberler")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if viewModel.guides.isEmpty {
                    viewModel.fetchGuides()
                }
            }
            .sheet(isPresented: $viewModel.showSpecialGuideDetails) {
                if let category = viewModel.selectedSpecialGuide {
                    Group {
                        switch category {
                        case .PILGRIMAGE:
                            HajjGuideView()
                        case .UMRAH:
                            UmrahGuideView()
                        case .JERUSALEM:
                            JerusalemGuideView()
                        default:
                            EmptyView()
                        }
                    }
                    .onDisappear {
                        viewModel.resetSpecialGuideSelection()
                    }
                }
            }
        }
    }
}

// MARK: - Yardımcı Görünümler

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.gray)
                .padding(.leading, 8)
            
            TextField(placeholder, text: $text)
                .padding(.vertical, 10)
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.gray)
                        .padding(.trailing, 8)
                }
            }
        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct CategoryPicker: View {
    @Binding var selectedCategory: GuideCategory?
    let categories: [GuideCategory]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CategoryButton(
                    title: "Tümü",
                    isSelected: selectedCategory == nil,
                    action: { selectedCategory = nil }
                )
                
                ForEach(categories, id: \.self) { category in
                    CategoryButton(
                        title: category.title,
                        isSelected: selectedCategory == category,
                        action: { selectedCategory = category }
                    )
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
        }
    }
}

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color(.secondarySystemBackground))
                .foregroundStyle(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct GuideCard: View {
    let guide: Guide
    let bookmarkAction: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            // Rehber Görseli
            Image(guide.images.first?.url ?? "placeholder_guide")
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            // Rehber Bilgisi
            VStack(alignment: .leading, spacing: 5) {
                Text(guide.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(guide.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "person")
                            .font(.caption)
                        Text(guide.author.name)
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                        Text("\(guide.readTime) dk")
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Kategori ve Yer İmi
            VStack(spacing: 15) {
                HStack {
                    Image(systemName: guide.category.iconName)
                        .font(.caption)
                    Text(guide.category.title)
                        .font(.caption)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.accentColor.opacity(0.1))
                .cornerRadius(8)
                
                Button(action: bookmarkAction) {
                    Image(systemName: guide.isBookmarked ? "bookmark.fill" : "bookmark")
                        .foregroundStyle(guide.isBookmarked ? Color.accentColor : .gray)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct SpecialGuideCard: View {
    let title: String
    let description: String
    let imageName: String
    let iconName: String
    let category: GuideCategory
    
    var body: some View {
        VStack(alignment: .leading) {
            // Resim
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 120)
                .clipped()
                .cornerRadius(12, corners: [.topLeft, .topRight])
            
            // İçerik
            VStack(alignment: .leading, spacing: 8) {
                // Kategori Etiketi
                HStack {
                    Image(systemName: iconName)
                        .font(.caption)
                    Text(category.title)
                        .font(.caption)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.accentColor.opacity(0.1))
                .cornerRadius(8)
                
                // Başlık
                Text(title)
                    .font(.headline)
                    .lineLimit(1)
                
                // Açıklama
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                
                // Görüntüle Butonu
                Button(action: {}) {
                    Text("Görüntüle")
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .cornerRadius(8)
                }
                .padding(.top, 4)
            }
            .padding(12)
        }
        .frame(width: 200)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 15) {
                ProgressView()
                    .scaleEffect(1.5)
                
                Text("Yükleniyor...")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            .padding(25)
            .background(BlurView(style: .systemThinMaterialDark))
            .cornerRadius(15)
        }
    }
}

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct HajjGuideView: View {
    // Hac Rehberi içeriği buraya gelecek
    var body: some View {
        Text("Hac Rehberi")
    }
}

struct UmrahGuideView: View {
    // Umre Rehberi içeriği buraya gelecek
    var body: some View {
        Text("Umre Rehberi")
    }
}

struct JerusalemGuideView: View {
    // Kudüs Rehberi içeriği buraya gelecek
    var body: some View {
        Text("Kudüs Rehberi")
    }
}

struct GuideDetailView: View {
    let guide: Guide
    
    var body: some View {
        Text("Rehber Detayları: \(guide.title)")
    }
}

// MARK: - Preview
struct GuidesView_Previews: PreviewProvider {
    static var previews: some View {
        GuidesView()
    }
} 