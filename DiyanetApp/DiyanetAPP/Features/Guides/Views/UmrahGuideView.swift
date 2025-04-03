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
                        .foregroundStyle(Color.accentColor)
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
                    Text("• Sağlık kontrolleri ve gerekli aşılar yaptırılmalıdır (menenjit aşısı zorunludur).")
                    Text("• Umre eğitimlerine katılım sağlanmalıdır.")
                    Text("• Yolculuk için uygun bir döviz temin edilmelidir (Suudi Arabistan Riyali veya ABD Doları).")
                }
                
                preparationItem(title: "Manevi Hazırlık", icon: "heart.fill") {
                    Text("• Günahlardan tövbe edilmelidir.")
                    Text("• Kul haklarının iadesi yapılmalıdır.")
                    Text("• Umre duaları ve tavaf adabı öğrenilmelidir.")
                    Text("• İbadetler düzenli şekilde yerine getirilmelidir.")
                    Text("• Manevi eğitim için umre rehberi okunmalıdır.")
                    Text("• Sabır ve tahammülün önemi hatırda tutulmalıdır.")
                }
                
                preparationItem(title: "İhram Rehberi", icon: "person.fill") {
                    Text("• İhrama girmeden önce yapılması gerekenler:")
                    Text("  - Gusül abdesti almak (sünnet)")
                    Text("  - Tırnak kesmek, tüyleri gidermek")
                    Text("  - Güzel koku sürünmek (ihramdan önce)")
                    Text("• İhram Kıyafeti:")
                    Text("  - Erkekler: Belden aşağı (izar) ve omuzlara (rida) sarılan iki parça dikişsiz kumaş")
                    Text("  - Kadınlar: Normal tesettür kıyafetleri, eldiven ve peçe hariç")
                    Text("• İhram Yasakları:")
                    Text("  - Saç, sakal ve tüyleri kesmek")
                    Text("  - Tırnak kesmek")
                    Text("  - Koku sürünmek")
                    Text("  - Cinsel ilişki ve buna götüren davranışlar")
                    Text("  - Avlanmak, bitki koparmak")
                    Text("  - Dikişli elbise giymek (erkekler için)")
                }
                
                preparationItem(title: "Yanınızda Götürecekleriniz", icon: "bag.fill") {
                    Text("• İhram (erkekler için)")
                    Text("• Uygun kıyafetler (mevsime göre)")
                    Text("• Sağlık malzemeleri ve ilaçlar")
                    Text("• Dua kitapları")
                    Text("• Kişisel bakım ürünleri")
                    Text("• Rahat ayakkabılar")
                    Text("• Omuz çantası (değerli eşyalar için)")
                    Text("• Telefon ve şarj cihazı")
                    Text("• Uluslararası seyahat adaptörü")
                    Text("• Hafif atıştırmalıklar")
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
            
            Divider()
            
            Text("Önemli İletişim Bilgileri")
                .font(.title3)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("• Diyanet İşleri Başkanlığı Hac ve Umre Hizmetleri Genel Müdürlüğü: +90 312 295 84 00")
                Text("• Türkiye'nin Suudi Arabistan Büyükelçiliği: +966 11 4880000")
                Text("• Cidde Başkonsolosluğu: +966 12 6677561")
                Text("• Mekke Acil Durum: 911")
                Text("• Ambulans: 997")
                Text("• Polis: 999")
                Text("• Yol Yardım: 993")
                Text("• Hac ve Umre Bakanlığı İletişim Merkezi: 8002451000")
            }
            .font(.caption)
        }
    }
    
    private var ritualsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Umre İbadetinin Adımları")
                .font(.title2)
                .fontWeight(.bold)
            
            ritualStep(number: 1, title: "İhrama Girmek", description: "Mikat sınırında ihrama girilir ve niyet edilir. Erkekler dikişsiz iki parça beyaz kumaş giyer, kadınlar normal tesettür kıyafetlerini giyerler.")
            
            Text("İhram Niyeti:")
                .font(.headline)
                .padding(.top, 8)
            
            Text("\"Allah'ım! Senin rızan için umre yapmak istiyorum. Onu bana kolaylaştır ve kabul et. Lebbeyk Allahümme Umreten.\"")
                .font(.body)
                .italic()
                .padding(.horizontal)
            
            ritualStep(number: 2, title: "Kâbe'yi Tavaf Etmek", description: "Mescid-i Haram'a girince, Kâbe'nin etrafında yedi kez dönülür. Tavaf, Hacer-ül Esved'in hizasından başlar ve saat yönünün tersine yapılır.")
            
            Text("Tavaf Adımları:")
                .font(.headline)
                .padding(.top, 8)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("1. Tavafa Hacer-ül Esved'in hizasından başlanır ve tekbir getirilir.")
                Text("2. Erkekler ilk üç şavtta remel yapar (hızlı ve çalımlı yürür).")
                Text("3. Her şavtta Hacer-ül Esved'e işaret edilir ve tekbir getirilir.")
                Text("4. Rükn-ü Yemani ve Hacer-ül Esved arasında özel dualar okunur.")
                Text("5. Tavaf sırasında dua edilir ve zikir çekilir.")
                Text("6. Yedi şavt tamamlandıktan sonra Makam-ı İbrahim'de iki rekat namaz kılınır.")
                Text("7. Zemzem suyu içilir.")
            }
            .font(.subheadline)
            .padding(.horizontal)
            
            ritualStep(number: 3, title: "Sa'y Yapmak", description: "Safa tepesinden başlayarak, Merve tepesine dört gidiş, üç geliş olmak üzere yedi kez gidilip gelinir.")
            
            Text("Sa'y Adımları:")
                .font(.headline)
                .padding(.top, 8)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("1. Sa'y, Safa tepesinden başlar. Tekbir getirilerek niyet edilir.")
                Text("2. Merve'ye doğru yürünür. Yeşil ışıklı direklerin arasında erkekler koşar, kadınlar normal yürür.")
                Text("3. Merve'ye ulaşınca tekbir getirilir ve dua edilir.")
                Text("4. Tekrar Safa'ya dönülür.")
                Text("5. Bu şekilde 7 tur tamamlanır (Safa → Merve 1 tur, Merve → Safa 2. tur).")
                Text("6. Sa'y Merve'de son bulur.")
            }
            .font(.subheadline)
            .padding(.horizontal)
            
            ritualStep(number: 4, title: "Tıraş Olmak/Saç Kesmek", description: "Erkekler saçlarını tıraş eder veya kısaltır, kadınlar ise saçlarının ucundan bir miktar keserler. Böylece ihramdan çıkılmış olur.")
            
            Divider()
            
            Text("Umre Sırasında Dikkat Edilmesi Gerekenler")
                .font(.title3)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("• Tavaf sırasında abdestli olmak gerekir.")
                Text("• Sa'y için abdest şart değildir ancak abdestli olmak müstehaptır.")
                Text("• İhramlıyken yasaklara dikkat edilmelidir.")
                Text("• Mescid-i Haram'da saygı ve huşu içinde bulunulmalıdır.")
                Text("• Kalabalık zamanlarda yaşlılara, hastalara ve kadınlara dikkat edilmelidir.")
                Text("• Tavaf esnasında kalabalığa dikkat edip izdiham oluşturmamaya özen gösterilmelidir.")
                Text("• Yüksek sesle konuşmamalı ve başkalarını rahatsız etmekten kaçınılmalıdır.")
                Text("• Özellikle kalabalık zamanlarda sabırlı ve anlayışlı olunmalıdır.")
                Text("• Kaybolmamak için grup liderini veya belirli noktaları takip etmek önemlidir.")
            }
            
            Divider()
            
            Text("Yaygın Hatalar ve Önlemler")
                .font(.title3)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 10) {
                hataItem(hata: "Tavafta şavt karıştırmak", onlem: "Tavaf sırasında şavtları saymak için tesbih veya sayaç kullanılabilir.")
                hataItem(hata: "Sa'y yaparken sayıları karıştırmak", onlem: "Sa'y yaparken tepeleri takip etmek ve zihinden sayı tutmak önemlidir.")
                hataItem(hata: "Hacer-ül Esved'i öpmek için aşırı çaba göstermek", onlem: "Kalabalık zamanlarda uzaktan selamlamak yeterlidir, izdiham oluşturmaktan kaçınılmalıdır.")
                hataItem(hata: "İhram yasaklarına uymamak", onlem: "İhram yasakları önceden öğrenilmeli ve titizlikle uygulanmalıdır.")
                hataItem(hata: "Tavaf namazını unutmak", onlem: "Her ritüelin adımlarını önceden çalışmak ve bir kontrol listesi bulundurmak faydalıdır.")
            }
        }
    }
    
    private var visitsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Mekke ve Medine'de Ziyaret Yerleri")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Umre sırasında ziyaret edilmesi tavsiye edilen önemli yerler:")
                .font(.headline)
            
            Group {
                visitCard(
                    location: "Mescid-i Haram (Kâbe)",
                    description: "İslam'ın en kutsal mekânı. Kâbe'nin bulunduğu ve tavaf ibadetinin yapıldığı mescid.",
                    visitTips: "Her vakit namazını burada kılmaya çalışın. En az izdiham olan saatleri tercih edin (gece yarısı veya sabah erken saatler)."
                )
                
                visitCard(
                    location: "Mescid-i Nebevi",
                    description: "Hz. Muhammed'in (s.a.v.) Medine'de inşa ettiği ve kabrinin bulunduğu mescid.",
                    visitTips: "Mescid-i Nebevi'de 40 vakit namaz kılmaya çalışın. Ravza-i Mutahhara'yı ziyaret edin. Kabir ziyareti için en uygun zamanı rehberinizden öğrenin."
                )
                
                visitCard(
                    location: "Cennet-ül Baki",
                    description: "Hz. Muhammed'in (s.a.v.) birçok aile üyesinin ve sahabenin medfun olduğu Medine'deki mezarlık.",
                    visitTips: "Ziyaret saatlerine dikkat edin, çünkü belirli vakitlerde ziyarete açıktır."
                )
                
                visitCard(
                    location: "Uhud Dağı",
                    description: "Uhud Savaşı'nın gerçekleştiği ve Hz. Hamza başta olmak üzere birçok şehidin medfun olduğu yer.",
                    visitTips: "Şehitlik ziyaretinde saygı ve huşu içinde olun. Fotoğraf çekerken saygılı olun."
                )
                
                visitCard(
                    location: "Kuba Mescidi",
                    description: "Hz. Muhammed'in (s.a.v.) Medine'ye hicreti sırasında ilk inşa ettiği mescid.",
                    visitTips: "Burada iki rekat namaz kılmanın büyük sevabı vardır."
                )
                
                visitCard(
                    location: "Hira Mağarası",
                    description: "Hz. Muhammed'e (s.a.v.) ilk vahyin geldiği Nur Dağı'ndaki mağara.",
                    visitTips: "Dağa tırmanış yorucu olabilir, sağlık durumunuza göre karar verin. Yanınızda su bulundurun."
                )
                
                visitCard(
                    location: "Sevr Mağarası",
                    description: "Hz. Muhammed'in (s.a.v.) Hz. Ebu Bekir ile birlikte hicret sırasında saklandığı mağara.",
                    visitTips: "Dağa tırmanmak zor olabilir, organize turlarla ziyaret etmeniz önerilir."
                )
                
                visitCard(
                    location: "Cin Mescidi",
                    description: "Hz. Muhammed'in (s.a.v.) cinlere Kur'an okuduğu yer olduğuna inanılan mescid.",
                    visitTips: "Mekke'nin dışında bulunduğundan, organize bir turla ziyaret edilmesi önerilir."
                )
                
                visitCard(
                    location: "Cennet-ül Mualla",
                    description: "Hz. Hatice ve birçok sahabenin medfun olduğu Mekke'deki mezarlık.",
                    visitTips: "Kısa bir ziyaret yapın ve dua edin."
                )
            }
            
            Divider()
            
            Text("Ziyaret Adabı")
                .font(.title3)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("• Kutsal mekânları ziyaret ederken saygı ve huşu içinde olun.")
                Text("• Mezarlık ziyaretlerinde uygun duaları okuyun.")
                Text("• Fotoğraf çekerken başkalarını rahatsız etmemeye dikkat edin.")
                Text("• Özellikle Ravza-i Mutahhara ziyaretinde kalabalığı artırmamaya özen gösterin.")
                Text("• Ziyaret yerlerinde aşırı sesli konuşmayın ve manevi atmosfere uygun davranın.")
                Text("• Organize ziyaretlerde rehberlerin talimatlarına uyun.")
                Text("• Uygun kıyafetlerle ziyaret edin, özellikle mescitlerde kıyafet kurallarına dikkat edin.")
            }
            .font(.body)
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
                title: "İhram Duası ve Telbiye",
                arabicText: "لَبَّيْكَ اللَّهُمَّ بِعُمْرَة. لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لَا شَرِيكَ لَكَ لَبَّيْكَ، إِنَّ الْحَمْدَ وَالنِّعْمَةَ لَكَ وَالْمُلْكَ، لَا شَرِيكَ لَكَ",
                turkishText: "Lebbeyk Allahümme bi-umrah. Lebbeyk Allahümme lebbeyk. Lebbeyke lâ şerike leke lebbeyk. İnnel hamde ven-ni'mete leke vel-mülk. Lâ şerike lek.",
                meaning: "Allah'ım! Umre için emrindeyim. Buyur Allah'ım buyur! Emrindeyim, buyur! Senin hiçbir ortağın yoktur. Emrindeyim, buyur! Şüphesiz hamd Sana mahsustur. Nimet de Senindir, mülk de Senindir. Senin hiçbir ortağın yoktur."
            )
            
            prayerCard(
                title: "Mescid-i Haram'a Giriş Duası",
                arabicText: "اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَسَلِّمْ، اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ",
                turkishText: "Allahümme salli alâ Muhammedin ve sellim. Allahümmeftah lî ebvâbe rahmetik.",
                meaning: "Allah'ım! Muhammed'e salat ve selam eyle. Allah'ım! Bana rahmet kapılarını aç."
            )
            
            prayerCard(
                title: "Tavaf Duası",
                arabicText: "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ",
                turkishText: "Rabbenâ âtinâ fid-dünyâ haseneten ve fil-âhirati haseneten ve kınâ azâben-nâr.",
                meaning: "Rabbimiz! Bize dünyada iyilik, ahirette de iyilik ver. Bizi cehennem azabından koru."
            )
            
            prayerCard(
                title: "Safa ve Merve Duası",
                arabicText: "إِنَّ الصَّفَا وَالْمَرْوَةَ مِنْ شَعَائِرِ اللَّهِ فَمَنْ حَجَّ الْبَيْتَ أَوِ اعْتَمَرَ فَلا جُنَاحَ عَلَيْهِ أَنْ يَطَّوَّفَ بِهِمَا",
                turkishText: "İnnes-safâ vel-mervete min şeâirillâh. Fe men haccel-beyte ev i'temera felâ cünâha aleyhi en yettavvefe bihimâ.",
                meaning: "Şüphesiz Safa ile Merve, Allah'ın (dininin) nişanelerindendir. Onun için her kim hac ve umre niyetiyle Kâbe'yi ziyaret eder ve onları tavaf ederse, bunda bir günah yoktur."
            )
            
            prayerCard(
                title: "Zemzem İçerken Okunacak Dua",
                arabicText: "اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا وَرِزْقًا وَاسِعًا وَشِفَاءً مِنْ كُلِّ دَاءٍ",
                turkishText: "Allâhümme innî es'elüke ilmen nâfi'an ve rizkan vâsi'an ve şifâen min külli dâ'.",
                meaning: "Allah'ım! Senden faydalı ilim, bol rızık ve her türlü hastalıktan şifa istiyorum."
            )
            
            Divider()
            
            Text("Umre Sırasında Yapılacak Zikirler")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("• Sübhanallah (Allah'ı eksikliklerden tenzih ederim): 33 defa")
                Text("• Elhamdülillah (Hamd Allah'a mahsustur): 33 defa")
                Text("• Allahu Ekber (Allah en büyüktür): 34 defa")
                Text("• La ilahe illallah (Allah'tan başka ilah yoktur)")
                Text("• Estağfirullah (Allah'tan bağışlanma dilerim)")
                Text("• Salat-ı Tefriciye")
            }
            .font(.body)
            
            Text("Umre Sonrası Dua")
                .font(.headline)
                .padding(.top)
            
            Text("\"Allah'ım! Umremi kabul buyur, günahlarımı bağışla, bana merhamet et. Buradan ayrıldıktan sonra bana hayırlı bir gelecek nasip eyle. Bu ziyaretimizi son ziyaretimiz kılma. Bize tekrar gelmeyi nasip eyle.\"")
                .font(.body)
                .italic()
                .padding()
                .background(Color(.systemGray6))
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
                answer: "Umre, Hac mevsimi (Zilhicce ayının 8-13. günleri) dışında yılın her zamanında yapılabilir. En faziletli zamanı ise Ramazan ayı içerisindedir."
            )
            
            faqItem(
                question: "Umre yaptıktan sonra tekrar yapılabilir mi?",
                answer: "Evet, umre hayatta birden fazla kez yapılabilir. Her umre, küçük günahlara kefaret olduğu için tekrarlanması tavsiye edilir."
            )
            
            faqItem(
                question: "Umre kaç gün sürer?",
                answer: "Umre ibadeti tek günde tamamlanabilir, ancak Türkiye'den düzenlenen umre turları genellikle 10-15 gün arasında sürer. Bu süreçte hem Mekke hem de Medine ziyaret edilir."
            )
            
            faqItem(
                question: "Umre için vize gerekli midir?",
                answer: "Evet, Suudi Arabistan'a giriş için özel umre vizesi gerekmektedir. Bu vize, umre organizasyonları tarafından toplu olarak alınır."
            )
            
            faqItem(
                question: "Umre ne kadara mal olur?",
                answer: "Umre maliyeti, sezon, kalış süresi, konaklama kalitesi ve seyahat firmasına göre değişkenlik gösterir. Türkiye'den umre programları, 2023 yılı itibariyle yaklaşık 2.500 - 6.000 USD arasında değişmektedir."
            )
            
            faqItem(
                question: "Kadınlar özel halleri sırasında umre yapabilir mi?",
                answer: "Kadınlar adet veya lohusalık durumlarında tavaf dışındaki tüm ibadetleri yapabilirler. Tavaf temizlendikten sonra yapılmalıdır. İhrama girebilir, sa'y yapabilir ve diğer ziyaretleri gerçekleştirebilirler."
            )
            
            faqItem(
                question: "Umrede şeytan taşlama var mı?",
                answer: "Hayır, şeytan taşlama sadece hac ibadetinde vardır. Umre; ihrama girme, tavaf, sa'y ve tıraş olmaktan ibarettir."
            )
            
            faqItem(
                question: "Umre için hangi aşılar gereklidir?",
                answer: "Suudi Arabistan'a giriş için menenjit aşısı zorunludur. Ayrıca grip, hepatit gibi aşılar da tavsiye edilmektedir."
            )
            
            faqItem(
                question: "Umrede vekalet olur mu?",
                answer: "Evet, umre de hac gibi vekâleten yapılabilir. Hasta, yaşlı veya vefat etmiş kişiler adına umre yapılabilir."
            )
            
            faqItem(
                question: "Çocuklar umre yapabilir mi?",
                answer: "Evet, çocuklar umre yapabilir. Ancak temyiz çağına (akıl-baliğ) ermemiş çocuklar için velileri niyette bulunur ve onların yapamayacağı işlemleri yardım ederek tamamlar."
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
    
    private func seasonItem(name: String, period: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(name)
                .font(.headline)
                .foregroundStyle(.primary)
            
            Text(period)
                .font(.subheadline)
                .foregroundStyle(Color.accentColor)
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
    
    private func visitCard(location: String, description: String, visitTips: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(location)
                .font(.headline)
            
            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Divider()
            
            HStack(alignment: .top) {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(Color.yellow)
                
                Text("Ziyaret İpucu: \(visitTips)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 2)
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
    
    private func hataItem(hata: String, onlem: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(Color.orange)
                
                Text(hata)
                    .font(.headline)
            }
            
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.green)
                    .padding(.leading, 24)
                
                Text(onlem)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
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