import SwiftUI
import Foundation

struct UmrahGuideView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedSection: UmrahSection = .overview
    @State private var showingMapView = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Başlık
                HStack {
                    Text("Umre Rehberi")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Image(systemName: "figure.walk.motion")
                        .font(.title)
                        .foregroundStyle(.accentColor)
                }
                .padding(.horizontal)
                
                // Bölüm seçici
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(UmrahSection.allCases, id: \.self) { section in
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
                    case .visits:
                        visitsSection
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
            UmrahMapView()
        }
    }
    
    // MARK: - Content Sections
    
    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Umre Nedir?")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Umre, Hac zamanı dışında yapılan, Mekke'ye gidip ihrama girme, Kâbe'yi tavaf etme, Safa ve Merve arasında sa'y yapma ve tıraş olarak ihramdan çıkma işlemlerinden oluşan bir ibadettir. Umre, Hac gibi farz değil, sünnettir.")
                .font(.body)
            
            Divider()
            
            Text("Umrenin Önemi")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("Umre, Müslümanlar için manevi arınma, günahlardan temizlenme ve Allah'a yaklaşma vesilesi olarak görülür. Hz. Muhammed (s.a.v.), \"Bir umreden diğer umreye kadar olan süre, aralarındaki günahlara kefarettir\" buyurmuştur.")
                .font(.body)
            
            Divider()
            
            Text("Umre Zamanları")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("Umre, hac mevsimi (Zilhicce ayının 8-13. günleri) dışında yılın her döneminde yapılabilir. Ancak en faziletli umre zamanları Ramazan ayında ve Recep ayında yapılan umredir.")
                .font(.body)
            
            Image("umrah_overview")
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
            
            Text("Umre ibadeti için yapılması gereken hazırlıklar:")
                .font(.body)
            
            VStack(alignment: .leading, spacing: 12) {
                preparationItem(title: "İdari Hazırlıklar", icon: "doc.text.fill") {
                    Text("• Diyanet İşleri Başkanlığı veya özel seyahat acenteleri aracılığıyla umre kaydı yaptırılmalıdır.")
                    Text("• Pasaport ve vize işlemleri tamamlanmalıdır.")
                    Text("• Sağlık kontrolleri ve gerekli aşılar yaptırılmalıdır.")
                    Text("• Umre eğitimlerine katılım sağlanmalıdır.")
                }
                
                preparationItem(title: "Manevi Hazırlık", icon: "heart.fill") {
                    Text("• Günahlardan tövbe edilmelidir.")
                    Text("• Kul haklarının iadesi yapılmalıdır.")
                    Text("• Umre duaları ve tavaf adabı öğrenilmelidir.")
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
            
            Text("Umre Sezonları ve Tavsiye Edilen Zamanlar")
                .font(.title3)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                seasonItem(name: "Ramazan Umresi", period: "Ramazan ayı boyunca", description: "Hz. Muhammed (s.a.v.), Ramazan ayında yapılan umrenin bir hacca denk olduğunu bildirmiştir. Manevi ödülü çok yüksektir.")
                
                seasonItem(name: "Recep Umresi", period: "Recep ayı boyunca", description: "Üç ayların başlangıcında yapılan umre, manevi hazırlık için idealdir.")
                
                seasonItem(name: "Kış Umresi", period: "Aralık - Şubat", description: "Hava şartları daha uygun olduğundan, ibadetleri daha rahat yerine getirme imkanı sağlar.")
                
                seasonItem(name: "Yaz Umresi", period: "Haziran - Ağustos", description: "Sıcaklıklar çok yüksek olduğundan, sağlık sorunu olmayan kişiler için uygundur.")
            }
        }
    }
    
    private var ritualsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Umre İbadetinin Adımları")
                .font(.title2)
                .fontWeight(.bold)
            
            ritualStep(number: 1, title: "İhrama Girmek", description: "Mikat sınırında ihrama girilir ve niyet edilir. Erkekler dikişsiz iki parça beyaz kumaş giyer, kadınlar normal tesettür kıyafetlerini giyerler.")
            
            ritualStep(number: 2, title: "Kâbe'yi Tavaf Etmek", description: "Mescid-i Haram'a girince, Kâbe'nin etrafında yedi kez dönülür. Tavaf, Hacer-ül Esved'in hizasından başlar ve saat yönünün tersine yapılır.")
            
            ritualStep(number: 3, title: "Sa'y Yapmak", description: "Safa tepesinden başlayarak, Merve tepesine dört gidiş, üç geliş olmak üzere yedi kez gidilip gelinir.")
            
            ritualStep(number: 4, title: "Tıraş Olmak/Saç Kesmek", description: "Erkekler saçlarını tıraş eder veya kısaltır, kadınlar ise saçlarının ucundan bir miktar keserler. Böylece ihramdan çıkılmış olur.")
            
            Divider()
            
            Text("Umre Sırasında Dikkat Edilmesi Gerekenler")
                .font(.title3)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("• Tavaf sırasında abdestli olmak gerekir.")
                Text("• Sa'y için abdest şart değildir ancak abdestli olmak müstehaptır.")
                Text("• İhramlıyken kaçınılması gereken yasaklara (tırnak kesmek, koku sürmek, avlanmak, cinsel ilişki vb.) dikkat edilmelidir.")
                Text("• Mescid-i Haram'da saygı ve huşu içinde bulunulmalıdır.")
                Text("• Tavaf ve sa'y duaları okunmalıdır.")
                Text("• Kalabalık zamanlarda sabırlı ve anlayışlı olunmalıdır.")
            }
            .font(.body)
            .padding()
            .background(Color.white)
            .cornerRadius(8)
        }
    }
    
    private var visitsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ziyaret Edilebilecek Yerler")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Umre sırasında ziyaret edilebilecek önemli mekanlar:")
                .font(.body)
            
            visitCard(
                name: "Mescid-i Nebevi",
                location: "Medine",
                description: "Hz. Muhammed'in mescidi ve kabri burada bulunur. Cennet Bahçesi (Ravza-i Mutahhara) olarak bilinen bölüm özellikle ziyaret edilmelidir.",
                importance: "Burada kılınan bir namaz, Mescid-i Haram dışındaki diğer mescitlerde kılınan bin namaza denktir."
            )
            
            visitCard(
                name: "Uhud Dağı",
                location: "Medine",
                description: "Uhud Savaşı'nın gerçekleştiği ve Hz. Hamza'nın şehit düştüğü yerdir.",
                importance: "Uhud, Hz. Muhammed'in \"Uhud bizi sever, biz de Uhud'u severiz\" dediği mübarek bir dağdır."
            )
            
            visitCard(
                name: "Hira Mağarası",
                location: "Mekke",
                description: "Hz. Muhammed'e ilk vahyin geldiği mağaradır. Nur Dağı'nın zirvesinde bulunur.",
                importance: "İslam'ın başlangıç noktası olarak kabul edilir."
            )
            
            visitCard(
                name: "Cennetü'l Mualla",
                location: "Mekke",
                description: "Hz. Hatice annemiz, Hz. Muhammed'in amcası Ebu Talib ve diğer pek çok sahabenin kabirlerinin bulunduğu mezarlıktır.",
                importance: "Dini ve tarihi öneme sahip bir ziyaret yeridir."
            )
            
            visitCard(
                name: "Sevr Mağarası",
                location: "Mekke",
                description: "Hz. Muhammed'in Mekke'den Medine'ye hicreti sırasında Hz. Ebubekir ile birlikte üç gün boyunca saklandıkları mağaradır.",
                importance: "Kuran'da zikredilen ve önemli bir hicret durağıdır."
            )
            
            visitCard(
                name: "Cennet-ül Baki",
                location: "Medine",
                description: "Hz. Osman, Hz. Hasan, Hz. Muhammed'in eşleri ve kızları başta olmak üzere binlerce sahabenin kabirlerinin bulunduğu mezarlıktır.",
                importance: "İslam tarihinde önemli şahsiyetlerin kabirlerinin bulunduğu mezarlıktır."
            )
        }
    }
    
    private var prayersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Dualar ve Zikirler")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Umre sırasında okunması tavsiye edilen dualar:")
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
                title: "Sa'y Duası",
                arabicText: "رَبِّ اغْفِرْ وَارْحَمْ وَتَجَاوَزْ عَمَّا تَعْلَمُ إِنَّكَ أَنْتَ الْأَعَزُّ الْأَكْرَمُ",
                turkishText: "Rabbiğfir verham vetecâvez ammâ ta'lem. İnneke entel e'azzül ekram.",
                meaning: "Rabbim! Bağışla, merhamet et ve bildiğin kusurlarımı affet. Şüphesiz Sen en Aziz ve en Kerim olansın."
            )
            
            Divider()
            
            Text("Umre'de Önemli Zikirler")
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
            .padding()
            .background(Color.white)
            .cornerRadius(8)
        }
    }
    
    private var faqSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sık Sorulan Sorular")
                .font(.title2)
                .fontWeight(.bold)
            
            faqItem(
                question: "Umre ne zaman yapılabilir?",
                answer: "Umre, Hac mevsimi (Zilhicce ayının 8-13 günleri) dışında yılın her zamanı yapılabilir. Özellikle Ramazan ayında yapılan umrenin sevabı çok yüksektir."
            )
            
            faqItem(
                question: "Umre ne kadar sürer?",
                answer: "Türkiye'den düzenlenen umre organizasyonları genellikle 10-15 gün sürmektedir. Ancak 7 günlük veya 1 aylık programlar da mevcuttur."
            )
            
            faqItem(
                question: "Umre için nereye başvurmalıyım?",
                answer: "Diyanet İşleri Başkanlığı veya Diyanet İşleri Başkanlığı'nın yetki verdiği seyahat acenteleri aracılığıyla umre başvurusu yapabilirsiniz."
            )
            
            faqItem(
                question: "Umrenin maliyeti ne kadardır?",
                answer: "Umre maliyeti konaklama süresi, otel kategorisi, gidilen sezon ve hizmet kalitesine göre değişmektedir. Resmi kurum olan Diyanet İşleri Başkanlığı'nın internet sitesinden güncel fiyatları öğrenebilirsiniz."
            )
            
            faqItem(
                question: "Umre için hangi aşılar gereklidir?",
                answer: "Suudi Arabistan'ın belirlediği sağlık şartlarına göre menenjit aşısı zorunludur. Ayrıca doktorunuzun önerebileceği diğer aşıları da (grip, zatürre, hepatit vb.) yaptırmanız tavsiye edilir."
            )
            
            faqItem(
                question: "Umrede kadınlar için özel ihram var mıdır?",
                answer: "Kadınlar için özel bir ihram kıyafeti yoktur. Normal tesettür kıyafetleri yeterlidir. Ancak ihram yasaklarına uymak zorundadırlar."
            )
        }
    }
    
    // MARK: - Helper Views
    
    private func preparationItem<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(.accentColor)
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
    
    private func seasonItem(name: String, period: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(name)
                .font(.headline)
                .foregroundStyle(.primary)
            
            Text(period)
                .font(.subheadline)
                .foregroundStyle(.accentColor)
                .fontWeight(.medium)
            
            Text(description)
                .font(.body)
                .foregroundStyle(.secondary)
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
    
    private func visitCard(name: String, location: String, description: String, importance: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(name)
                    .font(.headline)
                
                Spacer()
                
                Text(location)
                    .font(.subheadline)
                    .foregroundStyle(.accentColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.1))
                    .clipShape(Capsule())
            }
            
            Text(description)
                .font(.body)
                .foregroundStyle(.secondary)
            
            Divider()
            
            Text("Önemi:")
                .font(.subheadline)
                .fontWeight(.medium)
            
            Text(importance)
                .font(.body)
                .foregroundStyle(.secondary)
            
            Button(action: {
                showingMapView = true
                // TODO: Haritayı bu lokasyona odakla
            }) {
                HStack {
                    Image(systemName: "map.fill")
                    Text("Haritada Göster")
                }
                .font(.caption)
                .foregroundStyle(.accentColor)
            }
            .padding(.top, 4)
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

// MARK: - UmrahMapView
struct UmrahMapView: View {
    var body: some View {
        VStack {
            Text("Umre Bölgesi Haritası")
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
                        
                        Text("Bu bölümde Mekke, Medine ve diğer önemli ziyaret yerlerinin interaktif haritaları yer alacaktır.")
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
enum UmrahSection: String, CaseIterable {
    case overview = "overview"
    case preparation = "preparation"
    case rituals = "rituals"
    case visits = "visits"
    case prayers = "prayers"
    case faq = "faq"
    
    var title: String {
        switch self {
        case .overview: return "Genel Bilgi"
        case .preparation: return "Hazırlık"
        case .rituals: return "İbadetler"
        case .visits: return "Ziyaretler"
        case .prayers: return "Dualar"
        case .faq: return "SSS"
        }
    }
}

// MARK: - Preview
struct UmrahGuideView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UmrahGuideView()
        }
    }
} 