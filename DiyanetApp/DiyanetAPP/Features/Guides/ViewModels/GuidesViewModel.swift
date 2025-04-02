import Foundation
import Combine

class GuidesViewModel: ObservableObject {
    @Published var guides: [Guide] = []
    @Published var featuredGuides: [Guide] = []
    @Published var categories: [GuideCategory] = GuideCategory.allCases
    @Published var selectedCategory: GuideCategory?
    @Published var searchText = ""
    @Published var filteredGuides: [Guide] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let networkManager = NetworkManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSearchSubscription()
        fetchGuides()
    }
    
    // MARK: - Public Methods
    func fetchGuides() {
        isLoading = true
        error = nil
        
        // TODO: API'den rehberleri çek
        // Örnek veri
        let mockGuides = [
            Guide(
                id: "1",
                title: "Namaz Nasıl Kılınır?",
                description: "İslam'ın beş şartından biri olan namazın kılınışı hakkında detaylı rehber.",
                content: """
                    Namazın kılınışı şu adımlardan oluşur:
                    
                    1. Niyet
                    2. İftitah Tekbiri (Allahu Ekber)
                    3. Kıyam (Ayakta Durma)
                    4. Kıraat (Kuran Okuma)
                    5. Rükû
                    6. Secde
                    7. Ka'de (Oturuş)
                    8. Selam
                    
                    Her bir adımın detaylı açıklaması aşağıdadır...
                    """,
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
            ),
            Guide(
                id: "2",
                title: "Ramazan Orucu Rehberi",
                description: "Ramazan ayında oruç tutmanın önemi, faydaları ve dikkat edilmesi gerekenler.",
                content: """
                    Ramazan orucu, İslam'ın beş şartından biridir.
                    
                    Oruç Tutmanın Şartları:
                    1. Müslüman olmak
                    2. Akıllı olmak
                    3. Ergenlik çağına ulaşmış olmak
                    4. Sağlıklı olmak
                    5. Mukim olmak (yolcu olmamak)
                    
                    Orucu Bozan Durumlar:
                    1. Bilerek yemek veya içmek
                    2. Cinsel ilişki
                    3. Kasıtlı olarak kusmak
                    
                    Detaylı bilgiler...
                    """,
                category: .fasting,
                author: Author(
                    id: "2",
                    name: "Mehmet Demir",
                    title: "İlahiyat Profesörü",
                    bio: "İstanbul Üniversitesi İlahiyat Fakültesi Öğretim Üyesi",
                    avatarUrl: nil,
                    socialMedia: nil
                ),
                tags: ["ramazan", "oruç", "ibadet"],
                images: nil,
                videoUrl: nil,
                readTime: 15,
                createdAt: Date(),
                updatedAt: Date(),
                isBookmarked: true
            )
        ]
        
        DispatchQueue.main.async {
            self.guides = mockGuides
            self.featuredGuides = mockGuides.filter { $0.category == .prayer }
            self.filterGuides()
            self.isLoading = false
        }
    }
    
    func selectCategory(_ category: GuideCategory?) {
        selectedCategory = category
        filterGuides()
    }
    
    func toggleBookmark(_ guide: Guide) {
        // TODO: API'ye kaydet
        if let index = guides.firstIndex(where: { $0.id == guide.id }) {
            guides[index].isBookmarked.toggle()
            filterGuides()
        }
    }
    
    // MARK: - Private Methods
    private func setupSearchSubscription() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.filterGuides()
            }
            .store(in: &cancellables)
    }
    
    private func filterGuides() {
        var filtered = guides
        
        // Kategori filtresi
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Arama filtresi
        if !searchText.isEmpty {
            filtered = filtered.filter { guide in
                guide.title.localizedCaseInsensitiveContains(searchText) ||
                guide.description.localizedCaseInsensitiveContains(searchText) ||
                guide.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        filteredGuides = filtered
    }
} 