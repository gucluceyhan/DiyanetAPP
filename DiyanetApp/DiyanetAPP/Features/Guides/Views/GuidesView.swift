import SwiftUI

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
                                    .foregroundStyle(showBookmarksOnly ? .accentColor : .primary)
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
                .font(.subheadline)
                .fontWeight(isSelected ? .bold : .regular)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.accentColor : Color(.secondarySystemBackground))
                )
                .foregroundStyle(isSelected ? .white : .primary)
        }
    }
}

struct GuideCard: View {
    let guide: Guide
    let bookmarkAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Kategori ve Yer İmi
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: guide.category.iconName)
                        .font(.caption)
                    
                    Text(guide.category.title)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(20)
                
                Spacer()
                
                Button(action: bookmarkAction) {
                    Image(systemName: guide.isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 20))
                        .foregroundStyle(guide.isBookmarked ? .accentColor : .primary)
                }
            }
            
            // Başlık
            Text(guide.title)
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(2)
            
            // Açıklama
            Text(guide.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            
            // Alt Bilgiler
            HStack {
                // Etiketler
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(guide.tags, id: \.self) { tag in
                            Text("#\(tag)")
                    .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                // Okuma Süresi
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption2)
                    
                    Text("\(guide.readTime) dk")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct SpecialGuideCard: View {
    let title: String
    let description: String
    let imageName: String
    let iconName: String
    let category: GuideCategory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .topLeading) {
                // Resim
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 150)
                    .clipped()
                    .cornerRadius(12)
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.black.opacity(0.5), Color.clear]),
                            startPoint: .bottom,
                            endPoint: .top
                        )
                        .cornerRadius(12)
                    )
                
                // İkon ve kategori
                HStack(spacing: 6) {
                    Image(systemName: iconName)
                        .font(.caption)
                    
                    Text(category.title)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.white.opacity(0.8))
                .cornerRadius(20)
                .padding(10)
            }
            
            // İçerik
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                
                Button(action: {}) {
                    Text("Detaylı Göster")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.accentColor)
                }
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 10)
        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .frame(width: 240)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                
                Text("Yükleniyor...")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            .padding(30)
            .background(Color(.systemBackground).opacity(0.8))
            .cornerRadius(15)
        }
    }
}

// MARK: - Preview
struct GuidesView_Previews: PreviewProvider {
    static var previews: some View {
        GuidesView()
    }
} 