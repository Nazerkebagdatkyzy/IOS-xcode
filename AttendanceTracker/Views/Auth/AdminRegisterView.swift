import SwiftUI
import CoreData

struct AdminRegisterView: View {

    @Environment(\.managedObjectContext) private var viewContext

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var selectedSchool: School? = nil
    
    @State private var success = false
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \School.name, ascending: true)]
    ) private var schools: FetchedResults<School>
    
    var body: some View {
        Form {
            
            Section("Админ туралы") {
                TextField("Аты", text: $name)
                TextField("Email", text: $email)
                SecureField("Пароль", text: $password)
            }
            
            Section("Мектеп таңдау") {
                Picker("Мектеп", selection: $selectedSchool) {
                    ForEach(schools) { school in
                        Text(school.name ?? "Атауы жоқ")
                            .tag(Optional(school))
                    }
                }
                
                if let s = selectedSchool {
                    Text("Таңдалған мектеп: \(s.name ?? "")")
                        .foregroundColor(.green)
                }
            }
            
            Button("Админді тіркеу") {
                registerAdmin()
            }
            .disabled(selectedSchool == nil)
        }
        .navigationTitle("Админ тіркелу")
        .alert("Сәтті тіркелді!", isPresented: $success) {
            Button("OK") {}
        }
    }
    
    private func registerAdmin() {
        guard let school = selectedSchool else { return }
        
        let admin = SchoolAdmin(context: viewContext)
        admin.id = UUID()   // ← енді бәрі дұрыс!
        admin.name = name
        admin.email = email
        admin.passwordHash = password
        
        // 🟩 МІНЕ ЕҢ МАҢЫЗДЫ ЖЕР:
        admin.schoolID = school.id                 // schoolID САҚТАЛАДЫ!!!
        admin.school = school                      // relationship САҚТАЛАДЫ!!!
        
        try? viewContext.save()
        success = true
        
        print("🎉 NEW ADMIN CREATED")
        print("Admin schoolID:", admin.schoolID ?? "none")
        print("Admin linked school:", admin.school?.name ?? "nil")
    }
}
