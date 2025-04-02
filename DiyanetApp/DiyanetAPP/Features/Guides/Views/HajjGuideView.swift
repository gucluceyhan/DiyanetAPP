import SwiftUI
import Foundation

struct HajjGuideView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedSection: HajjSection = .overview
    @State private var showingMapView = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Başlık
                HStack {
                    Text("Hac Rehberi")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Image(systemName: "building.columns.fill")
                        .font(.title)
                        .foregroundStyle(Color.accentColor)
                }
                .padding(.horizontal)
                
                // Bölüm seçici
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(HajjSection.allCases, id: \.self) { section in
                            Button(action: {
                                selectedSection = section
                            }) {
                                Text(section.title)
                                    .font(.system(.subheadline, design: .rounded))
                                    .fontWeight(selectedSection == section ? .bold : .regular)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(
                                        Capsule()
                                            .fill(selectedSection == section ? Color.accentColor : Color.gray.opacity(0.2))
                                    )
                                    .foregroundStyle(selectedSection == section ? .white : .primary)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Seçilen bölümün içeriği
                VStack(alignment: .leading, spacing: 16) {
                    switch selectedSection {
                    case .overview:
                        overviewSection
                    case .preparation:
                        preparationSection
                    case .rituals:
                        ritualsSection
                    case .locations:
                        locationsSection
                    case .prayers:
                        prayersSection
                    case .faq:
                        faqSection
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingMapView = true
                }) {
                    Image(systemName: "map.fill")
                }
            }
        }
        .sheet(isPresented: $showingMapView) {
            HajjMapView()
        }
    }
    
    // MARK: - Content Sections
    
    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Hac Nedir?")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Hac, İslam'ın beş şartından biridir ve her yıl Zilhicce ayının 8 ve 13. günleri arasında Mekke'de yapılan bir ibadettir. Hac, gücü yeten ve imkanı olan her Müslüman'a ömründe bir kere farzdır.")
                .font(.body)
            
            Divider()
            
            Text("Haccın Önemi")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("Hac, Müslümanların topluca ibadet ettiği, birlik ve beraberliğin güçlendiği, kardeşliğin pekiştiği bir ibadettir. Hz. İbrahim ve Hz. İsmail zamanından beri yapılan bu ibadet, dünyada bütün Müslümanların aynı anda, aynı kıyafetle, aynı dualarla Allah'a yöneldiği eşsiz bir manevi atmosfer oluşturur.")
                .font(.body)
            
            Divider()
            
            Text("Hac İbadetinin Türleri")
                .font(.title3)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("• İfrad Haccı: Sadece hac ibadeti yapılır.")
                Text("• Temettu Haccı: Önce umre, sonra hac yapılır.")
                Text("• Kıran Haccı: Umre ve hac tek ihramla yapılır.")
            }
            .font(.body)
            
            Image("hajj_overview")
                .resizable()
                .scaledToFit()
                .cornerRadius(8)
        }
    }
    
    private var preparationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Hazırlık")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Hac ibadeti için fiziksel, manevi ve idari hazırlıkların yapılması gerekir.")
                .font(.body)
            
            VStack(alignment: .leading, spacing: 12) {
                preparationItem(title: "İdari Hazırlıklar", icon: "doc.text.fill") {
                    Text("• Diyanet İşleri Başkanlığı'nın açıkladığı tarihlerde hac başvurusu yapılmalıdır.")
                    Text("• Pasaport, vize ve diğer seyahat belgeleri hazırlanmalıdır.")
                    Text("• Sağlık kontrolleri ve aşılar yaptırılmalıdır.")
                    Text("• Hac eğitimlerine katılım sağlanmalıdır.")
                }
                
                preparationItem(title: "Manevi Hazırlık", icon: "heart.fill") {
                    Text("• Günahlardan tövbe edilmelidir.")
                    Text("• Kul haklarının iadesi yapılmalıdır.")
                    Text("• Hac ve umre duaları öğrenilmelidir.")
                    Text("• İbadetler düzenli şekilde yerine getirilmelidir.")
                }
                
                preparationItem(title: "Yanınızda Götürecekleriniz", icon: "bag.fill") {
                    Text("• İhram (erkekler için)")
                    Text("• Uygun kıyafetler")
                    Text("• Sağlık malzemeleri")
                    Text("• Dua kitapları")
                    Text("• Kişisel bakım ürünleri")
                    Text("• Rahat ayakkabılar")
                }
            }
            
            Divider()
            
            Text("Önemli İletişim Bilgileri")
                .font(.title3)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("• Diyanet İşleri Başkanlığı Hac ve Umre Hizmetleri Genel Müdürlüğü")
                Text("• Türkiye'nin Suudi Arabistan Büyükelçiliği")
                Text("• Cidde ve Mekke'deki Türk Konsoloslukları")
                Text("• Hac organizasyonu yetkilileri")
            }
            .font(.caption)
        }
    }
    
    private var ritualsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Hac İbadetinin Rükünleri")
                .font(.title2)
                .fontWeight(.bold)
            
            ritualStep(number: 1, title: "İhrama Girmek", description: "Mikat sınırlarını geçmeden önce ihrama girilir, telbiye getirilir ve niyet edilir.")
            
            ritualStep(number: 2, title: "Arafat Vakfesi", description: "Zilhicce'nin 9. günü öğle ile akşam arasında Arafat'ta bulunulur.")
            
            ritualStep(number: 3, title: "Tavaf", description: "Kâbe'nin etrafında yedi kez dönülür. Farz olan tavaf, ziyaret tavafıdır.")
            
            ritualStep(number: 4, title: "Sa'y", description: "Safa ve Merve tepeleri arasında dört gidiş üç geliş olmak üzere yedi kez gidilip gelinir.")
            
            Divider()
            
            Text("Hac Günleri Plan")
                .font(.title3)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 12) {
                dayPlan(day: "Terviye Günü (8 Zilhicce)", content: "Mekke'den Mina'ya gidilir, geceyi burada geçirmek sünnettir.")
                
                dayPlan(day: "Arefe Günü (9 Zilhicce)", content: "Sabah Mina'dan Arafat'a gidilir. Vakfe yapılır. Akşam Müzdelife'ye gidilir ve geceyi burada geçirilir.")
                
                dayPlan(day: "Bayram Günü (10 Zilhicce)", content: "Müzdelife'den Mina'ya gidilir, şeytan taşlanır, kurban kesilir, tıraş olunur, ziyaret tavafı yapılır.")
                
                dayPlan(day: "Teşrik Günleri (11-12-13 Zilhicce)", content: "Her gün şeytan taşlanır, 12 Zilhicce akşamına kadar Mina'da kalınması vaciptir.")
                
                dayPlan(day: "Veda Tavafı", content: "Mekke'den ayrılmadan önce yapılması vacip olan veda tavafı yapılır.")
            }
        }
    }
    
    private var locationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Önemli Mekanlar")
                .font(.title2)
                .fontWeight(.bold)
            
            locationCard(
                name: "Kâbe",
                description: "İslam'ın en kutsal mekânı, Müslümanların kıblesi. Tavaf ibadetinin yapıldığı yerdir.",
                coordinates: (21.4225, 39.8262)
            )
            
            locationCard(
                name: "Arafat",
                description: "Hac ibadetinin en önemli rüknü olan vakfenin yapıldığı yer. Arefe günü burada vakfe yapılır.",
                coordinates: (21.3549, 39.9841)
            )
            
            locationCard(
                name: "Müzdelife",
                description: "Arafat'tan sonra geceyi geçirilen yer. Buradan şeytan taşlamak için taşlar toplanır.",
                coordinates: (21.3764, 39.9375)
            )
            
            locationCard(
                name: "Mina",
                description: "Şeytan taşlama ibadetinin yapıldığı ve teşrik günlerinde kalınan yer.",
                coordinates: (21.4133, 39.8933)
            )
            
            locationCard(
                name: "Mescid-i Nebevi",
                description: "Medine'de bulunan, Hz. Muhammed'in kabri ve mescidi.",
                coordinates: (24.4672, 39.6111)
            )
            
            Button(action: {
                showingMapView = true
            }) {
                Text("Tüm Kutsal Mekanları Haritada Gör")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(10)
            }
        }
    }
    
    private var prayersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Dualar ve Zikirler")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Hac sırasında okunması tavsiye edilen dualar:")
                .font(.headline)
            
            prayerCard(
                title: "Telbiye",
                arabicText: "لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لَا شَرِيكَ لَكَ لَبَّيْكَ، إِنَّ الْحَمْدَ وَالنِّعْمَةَ لَكَ وَالْمُلْكَ، لَا شَرِيكَ لَكَ",
                turkishText: "Lebbeyk Allahümme lebbeyk. Lebbeyke lâ şerike leke lebbeyk. İnnel hamde ven-ni'mete leke vel-mülk. Lâ şerike lek.",
                meaning: "Buyur Allah'ım buyur! Emrindeyim, buyur! Senin hiçbir ortağın yoktur. Emrindeyim, buyur! Şüphesiz hamd Sana mahsustur. Nimet de Senindir, mülk de Senindir. Senin hiçbir ortağın yoktur."
            )
            
            prayerCard(
                title: "Tavaf Duası",
                arabicText: "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ",
                turkishText: "Rabbenâ âtinâ fid-dünyâ haseneten ve fil-âhirati haseneten ve kınâ azâben-nâr.",
                meaning: "Rabbimiz! Bize dünyada iyilik, ahirette de iyilik ver. Bizi cehennem azabından koru."
            )
            
            prayerCard(
                title: "Arafat Duası",
                arabicText: "لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ",
                turkishText: "Lâ ilâhe illallâhu vahdehû lâ şerîke leh. Lehül-mülkü ve lehül-hamdü ve hüve alâ külli şey'in kadîr.",
                meaning: "Allah'tan başka ilah yoktur, O tektir, ortağı yoktur. Mülk O'nundur, hamd O'nadır ve O her şeye kadirdir."
            )
            
            Divider()
            
            Text("Hac İbadetinde Yapılacak Zikirler")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("• Tekbir: Allahu Ekber")
                Text("• Tesbih: Sübhanallah")
                Text("• Tahmid: Elhamdülillah")
                Text("• Tehlil: La ilahe illallah")
                Text("• İstiğfar: Estağfirullah")
                Text("• Salavat: Allahümme salli ala Muhammed")
            }
            .font(.body)
        }
    }
    
    private var faqSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sık Sorulan Sorular")
                .font(.title2)
                .fontWeight(.bold)
            
            faqItem(
                question: "Türkiye'den hac başvurusu nasıl yapılır?",
                answer: "Diyanet İşleri Başkanlığı'nın internet sitesinde veya il/ilçe müftülüklerinde hac kayıt dönemlerinde başvuru yapabilirsiniz. Başvurular genellikle kura sistemiyle değerlendirilmektedir."
            )
            
            faqItem(
                question: "Hac için en uygun zaman nedir?",
                answer: "Hac ibadeti, Hicri takvime göre Zilhicce ayının 8-13. günleri arasında yapılır. Miladi takvimde bu tarihler her yıl değişiklik gösterir."
            )
            
            faqItem(
                question: "Hac yolculuğu ne kadar sürer?",
                answer: "Türkiye'den düzenlenen hac organizasyonları genellikle 30-45 gün sürmektedir. Bu sürenin bir kısmı Mekke'de, bir kısmı Medine'de geçirilir."
            )
            
            faqItem(
                question: "Hac ibadeti kimlere farzdır?",
                answer: "Akıl sağlığı yerinde olan, ergenlik çağına ulaşmış, hür ve hac yolculuğuna maddi ve bedeni imkanı olan her Müslümana ömründe bir kez hac yapmak farzdır."
            )
            
            faqItem(
                question: "İhram nedir ve nasıl giyilir?",
                answer: "İhram, hac ve umre ibadetlerini yapabilmek için belirli yasaklara uyarak niyet edilmesi ve özel kıyafet giyilmesidir. Erkekler için ihram, belden aşağıya sarılan ve omuza atılan iki parça dikişsiz beyaz kumaştan oluşur. Kadınlar için özel bir kıyafet yoktur, normal tesettür kıyafetleri yeterlidir."
            )
            
            faqItem(
                question: "Hacda hangi aşılara ihtiyaç vardır?",
                answer: "Suudi Arabistan Krallığı'nın belirlediği sağlık şartlarına göre menenjit aşısı zorunludur. Ayrıca doktorunuzun önerdiği diğer aşılar da (grip, zatürre, hepatit vb.) yaptırılabilir."
            )
        }
    }
    
    // MARK: - Helper Views
    
    private func preparationItem<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(Color.accentColor)
                Text(title)
                    .font(.headline)
            }
            
            content()
                .font(.subheadline)
                .padding(.leading)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
    }
    
    private func ritualStep(number: Int, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 36, height: 36)
                
                Text("\(number)")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
    }
    
    private func dayPlan(day: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(day)
                .font(.headline)
                .foregroundStyle(Color.accentColor)
            
            Text(content)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
    }
    
    private func locationCard(name: String, description: String, coordinates: (Double, Double)) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(name)
                .font(.headline)
            
            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            HStack {
                Text("Koordinatlar: \(String(format: "%.4f", coordinates.0)), \(String(format: "%.4f", coordinates.1))")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                Spacer()
                
                Button(action: {
                    showingMapView = true
                    // TODO: Haritayı bu koordinata odakla
                }) {
                    Text("Haritada Göster")
                        .font(.caption)
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
    }
    
    private func prayerCard(title: String, arabicText: String, turkishText: String, meaning: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            
            VStack(alignment: .trailing, spacing: 8) {
                Text(arabicText)
                    .font(.body)
                    .multilineTextAlignment(.trailing)
            }
            .frame(maxWidth: .infinity)
            
            Divider()
            
            Text(turkishText)
                .font(.body)
                .italic()
            
            Divider()
            
            Text("Anlamı:")
                .font(.subheadline)
                .fontWeight(.medium)
            
            Text(meaning)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
    }
    
    private func faqItem(question: String, answer: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(question)
                .font(.headline)
            
            Text(answer)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
    }
}

