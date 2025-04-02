import SwiftUI

struct RegisterView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = AuthenticationViewModel()
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showTerms = false
    @State private var acceptedTerms = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Logo
                    Image(systemName: "person.badge.plus")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundStyle(.blue)
                        .padding(.top, 30)
                    
                    Text("Hesap Oluştur")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    // Kayıt Formu
                    VStack(spacing: 15) {
                        TextField("Ad Soyad", text: $fullName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("E-posta", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        
                        TextField("Kullanıcı Adı", text: $username)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                        
                        SecureField("Şifre", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        SecureField("Şifre Tekrar", text: $confirmPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal, 30)
                    
                    // Hata Mesajı
                    if let error = viewModel.error {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                    
                    // Kullanım Şartları
                    Toggle(isOn: $acceptedTerms) {
                        HStack {
                            Text("Kullanım şartlarını")
                            Button("okudum ve kabul ediyorum") {
                                showTerms = true
                            }
                            .foregroundStyle(.blue)
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    // Kayıt Ol Butonu
                    Button(action: {
                        // TODO: Kayıt işlemi
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Kayıt Ol")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(acceptedTerms ? Color.blue : Color.gray)
                    .foregroundStyle(.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 30)
                    .disabled(!acceptedTerms || viewModel.isLoading)
                    
                    // Giriş Yap Bağlantısı
                    HStack {
                        Text("Zaten hesabınız var mı?")
                            .foregroundStyle(.gray)
                        Button("Giriş Yap") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .foregroundStyle(.blue)
                    }
                    .padding(.top, 20)
                }
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundStyle(.blue)
            })
        }
        .sheet(isPresented: $showTerms) {
            TermsView()
        }
    }
}

struct TermsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Kullanım Şartları")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.bottom)
                    
                    Text("1. Genel Hükümler")
                        .font(.headline)
                    Text("Bu uygulamayı kullanarak aşağıdaki şartları kabul etmiş olursunuz...")
                        .padding(.bottom)
                    
                    Text("2. Gizlilik Politikası")
                        .font(.headline)
                    Text("Kişisel verileriniz 6698 sayılı KVKK kapsamında korunmaktadır...")
                        .padding(.bottom)
                    
                    Text("3. Sorumluluk Reddi")
                        .font(.headline)
                    Text("Uygulama içeriğinin doğruluğu ve güncelliği konusunda...")
                }
                .padding()
            }
            .navigationBarTitle("Kullanım Şartları", displayMode: .inline)
            .navigationBarItems(trailing: Button("Kapat") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
} 