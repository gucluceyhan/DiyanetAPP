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
                    Text("• Sağlık kontrolleri ve aşılar yaptırılmalıdır (Menenjit aşısı zorunludur).")
                    Text("• E-Devlet üzerinden veya Müftülüklere giderek hac kaydı yapılmalıdır.")
                    Text("• Hac eğitimlerine katılım sağlanmalıdır.")
                }
                
                preparationItem(title: "Manevi Hazırlık", icon: "heart.fill") {
                    Text("• Günahlardan tövbe edilmelidir.")
                    Text("• Kul haklarının iadesi yapılmalıdır.")
                    Text("• Hac ve umre duaları öğrenilmelidir.")
                    Text("• İbadetler düzenli şekilde yerine getirilmelidir.")
                    Text("• İbadetlerin hikmetleri ve manevi anlamları üzerine düşünülmelidir.")
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
                    Text("• Uygun kıyafetler (hava koşullarına göre)")
                    Text("• Güneş şapkası/şemsiye (sıcaktan korunmak için)")
                    Text("• Sağlık malzemeleri ve ilaçlar")
                    Text("• Dua kitapları ve Kur'an-ı Kerim")
                    Text("• Kişisel bakım ürünleri")
                    Text("• Rahat ayakkabılar, terlikler")
                    Text("• Elektronik cihazlar için taşınabilir şarj aleti")
                    Text("• Su matarası/termos")
                    Text("• Omuz çantası/kemer çantası (değerli eşyalar için)")
                }
            }
            
            Divider()
            
            Text("Önemli İletişim Bilgileri")
                .font(.title3)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("• Diyanet İşleri Başkanlığı Hac ve Umre Hizmetleri Genel Müdürlüğü: +90 312 295 84 00")
                Text("• Türkiye'nin Suudi Arabistan Büyükelçiliği: +966 11 4880000")
                Text("• Cidde Başkonsolosluğu: +966 12 6677561")
                Text("• Mekke Suudi Arabistan Acil Durum Numarası: 911")
                Text("• Ambulans: 997")
                Text("• Polis: 999")
                Text("• Yol Yardım: 993")
                Text("• Hac Sorgu ve Şikayet Hattı: 8002451000")
            }
            .font(.caption)
            
            preparationItem(title: "Sağlık ve Güvenlik İpuçları", icon: "heart.text.square.fill") {
                Text("• Sıcak havalarda sık sık su için (en az 2-3 litre/gün)")
                Text("• İbadetler sırasında enerjinizi korumak için hafif atıştırmalıklar bulundurun")
                Text("• Güneş çarpmasına karşı şapka/şemsiye kullanın")
                Text("• Kalabalıklarda gruptan ayrılmamaya özen gösterin")
                Text("• Değerli eşyalarınızı güvenli şekilde yanınızda taşıyın")
                Text("• El hijyenine dikkat edin, sık sık el dezenfektanı kullanın")
                Text("• Yanınızda mutlaka kişisel ilaçlarınızı ve basit ilk yardım malzemelerini bulundurun")
                Text("• Yüksek tansiyon, kalp rahatsızlığı, diyabet gibi kronik hastalıkları olanlar ilaçlarını yanlarında bulundurmalı")
            }
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
            
            Text("Hac ibadetinde ziyaret edilecek kutsal mekanlar:")
                .font(.headline)
            
            locationCard(
                name: "Kâbe-i Muazzama",
                description: "İslam'ın en kutsal mekânı, Müslümanların kıblesi. Hz. İbrahim ve oğlu Hz. İsmail tarafından inşa edilmiştir. Tavaf ibadetinin yapıldığı yerdir.",
                coordinates: (21.4225, 39.8262)
            )
            
            locationCard(
                name: "Hacerü'l-Esved",
                description: "Kâbe'nin güneydoğu köşesinde bulunan siyah taş. Cennet'ten indirildiğine inanılır ve tavaf sırasında selamlanır.",
                coordinates: (21.4225, 39.8262)
            )
            
            locationCard(
                name: "Arafat",
                description: "Hac ibadetinin en önemli rüknü olan vakfenin yapıldığı yer. Arefe günü (9 Zilhicce) burada vakfe yapılır. Hz. Adem ile Hz. Havva'nın burada buluştuğuna inanılır.",
                coordinates: (21.3549, 39.9841)
            )
            
            locationCard(
                name: "Müzdelife",
                description: "Arafat'tan sonra geceyi geçirilen yer. Buradan şeytan taşlamak için taşlar toplanır. Arefe günü akşamı Mina'ya geçmeden önce burada vakfe yapılır.",
                coordinates: (21.3764, 39.9375)
            )
            
            locationCard(
                name: "Mina",
                description: "Şeytan taşlama ibadetinin yapıldığı ve teşrik günlerinde kalınan yer. Hz. İbrahim'in oğlu Hz. İsmail'i kurban etmek istediği yer olduğuna inanılır.",
                coordinates: (21.4133, 39.8933)
            )
            
            locationCard(
                name: "Safa ve Merve Tepeleri",
                description: "Hz. Hacer'in oğlu Hz. İsmail için su ararken koştuğu tepeler. Sa'y ibadeti bu iki tepe arasında yapılır.",
                coordinates: (21.4229, 39.8267)
            )
            
            locationCard(
                name: "Mescid-i Haram",
                description: "Kâbe'yi çevreleyen, dünyanın en büyük mescidi. İçinde Kâbe, Hacer-ül Esved, Makam-ı İbrahim, Zemzem kuyusu ve Safa-Merve tepeleri bulunur.",
                coordinates: (21.4229, 39.8267)
            )
            
            locationCard(
                name: "Mescid-i Nebevi",
                description: "Medine'de bulunan, Hz. Muhammed'in kabri ve mescidi. Hac sonrası genellikle ziyaret edilir (Haccın rüknü değildir).",
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
            
            Text("Ziyaret Adabı")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.top)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("• Kutsal mekanlarda sesli konuşmaktan kaçınılmalıdır.")
                Text("• Fotoğraf çekerken başkalarını rahatsız etmekten sakınılmalıdır.")
                Text("• Özellikle Kâbe ve Ravza-i Mutahhara ziyaretlerinde izdiham oluşturmaktan kaçınılmalıdır.")
                Text("• Her ziyaret yerinin kendine özgü duaları vardır, bunlar okunmalıdır.")
                Text("• Ziyaret esnasında huşu ve saygı içinde olunmalıdır.")
            }
            .font(.body)
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
                title: "İhrama Girme Niyeti ve Telbiye",
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
            
            prayerCard(
                title: "Safa ve Merve Duası",
                arabicText: "إِنَّ الصَّفَا وَالْمَرْوَةَ مِنْ شَعَائِرِ اللَّهِ فَمَنْ حَجَّ الْبَيْتَ أَوِ اعْتَمَرَ فَلا جُنَاحَ عَلَيْهِ أَنْ يَطَّوَّفَ بِهِمَا",
                turkishText: "İnnes-safâ vel-mervete min şeâirillâh. Fe men haccel-beyte ev i'temera felâ cünâha aleyhi en yettavvefe bihimâ.",
                meaning: "Şüphesiz Safa ile Merve, Allah'ın (dininin) nişanelerindendir. Onun için her kim hac ve umre niyetiyle Kâbe'yi ziyaret eder ve onları tavaf ederse, bunda bir günah yoktur."
            )
            
            prayerCard(
                title: "Müzdelife Duası",
                arabicText: "اللَّهُمَّ رَبَّ الْمَشْعَرِ الْحَرَامِ أَعْتِقْ رَقَبَتِي مِنَ النَّارِ وَآمِنِّي مِنْ خَوْفِكَ وَاجْمَعْ لِي خَيْرَ الدُّنْيَا وَالْآخِرَةِ",
                turkishText: "Allahümme Rabbel-Meş'aril-Harâm a'tik rakabetî minen-nâr ve âminnî min havfike vecma' lî hayrad-dünyâ vel-âhirah.",
                meaning: "Ey Meş'ar-i Haram'ın Rabbi olan Allah'ım! Boynumu ateşten azad eyle, beni korkudan emin kıl ve bana dünya ve ahiretin hayırlarını topla."
            )
            
            Divider()
            
            Text("Hac İbadetinde Yapılacak Zikirler")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("• Tekbir: Allahu Ekber (Allah en büyüktür)")
                Text("• Tesbih: Sübhanallah (Allah'ı tüm eksikliklerden tenzih ederim)")
                Text("• Tahmid: Elhamdülillah (Hamd Allah'a mahsustur)")
                Text("• Tehlil: La ilahe illallah (Allah'tan başka ilah yoktur)")
                Text("• İstiğfar: Estağfirullah (Allah'tan bağışlanma dilerim)")
                Text("• Salavat: Allahümme salli ala Muhammed (Allah'ım, Muhammed'e salat eyle)")
            }
            .font(.body)
            
            Text("Önemli Zikirler İçin Sesli Rehberlik")
                .font(.headline)
                .padding(.top)
            
            Button(action: {
                // TODO: Sesli rehberliği başlat
            }) {
                HStack {
                    Image(systemName: "speaker.wave.2.fill")
                    Text("Sesli Dua Rehberini Başlat")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .cornerRadius(8)
            }
            
            Text("Not: Sesli rehberlik, çevrimdışı modda da kullanılabilir.")
                .font(.caption)
                .foregroundStyle(.gray)
        }
    }
    
    private var faqSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sık Sorulan Sorular")
                .font(.title2)
                .fontWeight(.bold)
            
            faqItem(
                question: "Türkiye'den hac başvurusu nasıl yapılır?",
                answer: "Diyanet İşleri Başkanlığı'nın internet sitesinde veya il/ilçe müftülüklerinde hac kayıt dönemlerinde başvuru yapabilirsiniz. Başvurular genellikle kura sistemiyle değerlendirilmektedir. E-Devlet üzerinden de başvuru yapılabilmektedir."
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
            
            faqItem(
                question: "Hac ve umre arasındaki fark nedir?",
                answer: "Hac, belirli bir zamanda (Zilhicce ayının 8-13. günleri) yapılması gereken ve hayatta bir kez farz olan bir ibadettir. Umre ise yılın herhangi bir zamanında yapılabilen ve sünnet olan bir ibadettir. Hac, umreyi de içerir ancak ayrıca Arafat vakfesi ve şeytan taşlama gibi ek ritüeller içerir."
            )
            
            faqItem(
                question: "Hac sırasında Medine ziyareti zorunlu mudur?",
                answer: "Hayır, Medine ziyareti haccın rüknü veya vacip bir parçası değildir. Ancak Hz. Muhammed'in (s.a.v.) kabrini ziyaret etmek manevi açıdan çok değerli görüldüğünden, hac organizasyonları genellikle Medine ziyaretini de içerir."
            )
            
            faqItem(
                question: "Vekalet yoluyla hac yapılabilir mi?",
                answer: "Evet, vefat etmiş kişiler veya sağlık durumu hac yapmaya elvermeyecek derecede kötü olan kişiler adına vekalet yoluyla hac yapılabilir. Bunun için bir başkasını vekil tayin edip gerekli masrafları karşılamak gerekir."
            )
            
            faqItem(
                question: "Hac sırasında şeytan taşlama neden yapılır?",
                answer: "Şeytan taşlama (cemre), Hz. İbrahim'in şeytanı taşlamasını sembolize eder. İbrahim Peygamber'e oğlu İsmail'i kurban etmesi için vesvese vermeye çalışan şeytanı taşladığı rivayet edilir. Bu ritüel, Mina'da bulunan üç cemre noktasında (küçük, orta ve büyük) gerçekleştirilir."
            )
            
            faqItem(
                question: "Hac esnasında yaşlı ve hastalar için kolaylıklar var mıdır?",
                answer: "Evet, yaşlı ve hastalar için çeşitli kolaylıklar sağlanmaktadır. Örneğin, tavaf ve sa'y için tekerlekli sandalye kullanabilirler, şeytan taşlama için vekil tayin edebilirler. Ayrıca özel sağlık hizmetleri ve konaklama imkanları da sunulmaktadır."
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