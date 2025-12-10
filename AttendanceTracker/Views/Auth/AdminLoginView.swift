import SwiftUI
import CoreData

struct AdminLoginView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var email = ""
    @State private var password = ""
    
    @State private var admin: SchoolAdmin? = nil
    @State private var goDashboard = false
    @State private var showError = false
    
    var body: some View {
        NavigationStack {
            
            ZStack {
                // 🌑 EMERALD BACKGROUND
                LinearGradient(
                    colors: [
                        Color(#colorLiteral(red: 0.02, green: 0.20, blue: 0.17, alpha: 1)),
                        Color(#colorLiteral(red: 0.00, green: 0.16, blue: 0.14, alpha: 1))
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                
                VStack(spacing: 28) {
                    
                    // --------------------------
                    // TITLE
                    // --------------------------
                    Text("Админ кіру")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(#colorLiteral(red: 1.0, green: 0.96, blue: 0.82, alpha: 1)),
                                    Color(#colorLiteral(red: 1.0, green: 0.88, blue: 0.52, alpha: 1))
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .padding(.top, 20)
                    
                    // --------------------------
                    // EMAIL FIELD
                    // --------------------------
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Email")
                            .foregroundColor(.white.opacity(0.85))
                            .font(.headline)
                        
                        TextField("Email", text: $email)
                            .padding()
                            .background(Color.white.opacity(0.12))
                            .cornerRadius(14)
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
                            )
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                    }
                    .padding(.horizontal)
                    
                    // --------------------------
                    // PASSWORD FIELD
                    // --------------------------
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Құпия сөз")
                            .foregroundColor(.white.opacity(0.85))
                            .font(.headline)
                        
                        SecureField("Құпия сөз", text: $password)
                            .padding()
                            .background(Color.white.opacity(0.12))
                            .cornerRadius(14)
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)
                    
                    
                    // --------------------------
                    // LOGIN BUTTON
                    // --------------------------
                    Button(action: login) {
                        Text("Кіру")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(#colorLiteral(red: 0.71, green: 0.96, blue: 0.87, alpha: 1)),
                                        Color(#colorLiteral(red: 0.63, green: 0.94, blue: 0.88, alpha: 1))
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .foregroundColor(.black.opacity(0.9))
                            .cornerRadius(18)
                            .shadow(color: .black.opacity(0.25), radius: 10, y: 4)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    
                    // --------------------------
                    // NAVIGATION TO DASHBOARD
                    // --------------------------
                    NavigationLink(isActive: $goDashboard) {
                        if let admin = admin {
                            AdminDashboardView(admin: admin)
                        }
                    } label: { EmptyView() }
                    
                    
                    Spacer()
                }
            }
        }
        .alert("Қате", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Email немесе пароль қате")
        }
    }
    
    
    // -----------------------------------------------------------
    // MARK: LOGIN FUNCTION
    // -----------------------------------------------------------
    private func login() {
        let req: NSFetchRequest<SchoolAdmin> = SchoolAdmin.fetchRequest()
        req.predicate = NSPredicate(format: "email == %@ AND passwordHash == %@", email, password)
        
        do {
            let result = try viewContext.fetch(req)
            
            if let found = result.first {
                self.admin = found
                
                attachSchoolToAdmin(found)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.goDashboard = true
                }
                
            } else {
                showError = true
            }
            
        } catch {
            print("Login error:", error)
            showError = true
        }
    }
    
    
    // -----------------------------------------------------------
    // MARK: SCHOOL ATTACH FUNCTION
    // -----------------------------------------------------------
    private func attachSchoolToAdmin(_ admin: SchoolAdmin) {
        
        if admin.school != nil { return }
        
        if let schoolID = admin.schoolID {
            let req: NSFetchRequest<School> = School.fetchRequest()
            req.predicate = NSPredicate(format: "id == %@", schoolID)
            
            if let schools = try? viewContext.fetch(req),
               let matchedSchool = schools.first {
                
                admin.school = matchedSchool
                try? viewContext.save()
                return
            }
        }
        
        let req: NSFetchRequest<School> = School.fetchRequest()
        if let schools = try? viewContext.fetch(req),
           let first = schools.first {
            
            admin.school = first
            try? viewContext.save()
        }
    }
}
