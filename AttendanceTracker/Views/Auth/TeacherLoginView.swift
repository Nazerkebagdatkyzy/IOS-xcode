import SwiftUI
import CoreData

struct TeacherLoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showError = false
    
    @State private var loggedTeacherID: NSManagedObjectID? = nil
    @State private var navigate = false

    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {

                Text("Мұғалім ретінде кіру")
                    .font(.title2).bold()

                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)

                SecureField("Құпия сөз", text: $password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)

                Button("Кіру") {
                    loginTeacher()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)

                if showError {
                    Text("Қате email немесе құпия сөз").foregroundColor(.red)
                }

                Spacer()
            }
            .padding()
            .navigationDestination(isPresented: $navigate) {
                if let id = loggedTeacherID,
                   let teacher = try? viewContext.existingObject(with: id) as? Teacher {
                    TeacherDashboardView(teacher: teacher)
                } else {
                    Text("Қате! Мұғалім табылмады.")
                }
            }
        }
    }

    func loginTeacher() {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let fetch: NSFetchRequest<Teacher> = Teacher.fetchRequest()
        fetch.predicate = NSPredicate(format: "email ==[c] %@", normalizedEmail)

        do {
            let results = try viewContext.fetch(fetch)
            print("🔍 Found \(results.count) teacher(s) for email '\(normalizedEmail)'")
            if results.isEmpty {
                showError = true
                return
            }

            let teacher = results[0]
            let stored = (teacher.passwordHash ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            let entered = password.trimmingCharacters(in: .whitespacesAndNewlines)
            print("entered='\(entered)', stored='\(stored)'")

            if stored == entered {
                loggedTeacherID = teacher.objectID
                navigate = true
            } else {
                print("Password mismatch")
                showError = true
            }
        } catch {
            print("Fetch error:", error)
            showError = true
        }
    }


}
