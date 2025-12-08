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

                // ❗️Енді мұнда admin! ЖОҚ → қауіпсіз
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
                Button("OK", role: .cancel) { }
            } message: {
                Text("Email немесе пароль қате")
            }
        }
    }

    private func login() {
        let req: NSFetchRequest<SchoolAdmin> = SchoolAdmin.fetchRequest()
        req.predicate = NSPredicate(format: "email == %@ AND passwordHash == %@", email, password)

        do {
            let result = try viewContext.fetch(req)
            if let found = result.first {
                self.admin = found
                self.goDashboard = true   // экранға өткіземіз
            } else {
                showError = true
            }
        } catch {
            print("Login error:", error)
            showError = true
        }
    }
}

