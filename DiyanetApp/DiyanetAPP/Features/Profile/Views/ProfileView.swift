import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showingPreferences = false
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if let user = viewModel.user {
                        // Profil başlığı
                        ProfileHeaderView(user: user)
                            .padding(.horizontal)
                        
                        // İstatistikler
                        StatisticsView(
                            bookmarkedCount: viewModel.bookmarkedGuides.count,
                            completedPrayersCount: viewModel.prayerHistory.filter(\.isCompleted).count
                        )
                        .padding(.horizontal)
                        
                        // Kaydedilen rehberler
                        if !viewModel.bookmarkedGuides.isEmpty {
                            BookmarkedGuidesView(guides: viewModel.bookmarkedGuides)
                                .padding(.horizontal)
                        }
                        
                        // Namaz geçmişi
                        if !viewModel.prayerHistory.isEmpty {
                            PrayerHistoryView(prayers: viewModel.prayerHistory)
                                .padding(.horizontal)
                        }
                        
                        // Ayarlar
                        SettingsView(
                            user: user,
                            onPreferencesChanged: viewModel.updateUserPreferences,
                            onSignOut: viewModel.signOut,
                            onDeleteAccount: { showingDeleteConfirmation = true }
                        )
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Profilim")
            .navigationBarTitleDisplayMode(.large)
            .overlay(loadingOverlay)
            .alert(item: Binding(
                get: { viewModel.error.map { ErrorWrapper(error: $0) } },
                set: { _ in viewModel.error = nil }
            )) { wrapper in
                Alert(
                    title: Text("Hata"),
                    message: Text(wrapper.error),
                    dismissButton: .default(Text("Tamam"))
                )
            }
            .alert(isPresented: $showingDeleteConfirmation) {
                Alert(
                    title: Text("Hesabı Sil"),
                    message: Text("Hesabınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz."),
                    primaryButton: .destructive(Text("Sil")) {
                        viewModel.deleteAccount()
                    },
                    secondaryButton: .cancel(Text("İptal"))
                )
            }
            .refreshable {
                viewModel.loadUserData()
            }
        }
    }
    
    @ViewBuilder
    private var loadingOverlay: some View {
        if viewModel.isLoading {
            ProgressView()
                .scaleEffect(1.5)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.2))
        }
    }
}

// MARK: - Supporting Views
struct ProfileHeaderView: View {
    let user: User
    
    var body: some View {
        VStack(spacing: 16) {
            // Avatar
            if let avatarUrl = user.avatarUrl {
                AsyncImage(url: URL(string: avatarUrl)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .foregroundStyle(.gray)
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundStyle(.gray)
            }
            
            // Kullanıcı bilgileri
            VStack(spacing: 4) {
                Text(user.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(user.email)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                if let location = user.location {
                    Text(location)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

struct StatisticsView: View {
    let bookmarkedCount: Int
    let completedPrayersCount: Int
    
    var body: some View {
        HStack(spacing: 20) {
            StatisticItem(
                title: "Kaydedilenler",
                value: "\(bookmarkedCount)",
                systemImage: "bookmark.fill"
            )
            
            StatisticItem(
                title: "Kılınan Namazlar",
                value: "\(completedPrayersCount)",
                systemImage: "checkmark.circle.fill"
            )
        }
    }
}

struct StatisticItem: View {
    let title: String
    let value: String
    let systemImage: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundStyle(.accentColor)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct BookmarkedGuidesView: View {
    let guides: [Guide]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Kaydedilen Rehberler")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(guides) { guide in
                        NavigationLink(destination: GuideDetailView(guide: guide)) {
                            BookmarkedGuideCard(guide: guide)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
}

struct BookmarkedGuideCard: View {
    let guide: Guide
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(guide.title)
                .font(.headline)
                .lineLimit(2)
            
            Text(guide.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(3)
            
            HStack {
                Text(guide.category.title)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.2))
                    .foregroundStyle(.accentColor)
                    .clipShape(Capsule())
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                    Text("\(guide.readTime) dk")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(width: 250)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct PrayerHistoryView: View {
    let prayers: [Prayer]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Namaz Geçmişi")
                .font(.headline)
            
            ForEach(prayers.prefix(5)) { prayer in
                PrayerHistoryItem(prayer: prayer)
            }
        }
    }
}

struct PrayerHistoryItem: View {
    let prayer: Prayer
    
    var body: some View {
        HStack {
            Image(systemName: prayer.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(prayer.isCompleted ? .green : .gray)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(prayer.type.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(prayer.time.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(prayer.location)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct SettingsView: View {
    let user: User
    let onPreferencesChanged: (UserPreferences) -> Void
    let onSignOut: () -> Void
    let onDeleteAccount: () -> Void
    @State private var preferences: UserPreferences
    
    init(user: User, onPreferencesChanged: @escaping (UserPreferences) -> Void, onSignOut: @escaping () -> Void, onDeleteAccount: @escaping () -> Void) {
        self.user = user
        self.onPreferencesChanged = onPreferencesChanged
        self.onSignOut = onSignOut
        self.onDeleteAccount = onDeleteAccount
        _preferences = State(initialValue: user.preferences)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Ayarlar")
                .font(.headline)
            
            VStack(spacing: 16) {
                Toggle("Bildirimler", isOn: $preferences.notificationsEnabled)
                    .onChange(of: preferences.notificationsEnabled) { _ in
                        onPreferencesChanged(preferences)
                    }
                
                Toggle("Namaz Hatırlatıcıları", isOn: $preferences.prayerRemindersEnabled)
                    .onChange(of: preferences.prayerRemindersEnabled) { _ in
                        onPreferencesChanged(preferences)
                    }
                
                Toggle("Karanlık Mod", isOn: $preferences.darkModeEnabled)
                    .onChange(of: preferences.darkModeEnabled) { _ in
                        onPreferencesChanged(preferences)
                    }
                
                Picker("Dil", selection: $preferences.language) {
                    Text("Türkçe").tag("tr")
                    Text("English").tag("en")
                    Text("العربية").tag("ar")
                }
                .onChange(of: preferences.language) { _ in
                    onPreferencesChanged(preferences)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
            
            VStack(spacing: 16) {
                Button(action: onSignOut) {
                    Text("Çıkış Yap")
                        .font(.headline)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 2)
                }
                
                Button(action: onDeleteAccount) {
                    Text("Hesabı Sil")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(12)
                        .shadow(radius: 2)
                }
            }
        }
    }
}

// MARK: - Preview
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

// MARK: - Helper Types
struct ErrorWrapper: Identifiable {
    let id = UUID()
    let error: String
} 