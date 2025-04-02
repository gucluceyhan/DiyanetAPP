import Foundation
import SwiftUI
import Combine

class GuidesViewModel: ObservableObject {
    @Published var guides: [Guide] = []
    @Published var featuredGuides: [Guide] = []
    @Published var categories: [GuideCategory] = GuideCategory.allCases
    @Published var selectedCategory: GuideCategory? = nil
    @Published var searchText: String = ""
    @Published var filteredGuides: [Guide] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var showBookmarkedOnly: Bool = false
    @Published var showSpecialGuideDetails: Bool = false
    @Published var selectedSpecialGuide: GuideCategory? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        addSubscribers()
    }
    
    func addSubscribers() {
        // Fil treGuides whenever guides, selectedCategory, searchText or showBookmarkedOnly changes
        $guides
            .combineLatest($selectedCategory, $searchText, $showBookmarkedOnly)
            .map(filterGuides)
            .assign(to: \.filteredGuides, on: self)
            .store(in: &cancellables)
    }
    
    func fetchGuides() {
        isLoading = true
        errorMessage = nil
        
        // Simulating network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.loadMockData()
            self.isLoading = false
        }
    }
    
    private func loadMockData() {
        // Create some mock guides
        let guide1 = Guide(
            id: UUID().uuidString,
            title: "Ramazan Ayının Önemi ve Faziletleri",
            description: "Ramazan ayının İslam'daki yeri ve önemi hakkında kapsamlı bir rehber.",
            content: "Ramazan ayı, Kur'an-ı Kerim'in indirildiği ve oruç ibadeti ile mükellef olduğumuz mübarek bir aydır...",
            category: .FASTING,
            author: Author(name: "Diyanet İşleri Başkanlığı", imageUrl: "author_diyanet"),
            tags: ["Ramazan", "Oruç", "İbadet"],
            images: [
                GuideImage(url: "ramazan_1", caption: "Ramazan ayı"),
                GuideImage(url: "ramazan_2", caption: "İftar vakti")
            ],
            videoUrl: "https://example.com/ramazan_video",
            readTime: 15,
            createdAt: Date().addingTimeInterval(-86400 * 30), // 30 days ago
            updatedAt: Date().addingTimeInterval(-86400 * 5),  // 5 days ago
            isBookmarked: true
        )
        
        let guide2 = Guide(
            id: UUID().uuidString,
            title: "Namaz Kılmanın Adabı",
            description: "İslam'da namazın önemi ve doğru namaz kılma rehberi.",
            content: "Namaz, İslam'ın beş şartından biridir ve günde beş vakit kılınması farzdır...",
            category: .PRAYER,
            author: Author(name: "Diyanet İşleri Başkanlığı", imageUrl: "author_diyanet"),
            tags: ["Namaz", "İbadet", "Dua"],
            images: [
                GuideImage(url: "namaz_1", caption: "Namaz kılarken"),
                GuideImage(url: "namaz_2", caption: "Camide cemaat")
            ],
            videoUrl: "https://example.com/namaz_video",
            readTime: 10,
            createdAt: Date().addingTimeInterval(-86400 * 60), // 60 days ago
            updatedAt: Date().addingTimeInterval(-86400 * 10), // 10 days ago
            isBookmarked: false
        )
        
        let guide3 = Guide(
            id: UUID().uuidString,
            title: "Zekat ve Sadakanın Önemi",
            description: "İslam'da zekat ibadeti ve sadaka vermenin faziletleri.",
            content: "Zekat, mali bir ibadettir ve belirli bir nisaba ulaşan Müslümanların mallarının bir kısmını ihtiyaç sahiplerine vermeleridir...",
            category: .ZAKAT,
            author: Author(name: "Diyanet İşleri Başkanlığı", imageUrl: "author_diyanet"),
            tags: ["Zekat", "Sadaka", "Yardımlaşma"],
            images: [
                GuideImage(url: "zekat_1", caption: "Zekat vermek"),
                GuideImage(url: "zekat_2", caption: "Yardımlaşma")
            ],
            videoUrl: "https://example.com/zekat_video",
            readTime: 8,
            createdAt: Date().addingTimeInterval(-86400 * 45), // 45 days ago
            updatedAt: Date().addingTimeInterval(-86400 * 15), // 15 days ago
            isBookmarked: true
        )
        
        let guide4 = Guide(
            id: UUID().uuidString,
            title: "Hac İbadetinin Esasları",
            description: "Hac ve umre ibadetleri ile ilgili temel bilgiler ve uygulamalar.",
            content: "Hac, İslam'ın beş şartından biridir ve imkanı olan her Müslümanın ömründe bir kez yerine getirmesi gereken bir ibadettir...",
            category: .PILGRIMAGE,
            author: Author(name: "Diyanet İşleri Başkanlığı", imageUrl: "author_diyanet"),
            tags: ["Hac", "Umre", "Mekke", "Medine"],
            images: [
                GuideImage(url: "hac_1", caption: "Kabe"),
                GuideImage(url: "hac_2", caption: "Arafat vakfesi")
            ],
            videoUrl: "https://example.com/hac_video",
            readTime: 20,
            createdAt: Date().addingTimeInterval(-86400 * 20), // 20 days ago
            updatedAt: Date().addingTimeInterval(-86400 * 2),  // 2 days ago
            isBookmarked: false
        )
        
        let guide5 = Guide(
            id: UUID().uuidString,
            title: "Kudüs Rehberi",
            description: "Kudüs'ün İslam'daki yeri ve önemi, ziyaret rehberi.",
            content: "Kudüs, İslam'da üçüncü kutsal şehirdir ve Mescid-i Aksa'nın bulunduğu yerdir...",
            category: .JERUSALEM,
            author: Author(name: "Diyanet İşleri Başkanlığı", imageUrl: "author_diyanet"),
            tags: ["Kudüs", "Mescid-i Aksa", "Filistin"],
            images: [
                GuideImage(url: "kudus_1", caption: "Mescid-i Aksa"),
                GuideImage(url: "kudus_2", caption: "Kubbet-üs Sahra")
            ],
            videoUrl: "https://example.com/kudus_video",
            readTime: 18,
            createdAt: Date().addingTimeInterval(-86400 * 25), // 25 days ago
            updatedAt: Date().addingTimeInterval(-86400 * 3),  // 3 days ago
            isBookmarked: true
        )
        
        let guide6 = Guide(
            id: UUID().uuidString,
            title: "Umre Rehberi",
            description: "Umre ziyareti için kapsamlı rehber ve uygulamalar.",
            content: "Umre, hac mevsimi dışında yapılan, Kabe'yi tavaf ve Safa ile Merve arasında sa'y yapma ibadetidir...",
            category: .UMRAH,
            author: Author(name: "Diyanet İşleri Başkanlığı", imageUrl: "author_diyanet"),
            tags: ["Umre", "Mekke", "İbadet"],
            images: [
                GuideImage(url: "umre_1", caption: "Kabe tavafı"),
                GuideImage(url: "umre_2", caption: "Sa'y ibadeti")
            ],
            videoUrl: "https://example.com/umre_video",
            readTime: 15,
            createdAt: Date().addingTimeInterval(-86400 * 35), // 35 days ago
            updatedAt: Date().addingTimeInterval(-86400 * 7),  // 7 days ago
            isBookmarked: false
        )
        
        guides = [guide1, guide2, guide3, guide4, guide5, guide6]
        featuredGuides = [guide4, guide5, guide6] // Hac, Kudüs ve Umre rehberlerini öne çıkaralım
    }
    
    func filterGuides(guides: [Guide], category: GuideCategory?, searchText: String, showBookmarkedOnly: Bool) -> [Guide] {
        var filteredGuides = guides
        
        // Filter by category if selected
        if let category = category {
            filteredGuides = filteredGuides.filter { $0.category == category }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            filteredGuides = filteredGuides.filter {
                $0.title.lowercased().contains(searchText.lowercased()) ||
                $0.description.lowercased().contains(searchText.lowercased()) ||
                $0.tags.contains(where: { $0.lowercased().contains(searchText.lowercased()) })
            }
        }
        
        // Filter for bookmarked guides only
        if showBookmarkedOnly {
            filteredGuides = filteredGuides.filter { $0.isBookmarked }
        }
        
        // Sort by date (newest first)
        filteredGuides.sort(by: { $0.updatedAt > $1.updatedAt })
        
        return filteredGuides
    }
    
    func selectCategory(_ category: GuideCategory?) {
        self.selectedCategory = category
    }
    
    func toggleBookmark(for guide: Guide) {
        if let index = guides.firstIndex(where: { $0.id == guide.id }) {
            guides[index].isBookmarked.toggle()
        }
    }
    
    func isSpecialGuide(_ category: GuideCategory) -> Bool {
        return category == .PILGRIMAGE || category == .UMRAH || category == .JERUSALEM
    }
    
    func showDetailView(for category: GuideCategory) {
        self.selectedSpecialGuide = category
        self.showSpecialGuideDetails = true
    }
    
    func resetSpecialGuideSelection() {
        self.selectedSpecialGuide = nil
        self.showSpecialGuideDetails = false
    }
} 