import Foundation

final class AuthenticationManager {
    static let shared = AuthenticationManager()
    
    private init() {}
    
    // MARK: - Properties
    private var currentUser: User?
    private let userDefaults = UserDefaults.standard
    private let tokenKey = "auth_token"
    
    // MARK: - Public Methods
    func login(username: String, password: String, completion: @escaping (Result<User, AuthError>) -> Void) {
        // TODO: Implement e-Devlet login
        // This is a placeholder for e-Devlet integration
    }
    
    func logout() {
        currentUser = nil
        userDefaults.removeObject(forKey: tokenKey)
    }
    
    func isLoggedIn() -> Bool {
        return userDefaults.string(forKey: tokenKey) != nil
    }
    
    func getCurrentUser() -> User? {
        return currentUser
    }
    
    // MARK: - Token Management
    private func saveToken(_ token: String) {
        userDefaults.set(token, forKey: tokenKey)
    }
    
    private func getToken() -> String? {
        return userDefaults.string(forKey: tokenKey)
    }
}

// MARK: - Models
struct User: Codable {
    let id: String
    let username: String
    let email: String
    let fullName: String
}

enum AuthError: Error {
    case invalidCredentials
    case networkError
    case serverError
    case unknown
} 