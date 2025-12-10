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
            VStack(spacing: 20) {
                
                Text("Admin Login")
                    .font(.largeTitle).bold()
                
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Login") {
                    login()
                }
                .buttonStyle(.borderedProminent)
                
                NavigationLink(isActive: $goDashboard) {
                    if let admin = admin {
                        AdminDashboardView(admin: admin)
                    }
                } label: {
                    EmptyView()
                }
            }
            .padding()
            .alert("Қате", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Email немесе пароль қате")
            }
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
                
                // 1️⃣ Админге тиісті мектепті бекіту
                attachSchoolToAdmin(found)
                
                // 2️⃣ Экранға ауысуды кешіктіріп орындау
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
    // MARK: SCHOOL ATTACH FUNCTION (login-тен ТЫСҚАРЫ)
    // -----------------------------------------------------------
    private func attachSchoolToAdmin(_ admin: SchoolAdmin) {
        
        // Егер school байланысы бар болса — ештеңе істемейміз
        if admin.school != nil { return }
        
        // 1) Алдымен admin.schoolID арқылы іздеу
        if let schoolID = admin.schoolID {
            let req: NSFetchRequest<School> = School.fetchRequest()
            req.predicate = NSPredicate(format: "id == %@", schoolID)
            
            if let schools = try? viewContext.fetch(req),
               let matchedSchool = schools.first {
                
                admin.school = matchedSchool
                try? viewContext.save()
                
                print("🔥 ADMIN CONNECTED TO SCHOOL →", matchedSchool.name ?? "")
                return
            }
        }
        
        // 2) Егер schoolID сәйкес келмесе → fallback (бірінші мектепті алу)
        let req: NSFetchRequest<School> = School.fetchRequest()
        if let schools = try? viewContext.fetch(req),
           let first = schools.first {
            
            admin.school = first
            try? viewContext.save()
            
            print("⚠️ schoolID MATCH ЖОҚ — бірінші мектеп қойылды:", first.name ?? "")
        }
    }
}
