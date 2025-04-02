import SwiftUI
import Foundation

struct JerusalemGuideView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedSection: JerusalemSection = .overview
    @State private var showingMapView = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Başlık
                HStack {
                    Text("Kudüs Rehberi")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Image(systemName: "building.2.fill")
                        .font(.title)
                        .foregroundStyle(.accentColor)
                }
                .padding(.horizontal)
                
                // Bölüm seçici
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(JerusalemSection.allCases, id: \.self) { section in
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
                    case .importance:
                        importanceSection
                    case .holyPlaces:
                        holyPlacesSection
                    case .history:
                        historySection
                    case .visit:
                        visitSection
                    case .prayers:
                        prayersSection
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
            JerusalemMapView()
        }
    }
    
    // MARK: - Content Sections
    
    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Kudüs'e Genel Bakış")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Kudüs (Arapça: القدس el-Kuds, İbranice: ירושלים Yeruşalayim), üç semavi dinin (İslam, Hristiyanlık ve Yahudilik) kutsal kabul ettiği, Filistin'in doğusunda yer alan tarihi şehirdir. İslam dininde Mekke ve Medine'den sonra üçüncü kutsal şehir olarak kabul edilir.")
                .font(.body)
            
            Image("jerusalem_overview")
                .resizable()
                .scaledToFit()
                .cornerRadius(8)
            
            Divider()
            
            Text("Coğrafi Konum")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("Kudüs, Akdeniz ve Lut Gölü arasında, Akdeniz'den yaklaşık 60 km doğuda, deniz seviyesinden yaklaşık 750-800 metre yükseklikte bulunan dağlık bir alanda yer almaktadır. Şehir, doğu ve batı olmak üzere iki kısma ayrılmıştır.")
                .font(.body)
            
            Divider()
            
            Text("İklim ve En Uygun Ziyaret Zamanı")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("Kudüs, Akdeniz iklimine sahiptir. Yazları sıcak ve kuru, kışları ise soğuk ve yağışlıdır. Ziyaret için en uygun dönemler, ilkbahar (Mart-Mayıs) ve sonbahar (Eylül-Kasım) aylarıdır.")
                .font(.body)
            
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Ortalama Sıcaklıklar:")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Spacer()
                }
                
                Text("• Yazın (Haziran-Ağustos): 20-30°C")
                Text("• Kışın (Aralık-Şubat): 5-15°C")
                Text("• İlkbahar ve Sonbahar: 15-25°C")
            }
            .padding()
            .background(Color.white)
            .cornerRadius(8)
        }
    }
    
    private var importanceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("İslam'da Kudüs'ün Önemi")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Kudüs, İslam dininde çok önemli bir yere sahiptir. Müslümanlar için Mekke ve Medine'den sonra üçüncü kutsal şehirdir.")
                .font(.body)
            
            importanceCard(
                title: "İlk Kıble",
                description: "Kudüs, Müslümanların ilk kıblesidir. Hz. Muhammed (s.a.v.) ve sahabeleri, hicretten sonra yaklaşık 16-17 ay boyunca namazlarda Kudüs'e (Mescid-i Aksa'ya) yönelmişlerdir.",
                iconName: "arrow.up.right"
            )
            
            importanceCard(
                title: "İsra ve Miraç",
                description: "Kur'an-ı Kerim'de bahsedilen İsra olayı, Hz. Muhammed'in (s.a.v.) bir gece Mescid-i Haram'dan Mescid-i Aksa'ya götürülmesi ve oradan da göklere yükseltilmesi (Miraç) olayıdır.",
                iconName: "arrow.up.to.line"
            )
            
            importanceCard(
                title: "Haremeyn-i Şerifeyn",
                description: "Mescid-i Aksa, Mescid-i Haram ve Mescid-i Nebevi ile birlikte ziyaret edilmesi tavsiye edilen üç büyük mescidden biridir.",
                iconName: "building.columns.fill"
            )
            
            importanceCard(
                title: "Kubbetü's-Sahra",
                description: "Hz. Muhammed'in (s.a.v.) Miraç'a yükseldiği yer olarak kabul edilen Kutsal Kaya'nın üzerine inşa edilmiş yapıdır. İslam mimarisinin en önemli eserlerinden biridir.",
                iconName: "building.columns.circle.fill"
            )
            
            importanceCard(
                title: "Hadisler",
                description: "Hz. Muhammed (s.a.v.), \"Yolculuk ancak üç mescide yapılır: Mescid-i Haram, benim mescidim ve Mescid-i Aksa\" buyurmuştur.",
                iconName: "text.book.closed.fill"
            )
            
            Divider()
            
            Text("Kudüs Ziyaretinin Fazileti")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("Mescid-i Aksa'da kılınan bir namaz, diğer mescitlerde kılınan bin namaza denktir. (Mescid-i Haram'da kılınan bir namaz yüz bin, Mescid-i Nebevi'de kılınan bir namaz ise bin namaza denktir.)")
                .font(.body)
                .padding()
                .background(Color.white)
                .cornerRadius(8)
        }
    }
    
    private var holyPlacesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Kutsal Mekanlar")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Kudüs'te ziyaret edilmesi gereken İslami kutsal mekanlar:")
                .font(.body)
            
            holyPlaceCard(
                name: "Mescid-i Aksa",
                description: "İslam'ın ilk kıblesi ve üçüncü kutsal mescidi. Hz. Muhammed'in (s.a.v.) Miraç yolculuğuna çıkmadan önce diğer peygamberlerle namaz kıldığı yer olarak kabul edilir.",
                historicalNote: "Emevi Halifesi Abdülmelik bin Mervan tarafından 690-691 yıllarında inşa edilmiştir.",
                coordinates: (31.7767, 35.2356)
            )
            
            holyPlaceCard(
                name: "Kubbetü's-Sahra (Ömer Camii)",
                description: "Hz. Muhammed'in (s.a.v.) Miraç'a yükseldiği kutsal kaya üzerine inşa edilmiş, altın kubbesiyle ünlü İslam mimarisinin en önemli yapılarından biridir.",
                historicalNote: "Emevi Halifesi Abdülmelik bin Mervan tarafından 688-691 yılları arasında yaptırılmıştır.",
                coordinates: (31.7781, 35.2354)
            )
            
            holyPlaceCard(
                name: "El-Aksa Camii",
                description: "Mescid-i Aksa'nın güney kısmında bulunan ve yaklaşık 5000 kişilik kapasiteye sahip ana ibadet alanıdır.",
                historicalNote: "İlk olarak Emevi Halifesi Velid bin Abdülmelik tarafından 705-715 yılları arasında inşa edilmiştir.",
                coordinates: (31.7762, 35.2358)
            )
            
            holyPlaceCard(
                name: "Kubbet-ül Miraç",
                description: "Hz. Muhammed'in (s.a.v.) Miraç'a yükselmek üzere melek Cebrail ile buluştuğu yer olarak kabul edilir.",
                historicalNote: "İlk olarak Emevi döneminde inşa edilmiş, sonraki dönemlerde yeniden yapılmıştır.",
                coordinates: (31.7778, 35.2350)
            )
            
            holyPlaceCard(
                name: "El-Mervan Camii (Kadim El-Aksa)",
                description: "Mescid-i Aksa'nın altında bulunan ve Hz. Süleyman'ın inşa ettiği mabede ait olduğu düşünülen tarihi bir mekandır.",
                historicalNote: "Romalılar döneminden kaldığı düşünülmektedir.",
                coordinates: (31.7760, 35.2359)
            )
            
            holyPlaceCard(
                name: "Burak Duvarı",
                description: "Hz. Muhammed'in (s.a.v.) İsra gecesinde Burak adlı binekini bağladığı duvar olarak kabul edilir. Batı Duvarı veya Yahudilerce 'Ağlama Duvarı' olarak da bilinir.",
                historicalNote: "M.Ö. 19 yılında II. Herodes döneminde yapılmıştır.",
                coordinates: (31.7767, 35.2342)
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
    
    private var historySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Kudüs'ün İslam Tarihi")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("İslam tarihinde Kudüs önemli bir yere sahiptir. İslam egemenliğindeki Kudüs tarihinin önemli dönüm noktaları:")
                .font(.body)
            
            historicalEvent(
                period: "636-1099",
                title: "İlk İslam Dönemi",
                description: "Hz. Ömer döneminde (638) İslam hakimiyetine girmiştir. Emeviler ve Abbasiler döneminde İslam medeniyetinin önemli merkezlerinden biri olmuştur. Bu dönemde Kubbetü's-Sahra ve El-Aksa Camii inşa edilmiştir."
            )
            
            historicalEvent(
                period: "1099-1187",
                title: "Haçlı İşgali",
                description: "Haçlı Seferleri sırasında Kudüs, 1099'da işgal edilmiş ve birçok Müslüman katledilmiştir. Bu dönemde Kubbetü's-Sahra kiliseye çevrilmiştir."
            )
            
            historicalEvent(
                period: "1187-1516",
                title: "Selahaddin Eyyubi ve Memlükler Dönemi",
                description: "Selahaddin Eyyubi, 1187'de Kudüs'ü Haçlılardan geri almıştır. Memlük Sultanlığı döneminde şehir imar edilmiş ve İslami eserler restore edilmiştir."
            )
            
            historicalEvent(
                period: "1516-1917",
                title: "Osmanlı Dönemi",
                description: "Yavuz Sultan Selim döneminde 1516'da Osmanlı hakimiyetine giren Kudüs, dört yüz yıl boyunca Osmanlı yönetiminde kalmıştır. Kanuni Sultan Süleyman döneminde şehir surları yenilenmiş, su yolları yapılmış ve çeşitli vakıf eserleri inşa edilmiştir."
            )
            
            historicalEvent(
                period: "1917-1948",
                title: "İngiliz Mandası",
                description: "I. Dünya Savaşı sonunda Osmanlı'nın yenilgisiyle Kudüs, İngiliz kontrolüne geçmiştir. Bu dönemde Yahudi göçü artmış ve bölgede gerilimler yükselmiştir."
            )
            
            historicalEvent(
                period: "1948'den Günümüze",
                title: "Modern Dönem",
                description: "1948'de İsrail'in kurulmasıyla Kudüs bölünmüş, 1967 Altı Gün Savaşı'nda Doğu Kudüs İsrail tarafından işgal edilmiştir. Günümüzde Müslümanlar, Kudüs'ün ve Mescid-i Aksa'nın statüsünün korunması için çabalarını sürdürmektedir."
            )
            
            Divider()
            
            Text("Kadim Bir Şehir: Kudüs")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("Kudüs, tarih boyunca yaklaşık 40 kez ele geçirilmiş, 23 kez kuşatılmış ve iki kez yıkılmıştır. Şehir, tüm bu tarihî olaylara rağmen dinî önemini hiçbir zaman kaybetmemiş ve üç semavi din için de kutsal olma özelliğini korumuştur.")
                .font(.body)
                .padding()
                .background(Color.white)
                .cornerRadius(8)
        }
    }
    
    private var visitSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ziyaret Rehberi")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Kudüs'ü ziyaret etmek isteyen Müslümanlar için önemli bilgiler:")
                .font(.body)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Giriş İşlemleri")
                    .font(.headline)
                
                Text("Türkiye Cumhuriyeti vatandaşları Filistin'e (Batı Şeria) girmek için İsrail vizesi almak zorundadır. Vize başvurusu İsrail Büyükelçiliği veya Konsolosluğu'na yapılır. Vizesi hazır olanların, İsrail havalimanlarında sıkı güvenlik kontrollerinden geçeceğini bilmeleri gerekir.")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Ulaşım")
                    .font(.headline)
                
                Text("Kudüs'e ulaşım genellikle Ben Gurion Havalimanı (Tel Aviv) üzerinden sağlanır. Havalimanından Kudüs'e yaklaşık 60 km mesafe vardır. Otobüs, taksi veya araç kiralama ile Kudüs'e ulaşılabilir. Alternatif olarak, Ürdün üzerinden Allenby (Kral Hüseyin) Köprüsü geçişi ile de Kudüs'e giriş yapılabilir.")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Konaklama")
                    .font(.headline)
                
                Text("Kudüs'te çeşitli konaklama imkanları mevcuttur. Doğu Kudüs'te (Arap bölgesi) birçok otel ve misafirhane bulunmaktadır. Eski Şehir içinde veya yakınında konaklama tercih edilebilir, böylece kutsal mekanlara yürüme mesafesinde olunur.")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Mescid-i Aksa Ziyareti")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("• Mescid-i Aksa'ya giriş için pasaport kontrolünden geçmek gerekebilir.")
                    Text("• Kadınlar tesettüre uygun kıyafetle (başörtüsü dahil) giriş yapmalıdır.")
                    Text("• Cuma günleri yaş sınırlaması olabilir; genç erkeklerin girişine izin verilmeyebilir.")
                    Text("• Mescid-i Aksa içerisinde namaz kılmak için en uygun vakitler sabah ve ikindi vakitleridir.")
                    Text("• Ziyaret sırasında İsrail askerlerinden uzak durmak ve provokasyonlara karşı dikkatli olmak gerekir.")
                    Text("• Fotoğraf çekerken izin almak veya dikkatli olmak önemlidir.")
                }
                .font(.body)
                .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Güvenlik Önerileri")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("• Resmi seyahat belgelerini (pasaport vb.) her zaman yanınızda bulundurun.")
                    Text("• Politik tartışmalardan uzak durun.")
                    Text("• Kalabalık gösterilerden ve gergin bölgelerden uzak durun.")
                    Text("• Acil durumlar için Türkiye'nin Kudüs Başkonsolosluğu iletişim bilgilerini not edin.")
                    Text("• Yerel haberleri takip edin ve güvenlik durumuna göre hareket edin.")
                    Text("• Kutsal mekanları ziyaret ederken saygılı ve dikkatli olun.")
                }
                .font(.body)
                .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("En İyi Ziyaret Zamanı")
                    .font(.headline)
                
                Text("Kudüs'ü ziyaret etmek için en uygun dönemler ilkbahar (Mart-Mayıs) ve sonbahar (Eylül-Kasım) aylarıdır. Yazın çok sıcak, kışın ise soğuk ve yağışlı olabilir. Ayrıca, Yahudi bayramları ve tatil dönemlerinde şehir çok kalabalık olabilir, bu dönemlerde fiyatlar yükselir ve bazı yerler kapalı olabilir.")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(8)
        }
    }
    
    private var prayersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Kudüs ile İlgili Dualar")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Kudüs ziyareti sırasında okunabilecek dualar ve zikirler:")
                .font(.body)
            
            prayerCard(
                title: "Mescid-i Aksa'ya Girerken",
                arabicText: "اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ",
                turkishText: "Allahümme'ftah lî ebvâbe rahmetik",
                meaning: "Allah'ım! Bana rahmet kapılarını aç."
            )
            
            prayerCard(
                title: "Mescid-i Aksa'da",
                arabicText: "اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ اللَّهُمَّ بَارِكْ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا بَارَكْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ",
                turkishText: "Allahümme salli alâ Muhammedin ve alâ âli Muhammed. Kemâ salleyte alâ İbrahime ve alâ âli İbrahim. İnneke hamidün mecîd. Allahümme bârik alâ Muhammedin ve alâ âli Muhammed. Kemâ bârekte alâ İbrahime ve alâ âli İbrahim. İnneke hamîdün mecîd.",
                meaning: "Allah'ım! İbrahim'e ve İbrahim'in ailesine rahmet ettiğin gibi, Muhammed'e ve Muhammed'in ailesine de rahmet et. Şüphesiz sen övülmeye layıksın, şan ve şeref sahibisin. Allah'ım! İbrahim'e ve İbrahim'in ailesine bereketler ihsan ettiğin gibi, Muhammed'e ve Muhammed'in ailesine de bereketler ihsan et. Şüphesiz sen övülmeye layıksın, şan ve şeref sahibisin."
            )
            
            prayerCard(
                title: "Kubbetü's-Sahra'da",
                arabicText: "سُبْحَانَ الَّذِي أَسْرَى بِعَبْدِهِ لَيْلًا مِنَ الْمَسْجِدِ الْحَرَامِ إِلَى الْمَسْجِدِ الْأَقْصَى الَّذِي بَارَكْنَا حَوْلَهُ لِنُرِيَهُ مِنْ آيَاتِنَا إِنَّهُ هُوَ السَّمِيعُ الْبَصِيرُ",
                turkishText: "Sübhanellezî esrâ bi abdihî leylen minel mescidil harâmi ilel mescidil aksallezî bâreknâ havlehû linüriyehû min âyâtinâ, innehû hüves semîul basîr.",
                meaning: "Bir gece, kendisine ayetlerimizden bir kısmını gösterelim diye kulunu Mescid-i Haram'dan, çevresini mübarek kıldığımız Mescid-i Aksa'ya götüren Allah, her türlü eksiklikten uzaktır. Şüphesiz O, hakkıyla işiten, hakkıyla görendir. (İsra Suresi, 1. Ayet)"
            )
            
            prayerCard(
                title: "Kudüs için Dua",
                arabicText: "اللَّهُمَّ افْتَحْ عَلَيْنَا أَبْوَابَ الْخَيْرِ وَالْبَرَكَةِ وَالرِّزْقِ وَالْفَرَجِ الْقَرِيبِ، وَاجْعَلْنَا مِمَّنْ زَارَ الْمَسْجِدَ الْأَقْصَى وَصَلَّى فِيهِ، وَاجْعَلْنَا مِنْ أَنْصَارِهِ وَمُدَافِعِيهِ إِلَى يَوْمِ الدِّينِ",
                turkishText: "Allahümme'ftah aleynâ ebvâbel hayri vel beraketi ver rizki vel ferecel karîb. Vec'alnâ mimmen zârel mescidel aksâ ve sallâ fîh. Vec'alnâ min ensârihi ve müdâfiîhi ilâ yevmid dîn.",
                meaning: "Allah'ım! Bize hayır, bereket, rızık ve yakın kurtuluş kapılarını aç. Bizi Mescid-i Aksa'yı ziyaret eden ve orada namaz kılanlardan eyle. Bizi Kıyamet Günü'ne kadar onun yardımcıları ve savunucuları eyle."
            )
            
            Divider()
            
            Text("Kudüs Ziyareti Sırasında Okunabilecek Zikirler")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("• Sübhanallah (33 kez)")
                Text("• Elhamdülillah (33 kez)")
                Text("• Allahu Ekber (33 kez)")
                Text("• La ilahe illallahu vahdehû lâ şerike leh. Lehül mülkü ve lehül hamdü ve hüve alâ külli şey'in kadîr (1 kez)")
                Text("• Ayetü'l-Kürsi")
                Text("• İhlas, Felak ve Nas Sureleri")
            }
            .font(.body)
            .padding()
            .background(Color.white)
            .cornerRadius(8)
        }
    }
    
    // MARK: - Helper Views
    
    private func importanceCard(title: String, description: String, iconName: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: iconName)
                .font(.title2)
                .foregroundStyle(.accentColor)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 8) {
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
    
    private func holyPlaceCard(name: String, description: String, historicalNote: String, coordinates: (Double, Double)) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(name)
                .font(.headline)
            
            Text(description)
                .font(.body)
                .foregroundStyle(.secondary)
            
            Divider()
            
            Text("Tarihçe:")
                .font(.subheadline)
                .fontWeight(.medium)
            
            Text(historicalNote)
                .font(.body)
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
                        .foregroundStyle(.accentColor)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
    }
    
    private func historicalEvent(period: String, title: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(period)
                    .font(.subheadline)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.accentColor.opacity(0.2))
                    .clipShape(Capsule())
                
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
            
            Text(description)
                .font(.body)
                .foregroundStyle(.secondary)
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
}

// MARK: - JerusalemMapView
struct JerusalemMapView: View {
    var body: some View {
        VStack {
            Text("Kudüs Haritası")
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
                        
                        Text("Bu bölümde Kudüs'teki önemli İslami mekanların interaktif haritası yer alacaktır.")
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
enum JerusalemSection: String, CaseIterable {
    case overview = "overview"
    case importance = "importance"
    case holyPlaces = "holyPlaces"
    case history = "history"
    case visit = "visit"
    case prayers = "prayers"
    
    var title: String {
        switch self {
        case .overview: return "Genel Bilgi"
        case .importance: return "Önemi"
        case .holyPlaces: return "Kutsal Yerler"
        case .history: return "Tarihçe"
        case .visit: return "Ziyaret"
        case .prayers: return "Dualar"
        }
    }
}

// MARK: - Preview
struct JerusalemGuideView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            JerusalemGuideView()
        }
    }
} 