import Foundation
import Combine

class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var bookmarkedGuides: [Guide] = []
    @Published var prayerHistory: [Prayer] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let networkManager = NetworkManager.shared
    private let authManager = AuthenticationManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadUserData()
    }
    
    // MARK: - Public Methods
    func loadUserData() {
        isLoading = true
        error = nil
        
        // TODO: API'den kullanıcı bilgilerini çek
        // Örnek veri
        let mockUser = User(
            id: "1",
            email: "ahmet@example.com",
            name: "Ahmet Yılmaz",
            avatarUrl: nil,
            location: "İstanbul",
            preferences: UserPreferences(
                notificationsEnabled: true,
                prayerRemindersEnabled: true,
                darkModeEnabled: false,
                language: "tr"
            )
        )
        
        let mockGuides = [
            Guide(
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
                isBookmarked: true
            )
        ]
        
        let mockPrayers = [
            Prayer(
                id: "1",
                type: .fajr,
                time: Date(),
                location: "İstanbul",
                isCompleted: true
            ),
            Prayer(
                id: "2",
                type: .dhuhr,
                time: Date().addingTimeInterval(3600),
                location: "İstanbul",
                isCompleted: false
            )
        ]
        
        DispatchQueue.main.async {
            self.user = mockUser
            self.bookmarkedGuides = mockGuides
            self.prayerHistory = mockPrayers
            self.isLoading = false
        }
    }
    
    func updateUserPreferences(preferences: UserPreferences) {
        guard var updatedUser = user else { return }
        updatedUser.preferences = preferences
        
        // TODO: API'ye güncellenen tercihleri gönder
        DispatchQueue.main.async {
            self.user = updatedUser
        }
    }
    
    func signOut() {
        authManager.signOut { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.user = nil
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            }
        }
    }
    
    func deleteAccount() {
        // TODO: API'den hesabı sil
        authManager.deleteAccount { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.user = nil
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            }
        }
    }
} 