import Foundation
import Combine

class AuthenticationViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var error: String?
    
    private let networkManager = NetworkManager.shared
    
    init() {
        // Normalde burada Firebase veya başka bir kimlik doğrulama servisi kontrol edilir
        // Şimdilik otomatik olarak giriş yapmış varsayalım
        checkAuthenticationStatus()
    }
    
    func checkAuthenticationStatus() {
        // Şimdilik otomatik giriş
        self.isAuthenticated = true
        self.currentUser = User(
            id: "user1",
            name: "Demo Kullanıcı",
            email: "demo@example.com",
            location: Location(latitude: 41.0082, longitude: 28.9784, city: "İstanbul", country: "Türkiye"),
            avatarUrl: nil,
            preferences: UserPreferences(notifications: true, darkMode: false, language: "tr")
        )
    }
    
    func login(email: String, password: String) {
        isLoading = true
        error = nil
        
        // Kimlik doğrulama işlemi burada yapılır
        // Şimdilik başarılı bir giriş simüle edelim
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isLoading = false
            self.isAuthenticated = true
            self.currentUser = User(
                id: "user1",
                name: "Demo Kullanıcı",
                email: email,
                location: Location(latitude: 41.0082, longitude: 28.9784, city: "İstanbul", country: "Türkiye"),
                avatarUrl: nil,
                preferences: UserPreferences(notifications: true, darkMode: false, language: "tr")
            )
        }
    }
    
    func register(name: String, email: String, password: String) {
        isLoading = true
        error = nil
        
        // Kayıt işlemi burada yapılır
        // Şimdilik başarılı bir kayıt simüle edelim
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isLoading = false
            self.isAuthenticated = true
            self.currentUser = User(
                id: "user1",
                name: name,
                email: email,
                location: Location(latitude: 41.0082, longitude: 28.9784, city: "İstanbul", country: "Türkiye"),
                avatarUrl: nil,
                preferences: UserPreferences(notifications: true, darkMode: false, language: "tr")
            )
        }
    }
    
    func logout() {
        isLoading = true
        
        // Çıkış işlemi burada yapılır
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoading = false
            self.isAuthenticated = false
            self.currentUser = nil
        }
    }
    
    func resetPassword(email: String) {
        isLoading = true
        error = nil
        
        // Şifre sıfırlama işlemi burada yapılır
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
            // Başarılı bir şekilde e-posta gönderildi simülasyonu
        }
    }
    
    func updateProfile(name: String, email: String) {
        isLoading = true
        error = nil
        
        // Profil güncelleme işlemi burada yapılır
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
            if var user = self.currentUser {
                user.name = name
                user.email = email
                self.currentUser = user
            }
        }
    }
    
    func updatePreferences(preferences: UserPreferences) {
        isLoading = true
        
        // Tercihleri güncelleme işlemi burada yapılır
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoading = false
            if var user = self.currentUser {
                user.preferences = preferences
                self.currentUser = user
            }
        }
    }
}

// MARK: - Models
struct User: Identifiable {
    var id: String
    var name: String
    var email: String
    var location: Location
    var avatarUrl: String?
    var preferences: UserPreferences
}

struct UserPreferences {
    var notifications: Bool
    var darkMode: Bool
    var language: String
} 