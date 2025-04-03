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
                        .foregroundStyle(Color.accentColor)
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
            Text("Kudüs Hakkında")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Kudüs (Arapça: القدس el-Kuds, İbranice: ירושלים Yeruşalayim), üç semavi din için kutsal kabul edilen, zengin tarihi ve kültürel mirası ile dünya tarihinin en önemli şehirlerinden biridir.")
                .font(.body)
            
            Divider()
            
            Text("Kudüs'ün Önemi")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                importanceItem(
                    title: "İslam'daki Yeri",
                    description: "Müslümanlar için Mekke ve Medine'den sonra üçüncü kutsal şehirdir. Mescid-i Aksa ve Kubbet-üs Sahra burada bulunur. İsra ve Miraç olayının gerçekleştiği yerdir. İlk kıble olma özelliğini taşır."
                )
                
                importanceItem(
                    title: "Yahudilikteki Yeri",
                    description: "Yahudiler için en kutsal şehirdir. Hz. Süleyman'ın inşa ettiği ve sonradan yıkılan mabedin (Süleyman Tapınağı) bulunduğu yerdir. Ağlama Duvarı (Batı Duvarı) kutsal kabul edilir."
                )
                
                importanceItem(
                    title: "Hristiyanlıktaki Yeri",
                    description: "Hz. İsa'nın çarmıha gerildiği, gömüldüğü ve dirildiğine inanılan Kutsal Kabir Kilisesi burada bulunur. Hristiyanlığın doğduğu şehir olarak kabul edilir."
                )
            }
            
            Divider()
            
            Text("Coğrafi Konumu ve İklimi")
                .font(.headline)
            
            Text("Kudüs, Akdeniz'in doğusunda, deniz seviyesinden yaklaşık 750 metre yükseklikte yer alır. Şehir, Filistin topraklarında bulunmakla birlikte, siyasi olarak İsrail tarafından işgal edilmiştir ve Doğu Kudüs, Filistin Devleti'nin başkenti olarak kabul edilmektedir.")
                .font(.body)
                .padding(.bottom, 4)
            
            Text("İklimi Akdeniz iklimidir; yazları sıcak ve kurak, kışları ılık ve yağışlıdır. En uygun ziyaret zamanı ilkbahar (Mart-Mayıs) ve sonbahar (Eylül-Kasım) mevsimleridir.")
                .font(.body)
                .padding(.bottom, 8)
            
            Text("Nüfus: Yaklaşık 950.000")
                .font(.body)
            
            Divider()
            
            Text("Kudüs'ün Kısa Tarihi")
                .font(.headline)
            
            historicalEvent(date: "MÖ 1000 civarı", event: "Hz. Davud tarafından başkent ilan edildi.")
            historicalEvent(date: "MÖ 970-931", event: "Hz. Süleyman döneminde ilk mabed inşa edildi.")
            historicalEvent(date: "MÖ 586", event: "Babil Kralı Nebukadnezar tarafından işgal edildi ve Süleyman Mabedi yıkıldı.")
            historicalEvent(date: "MS 70", event: "Romalılar tarafından işgal edildi ve İkinci Mabed yıkıldı.")
            historicalEvent(date: "MS 637", event: "Hz. Ömer döneminde Müslümanların idaresine geçti.")
            historicalEvent(date: "MS 691", event: "Emevi Halifesi Abdülmelik tarafından Kubbet-üs Sahra inşa edildi.")
            historicalEvent(date: "MS 1099-1187", event: "Haçlı işgali altında kaldı.")
            historicalEvent(date: "MS 1187", event: "Selahaddin Eyyubi tarafından Haçlılardan geri alındı.")
            historicalEvent(date: "1517-1917", event: "Osmanlı İmparatorluğu yönetiminde kaldı.")
            historicalEvent(date: "1917-1948", event: "İngiliz mandası altında kaldı.")
            historicalEvent(date: "1948", event: "İsrail kuruldu ve Kudüs bölündü.")
            historicalEvent(date: "1967", event: "Altı Gün Savaşı sonrası tamamen İsrail işgaline girdi.")
            
            Text("Günümüzde Kudüs, doğu ve batı olarak bölünmüş durumdadır ve uluslararası toplum tarafından statüsü tartışmalı bir şehirdir.")
                .font(.body)
                .padding(.top, 8)
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
            Text("Kutsal Mekânlar")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Kudüs'te ziyaret edilmesi gereken önemli mekânlar:")
                .font(.headline)
            
            holyPlaceCard(
                name: "Mescid-i Aksa",
                description: "İslam'ın ilk kıblesi ve üç kutsal mescidinden biridir. Hz. Muhammed'in (s.a.v.) İsra ve Miraç yolculuğu sırasında namaz kıldığı yerdir.",
                importance: "Peygamber Efendimizin bildirdiğine göre, Mescid-i Aksa'da kılınan bir namaz, başka mescitlerde kılınan 250 namaza denktir.",
                visitTips: "Cuma namazı için erkenden gidin. Kadınlar için başörtüsü gereklidir. Kimlik kontrolü olacağından pasaportunuzu yanınızda bulundurun."
            )
            
            holyPlaceCard(
                name: "Kubbet-üs Sahra (Altın Kubbe)",
                description: "Hz. Muhammed'in (s.a.v.) miraca yükseldiğine inanılan Muallak Taşı'nın üzerine inşa edilmiş olan muhteşem yapıdır. Altın kubbesi ile Kudüs'ün simgesidir.",
                importance: "İçinde Hacer-ül Muallak (Muallak Taşı) bulunur. İslam mimarisinin en önemli eserlerinden biridir.",
                visitTips: "Ziyaretlerde saygılı olun ve sessiz kalın. Ayakkabılarınızı girişte çıkarmanız gerekecektir."
            )
            
            holyPlaceCard(
                name: "El-Burak Duvarı (Ağlama Duvarı)",
                description: "Müslümanlar için Hz. Muhammed'in (s.a.v.) Burak'ı bağladığı duvar, Yahudiler için ise İkinci Mabed'den kalan son kalıntıdır.",
                importance: "Harem-i Şerif'in batı duvarıdır ve Müslümanlar için kutsal bir alandır.",
                visitTips: "Ziyaret sırasında saygılı olun. Bazı bölümlere giriş için başörtüsü gerekebilir."
            )
            
            holyPlaceCard(
                name: "Kutsal Kabir Kilisesi",
                description: "Hristiyanlar için Hz. İsa'nın çarmıha gerildiği, gömüldüğü ve dirildiğine inanılan yerdir.",
                importance: "Hristiyanlığın en kutsal mekânlarından biridir ve farklı Hristiyan mezhepleri tarafından ortak kullanılır.",
                visitTips: "Kalabalık olabilir, mümkünse sabah erken saatlerde ziyaret edin. Uygun kıyafet gereklidir (omuzlar ve dizler kapalı)."
            )
            
            holyPlaceCard(
                name: "Hz. Davud'un Türbesi",
                description: "Hz. Davud'un (a.s.) medfun olduğuna inanılan türbedir.",
                importance: "Hem Müslümanlar hem de Yahudiler için önemli bir ziyaret yeridir.",
                visitTips: "Erkekler için başlık (kipa) gerekebilir. Giriş için bilet almanız gerekebilir."
            )
            
            holyPlaceCard(
                name: "Zeytin Dağı",
                description: "Kudüs'ün doğusunda yer alan, şehrin en güzel manzarasını sunan tarihi tepedir.",
                importance: "İslam inancına göre kıyamet günü Hz. İsa'nın ineceği yer olarak kabul edilir.",
                visitTips: "Güneşli günlerde şapka ve su götürün. Manzara fotoğrafları için ideal bir noktadır."
            )
            
            holyPlaceCard(
                name: "Hz. Meryem Türbesi",
                description: "Hz. Meryem'in medfun olduğuna inanılan türbedir.",
                importance: "Hem Müslümanlar hem de Hristiyanlar için önemli bir ziyaret yeridir.",
                visitTips: "Kadınlar için başörtüsü tavsiye edilir. Ziyaret için uygun saatleri kontrol edin."
            )
            
            Divider()
            
            Text("Mescid-i Aksa Kompleksi")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("Mescid-i Aksa, sadece bilinen gri kubbeli mescidi değil, yaklaşık 144 dönümlük bir alanı kapsayan Harem-i Şerif'in (Kutsal Alan) tamamını ifade eder. Bu kompleks içinde:")
                .font(.body)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("• Kubbet-üs Sahra (Altın Kubbe)")
                Text("• Kıble Mescidi (gri kubbeli ana mescit)")
                Text("• Kadim el-Aksa (yer altındaki eski mescit)")
                Text("• Mervan Mescidi")
                Text("• Burak Duvarı")
                Text("• Kubbetü'l Miraç")
                Text("• Kubbetü's Silsile (Zincirli Kubbe)")
                Text("• Sebil-i Kaytbay")
                Text("• Çeşitli medreseler ve revaklar")
            }
            .font(.body)
            .padding(.horizontal)
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
            
            Text("Kudüs'e Giriş")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("• Türkiye'den Kudüs'e direkt uçuş bulunmamaktadır. Tel Aviv'e uçup oradan kara yoluyla Kudüs'e geçiş yapılmalıdır.")
                Text("• Türk vatandaşları İsrail'e giriş için vize almalıdır.")
                Text("• Havalimanında ve sınır kapılarında detaylı güvenlik kontrollerinden geçeceğinizi unutmayın.")
                Text("• Türkiye'den organize turla gitmek, vize ve ulaşım işlemlerini kolaylaştırabilir.")
                Text("• Tel Aviv'den Kudüs'e otobüs veya servis araçlarıyla yaklaşık 1 saat içinde ulaşabilirsiniz.")
            }
            .font(.body)
            
            Divider()
            
            Text("Ziyaret İçin En Uygun Zamanlar")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("• İlkbahar (Mart-Mayıs): Ilıman hava, doğanın canlanması")
                Text("• Sonbahar (Eylül-Kasım): Sıcakların azaldığı, rahat gezilecek dönem")
                Text("• Dini bayram ve tatillerden kaçının (Yahudi tatilleri, Ramazan veya Paskalya gibi)")
                Text("• Cuma namazı için Mescid-i Aksa'da bulunmak istiyorsanız, Perşembe-Cuma günlerini kapsayan bir program planlayın")
            }
            .font(.body)
            
            Divider()
            
            Text("Güvenlik ve Dikkat Edilecek Hususlar")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("• Pasaport ve değerli eşyalarınızı güvenli bir şekilde yanınızda taşıyın.")
                Text("• İsrail güvenlik güçleriyle tartışmaya girmekten kaçının.")
                Text("• Siyasi gösteri ve kalabalıklardan uzak durun.")
                Text("• Yerel haberleri takip edin ve güvenlik durumunu kontrol edin.")
                Text("• Acil durumlar için Türkiye'nin Kudüs Başkonsolosluğu'nun iletişim bilgilerini kaydedin.")
                Text("• Kudüs'ün Doğu ve Batı kısımları arasında geçişlerde kontrol noktaları olabileceğini unutmayın.")
                Text("• Kutsal mekânlara girerken uygun kıyafet giyin (omuzlar ve dizler kapalı olmalı).")
                Text("• Fotoğraf çekerken izin gereken yerlere dikkat edin, özellikle askeri noktalarda fotoğraf çekmekten kaçının.")
            }
            .font(.body)
            
            Divider()
            
            Text("Konaklama ve Ulaşım")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("• Konaklama için Doğu Kudüs'teki otelleri tercih edebilirsiniz (Arap mahallesi).")
                Text("• Şehir içi ulaşımda tramvay, otobüs ve taksi kullanabilirsiniz.")
                Text("• Eski Şehir (Old City) içindeki mesafeler yürüme mesafesindedir.")
                Text("• Cuma günleri ve Yahudi tatillerinde toplu taşıma hizmetlerinin sınırlı olabileceğini göz önünde bulundurun.")
                Text("• Para birimi olarak İsrail Şekeli (ILS) kullanılır. Yanınızda dolar veya euro bulundurmak faydalı olabilir.")
            }
            .font(.body)
            
            Divider()
            
            Text("Gezilecek Diğer Yerler")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("• Eski Şehir Surları ve Kapıları: Şam Kapısı, Yafa Kapısı, El-Halil Kapısı")
                Text("• Via Dolorosa (Çile Yolu): Hz. İsa'nın çarmıha giderken yürüdüğü yol")
                Text("• El-Halil Caddesi: Meşhur çarşı ve alışveriş bölgesi")
                Text("• Yad Vashem: Holokost Anıtı")
                Text("• İsrail Müzesi: Ölü Deniz Yazmaları'nın sergilendiği müze")
                Text("• Zeytin Dağı Mezarlığı")
                Text("• Getsemani Bahçesi")
                Text("• Beytüllahim (Bethlehem): Hz. İsa'nın doğduğu yer (yaklaşık 10 km uzaklıkta)")
                Text("• El-Halil (Hebron): Hz. İbrahim'in mezarının bulunduğu yer (yaklaşık 30 km uzaklıkta)")
            }
            .font(.body)
        }
    }
    
    private var prayersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Dualar ve Manevi Rehberlik")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Mescid-i Aksa'da Okunabilecek Dualar")
                .font(.headline)
            
            prayerCard(
                title: "Mescid-i Aksa'ya Giriş Duası",
                arabicText: "بِسْمِ اللهِ وَالصَّلَاةُ وَالسَّلَامُ عَلَى رَسُولِ اللهِ، اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ",
                turkishText: "Bismillâhi ves-salâtü ves-selâmü alâ Rasûlillâh. Allâhümmeftah lî ebvâbe rahmetik.",
                meaning: "Allah'ın adıyla ve Allah'ın Rasûlü'ne salât ve selam olsun. Allah'ım, bana rahmet kapılarını aç."
            )
            
            prayerCard(
                title: "Mescid-i Aksa'da Namaz Duası",
                arabicText: "اللَّهُمَّ إِنِّي أَسْأَلُكَ فِي هَذَا الْبَلَدِ الْمُقَدَّسِ وَالْمَسْجِدِ الْأَقْصَى الْمُبَارَكِ أَنْ تَغْفِرَ لِي ذُنُوبِي وَأَنْ تَكْتُبَنِي مِنْ عِبَادِكَ الصَّالِحِينَ",
                turkishText: "Allâhümme innî es'elüke fî hâzel-beledil-mukaddesi vel-mescidil-aksâl-mübâraki en tağfira lî zünûbî ve en tektübenî min ibâdikes-sâlihîn.",
                meaning: "Allah'ım! Bu kutsal beldede ve mübarek Mescid-i Aksa'da Senden günahlarımı bağışlamanı ve beni salih kulların arasına yazmanı diliyorum."
            )
            
            prayerCard(
                title: "Kubbet-üs Sahra Duası",
                arabicText: "اللَّهُمَّ يَا مُنَزِّلَ الْكِتَابِ، وَيَا مُجْرِيَ السَّحَابِ، وَيَا هَازِمَ الْأَحْزَابِ، اهْزِمْهُمْ وَانْصُرْنَا عَلَيْهِمْ",
                turkishText: "Allâhümme yâ münezzilel-kitâbi, ve yâ mücriyes-sehâbi, ve yâ hâzimel-ahzâbi, ihzimhüm vensurnâ aleyhim.",
                meaning: "Ey kitabı indiren, bulutları yürüten ve düşman topluluklarını bozguna uğratan Allah'ım! Onları bozguna uğrat ve bize onlara karşı yardım et."
            )
            
            prayerCard(
                title: "Kudüs İçin Dua",
                arabicText: "اللَّهُمَّ احْفَظْ الْقُدْسَ وَأَهْلَهَا، وَانْصُرْ الْمُرَابِطِينَ فِيهَا، وَاجْعَلْهَا آمِنَةً مُطْمَئِنَّةً، وَاجْمَعْنَا فِيهَا تَحْتَ رَايَةِ الْحَقِّ",
                turkishText: "Allâhümmahfazil-Kudse ve ehlehâ, vensurül-murâbitîne fîhâ, vec'alhâ âmineten mutmainneten, vecme'nâ fîhâ tahte râyetil-hakk.",
                meaning: "Allah'ım! Kudüs'ü ve halkını koru, orada nöbet tutanları muzaffer kıl, orayı güvenli ve huzurlu eyle, bizleri orada hak bayrağı altında bir araya getir."
            )
            
            Divider()
            
            Text("Mescid-i Aksa'da Kılınacak Namazın Fazileti")
                .font(.headline)
            
            Text("Hz. Muhammed (s.a.v.) şöyle buyurmuştur: \"Mescid-i Aksa'da kılınan bir namaz, başka mescitlerde kılınan bin namaza denktir.\" (Taberânî)")
                .font(.body)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            Divider()
            
            Text("Mescid-i Aksa'ya Yolculuk Adabı")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("• Yolculuk öncesi tövbe ve istiğfar et.")
                Text("• Kudüs'e ziyaret niyetiyle çıktığın yolculuğun bir ibadet olduğunu hatırla.")
                Text("• Mescid-i Aksa'da en az iki rekat namaz kılmayı niyet et.")
                Text("• Yolculuk sırasında çokça dua ve zikir ile meşgul ol.")
                Text("• Orada rastladığın Müslümanlara selam ver ve onlarla iyi ilişkiler kur.")
                Text("• Kudüs ve Mescid-i Aksa'nın tarihini öğren.")
                Text("• Mescid-i Aksa'da ibadete özen göster ve vakti değerlendir.")
                Text("• Mescid-i Aksa'da ve Kudüs'teki diğer kutsal mekanlarda uygun davranışlarda bulun.")
            }
            .font(.body)
            
            Divider()
            
            Text("Kudüs Ziyareti İçin Önerilen Zikirler")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("• Subhanallah (33 kez)")
                Text("• Elhamdülillah (33 kez)")
                Text("• Allahu Ekber (34 kez)")
                Text("• La ilahe illallah")
                Text("• İstiğfar: Estağfirullah el-azim ve etûbü ileyh")
                Text("• Salavat-ı Şerife")
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
                question: "Türkiye'den Kudüs'e nasıl gidilir?",
                answer: "Türkiye'den doğrudan Kudüs'e uçuş bulunmamaktadır. Tel Aviv'e uçuş yapıp, oradan kara yoluyla Kudüs'e ulaşabilirsiniz. Alternatif olarak, Ürdün üzerinden de Kudüs'e geçiş yapılabilir. Organize turlar, vize ve ulaşım işlemlerini kolaylaştırabilir."
            )
            
            faqItem(
                question: "Kudüs'e girmek için vize gerekiyor mu?",
                answer: "Evet, Türk vatandaşları için İsrail vizesi gereklidir. Vize başvurusu İsrail'in Türkiye'deki büyükelçiliği veya konsolosluğu aracılığıyla yapılabilir. Grup turları için genellikle seyahat acenteleri vize işlemlerinde yardımcı olur."
            )
            
            faqItem(
                question: "Mescid-i Aksa'ya giriş için özel izin gerekir mi?",
                answer: "Bazen güvenlik durumuna bağlı olarak Mescid-i Aksa'ya giriş sınırlandırılabilir. Müslümanlar için genellikle namaz vakitlerinde giriş daha kolaydır. Kudüs'e gitmeden önce güncel durumu kontrol etmeniz önerilir."
            )
            
            faqItem(
                question: "Kudüs'te konaklama için en iyi bölge neresidir?",
                answer: "Müslümanlar için Doğu Kudüs'teki Arap mahallelerinde (özellikle Eski Şehir yakınlarında) konaklama tercih edilebilir. Bu bölgeler Mescid-i Aksa'ya daha yakındır ve Müslüman nüfus yoğunluktadır."
            )
            
            faqItem(
                question: "Kudüs'te para birimi nedir ve kredi kartı kullanılabilir mi?",
                answer: "Kudüs'te İsrail Şekeli (ILS) kullanılmaktadır. Büyük işletmelerde kredi kartları genellikle kabul edilir, ancak küçük dükkanlarda ve pazarlarda nakit para bulundurmak daha güvenlidir. Dolar ve Euro kolaylıkla bozulabilir."
            )
            
            faqItem(
                question: "Mescid-i Aksa kompleksi ne kadar büyüktür?",
                answer: "Mescid-i Aksa, yaklaşık 144 dönümlük (35 acre) bir alanı kaplayan Harem-i Şerif (Kutsal Alan) olarak bilinen bölgenin tamamını kapsar. Bu alan içinde Kubbet-üs Sahra, Kıble Mescidi (gri kubbeli ana mescit) ve diğer birçok yapı bulunur."
            )
            
            faqItem(
                question: "Kudüs'te hangi diller konuşulur?",
                answer: "Kudüs'te ağırlıklı olarak İbranice ve Arapça konuşulur. Batı Kudüs'te İbranice, Doğu Kudüs'te Arapça daha yaygındır. Turistik alanlarda İngilizce de yaygın olarak kullanılmaktadır."
            )
            
            faqItem(
                question: "Kudüs'te giyim konusunda dikkat edilmesi gereken hususlar nelerdir?",
                answer: "Kutsal mekânları ziyaret ederken muhafazakâr giyinmek önemlidir. Erkekler ve kadınlar için omuzlar ve dizler kapalı olmalıdır. Mescid-i Aksa'ya girerken kadınların başörtüsü takması gerekir. Yahudi mahallelerinde de dikkatli olmak ve muhafazakâr giyinmek gereklidir."
            )
            
            faqItem(
                question: "Kudüs'te dini açıdan hassas olan bölgeler nelerdir?",
                answer: "Eski Şehir'deki dört mahalle (Müslüman, Yahudi, Hristiyan ve Ermeni Mahallesi) dini açıdan hassas bölgelerdir. Özellikle Mescid-i Aksa/Tapınak Tepesi, Ağlama Duvarı ve Kutsal Kabir Kilisesi çevresinde farklı dinlere saygılı olmak ve provokasyondan kaçınmak önemlidir."
            )
            
            faqItem(
                question: "Kudüs ziyareti için en uygun zaman nedir?",
                answer: "İlkbahar (Mart-Mayıs) ve sonbahar (Eylül-Kasım) mevsimleri, ılıman hava şartları nedeniyle Kudüs ziyareti için en uygun zamanlardır. Yaz ayları çok sıcak, kış ayları ise yağışlı ve bazen karlı olabilir. Dini bayram ve tatil dönemlerinde şehir çok kalabalık olabilir."
            )
        }
    }
    
    // MARK: - Helper Views
    
    private func importanceCard(title: String, description: String, iconName: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: iconName)
                .font(.title2)
                .foregroundStyle(Color.accentColor)
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
    
    private func holyPlaceCard(name: String, description: String, importance: String, visitTips: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(name)
                .font(.headline)
            
            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(Color.yellow)
                    
                    Text("Önemi: \(importance)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                HStack(alignment: .top) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(Color.yellow)
                    
                    Text("Ziyaret İpucu: \(visitTips)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 2)
    }
    
    private func historicalEvent(date: String, event: String) -> some View {
        HStack(alignment: .top) {
            Text(date)
                .font(.subheadline)
                .fontWeight(.semibold)
                .frame(width: 90, alignment: .leading)
            
            Text(event)
                .font(.subheadline)
        }
        .padding(.vertical, 2)
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
    
    private func importanceItem(title: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            
            Text(description)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
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