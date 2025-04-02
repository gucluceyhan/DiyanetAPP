import SwiftUI

struct GuidesView: View {
    @StateObject private var viewModel = GuidesViewModel()
    @State private var showBookmarksOnly = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Arama çubuğu
                SearchBar(text: $viewModel.searchText)
                    .padding()
                
                // Kategori seçici
                CategoryPicker(
                    categories: viewModel.categories,
                    selectedCategory: Binding(
                        get: { viewModel.selectedCategory },
                        set: { viewModel.selectCategory($0) }
                    )
                )
                .padding(.horizontal)
                
                // Rehber listesi
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(showBookmarksOnly ? viewModel.filteredGuides.filter(\.isBookmarked) : viewModel.filteredGuides) { guide in
                            NavigationLink(destination: GuideDetailView(guide: guide)) {
                                GuideCard(guide: guide, onBookmarkTap: {
                                    viewModel.toggleBookmark(guide)
                                })
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Rehberler")
            .navigationBarItems(trailing: bookmarkFilterButton)
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
            .refreshable {
                await viewModel.fetchGuides()
            }
        }
    }
    
    private var bookmarkFilterButton: some View {
        Button(action: {
            showBookmarksOnly.toggle()
        }) {
            Image(systemName: showBookmarksOnly ? "bookmark.fill" : "bookmark")
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
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.gray)
            
            TextField("Rehberlerde ara...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.gray)
                }
            }
        }
    }
}

struct CategoryPicker: View {
    let categories: [GuideCategory]
    @Binding var selectedCategory: GuideCategory?
    
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
            .padding(.vertical, 8)
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
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color.gray.opacity(0.2))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

struct GuideCard: View {
    let guide: Guide
    let onBookmarkTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Başlık ve yer imi
            HStack {
                Text(guide.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Spacer()
                
                Button(action: onBookmarkTap) {
                    Image(systemName: guide.isBookmarked ? "bookmark.fill" : "bookmark")
                        .foregroundStyle(.accentColor)
                }
            }
            
            // Açıklama
            Text(guide.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)
            
            // Alt bilgiler
            HStack {
                // Kategori
                Text(guide.category.title)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(Capsule())
                
                Spacer()
                
                // Okuma süresi
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                    Text("\(guide.readTime) dk")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// MARK: - Preview
struct GuidesView_Previews: PreviewProvider {
    static var previews: some View {
        GuidesView()
    }
}

// MARK: - Helper Types
struct ErrorWrapper: Identifiable {
    let id = UUID()
    let error: String
} 