// MARK: - HajjMapView
struct HajjMapView: View {
    var body: some View {
        VStack {
            Text("Hac Bölgesi Haritası")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            // TODO: Map view will be implemented
            Color.gray.opacity(0.3)
                .overlay(
                    VStack {
                        Image(systemName: "map.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(.gray)
                        
                        Text("Harita görünümü yükleniyor...")
                            .font(.headline)
                            .padding()
                        
                        Text("Bu bölümde Mekke, Arafat, Müzdelife, Mina ve diğer kutsal mekanların interaktif haritaları yer alacaktır.")
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                )
            
            Button("Kapat") {
                // Dismiss the sheet
            }
            .padding()
        }
    }
}

// MARK: - Helper Enums
enum HajjSection: String, CaseIterable {
    case overview = "overview"
    case preparation = "preparation"
    case rituals = "rituals"
    case locations = "locations"
    case prayers = "prayers"
    case faq = "faq"
    
    var title: String {
        switch self {
        case .overview: return "Genel Bilgi"
        case .preparation: return "Hazırlık"
        case .rituals: return "İbadetler"
        case .locations: return "Mekanlar"
        case .prayers: return "Dualar"
        case .faq: return "SSS"
        }
    }
}

// MARK: - Preview
struct HajjGuideView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HajjGuideView()
        }
    }
} 