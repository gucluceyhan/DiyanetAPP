import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @State private var username = ""
    @State private var password = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Logo
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundStyle(.blue)
                    .padding(.bottom, 30)
                
                // Giriş Formu
                VStack(spacing: 15) {
                    TextField("Kullanıcı Adı", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                    
                    SecureField("Şifre", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal, 30)
                
                // Hata Mesajı
                if let error = viewModel.error {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.caption)
                }
                
                // Giriş Butonu
                Button(action: {
                    viewModel.login(username: username, password: password)
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Giriş Yap")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundStyle(.white)
                .cornerRadius(10)
                .padding(.horizontal, 30)
                .disabled(viewModel.isLoading)
                
                // E-Devlet ile Giriş
                Button(action: {
                    // TODO: E-Devlet ile giriş işlemi
                }) {
                    HStack {
                        Image("e-devlet-logo") // E-Devlet logosu asset olarak eklenecek
                            .resizable()
                            .frame(width: 24, height: 24)
                        Text("E-Devlet ile Giriş Yap")
                            .fontWeight(.medium)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .foregroundStyle(.blue)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue, lineWidth: 1)
                )
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Yardım Bağlantıları
                VStack(spacing: 10) {
                    Button("Şifremi Unuttum") {
                        // TODO: Şifre sıfırlama işlemi
                    }
                    .foregroundStyle(.gray)
                    
                    HStack {
                        Text("Hesabınız yok mu?")
                            .foregroundStyle(.gray)
                        Button("Kayıt Ol") {
                            // TODO: Kayıt olma sayfasına yönlendirme
                        }
                        .foregroundStyle(.blue)
                    }
                }
            }
            .padding(.vertical, 30)
            .navigationBarHidden(true)
        }
    }
} 