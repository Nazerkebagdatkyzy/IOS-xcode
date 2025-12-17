import SwiftUI
import CoreData

struct TeacherLoginView: View {

    @State private var email = ""
    @State private var password = ""
    @State private var showError = false
    @State private var navigate = false
    @State private var animateTitle = false

    @State private var shimmer = false
    @State private var animateLogo = false
    @State private var ripple = false

    @State private var loggedTeacherID: NSManagedObjectID? = nil

    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        NavigationStack {
            ZStack {

                // 🌿 EMERALD BACKGROUND
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(#colorLiteral(red: 0.02, green: 0.20, blue: 0.17, alpha: 1)),
                        Color(#colorLiteral(red: 0.00, green: 0.16, blue: 0.14, alpha: 1))
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 25) {

                    // ============================================================
                    // ⭐ ЛОГОТИП
                    
                    ZStack {

                        // Тыныш фон сақина
                        Circle()
                            .stroke(Color.white.opacity(0.15), lineWidth: 3)
                            .frame(width: 120, height: 120)

                        // ALTYN LOGO — жай тыныс алу
                        Image(systemName: "network")
                            .font(.system(size: 65, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(#colorLiteral(red: 1.0, green: 0.93, blue: 0.70, alpha: 1)),
                                        Color(#colorLiteral(red: 1.0, green: 0.83, blue: 0.46, alpha: 1))
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .scaleEffect(animateLogo ? 1.06 : 1.0)    // басты тыныс алу
                            .opacity(animateLogo ? 1 : 0.88)
                            .shadow(color: .yellow.opacity(0.35), radius: 12)
                            
                    }
                    .frame(height: 140)
                    .onAppear {
                        animateLogo = true     // ТЕК ОСЫ ҚАЖЕТ!
                    }





                    // ============================================================
                    // ⭐ SHIMMER TITLE
                    // ============================================================
                    ZStack {
                        Text("Мұғалім ретінде кіру")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
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

                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.05), Color.white, Color.white.opacity(0.05)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .rotationEffect(.degrees(30))
                            .offset(x: shimmer ? 200 : -200)
                            .blendMode(.overlay)
                            .animation(
                                .linear(duration: 2.2).repeatForever(autoreverses: false),
                                value: shimmer
                            )
                    }
                    .padding(.bottom, 10)
                    

                    // ============================================================
                    // INPUT FIELDS
                    // ============================================================
                    VStack(spacing: 14) {

                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color(#colorLiteral(red: 0.85, green: 1.0, blue: 0.96, alpha: 1)))
                            .cornerRadius(12)

                        SecureField("Құпия сөз", text: $password)
                            .padding()
                            .background(Color(#colorLiteral(red: 0.81, green: 1.0, blue: 0.94, alpha: 1)))
                            .cornerRadius(12)
                    }

                    // ============================================================
                    // LOGIN BUTTON
                    // ============================================================
                    Button(action: loginTeacher) {
                        Text("Кіру")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(#colorLiteral(red: 0.73, green: 0.95, blue: 0.87, alpha: 1)),
                                        Color(#colorLiteral(red: 0.63, green: 0.94, blue: 0.88, alpha: 1))
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(14)
                            .foregroundColor(.black.opacity(0.85))
                    }
                    .padding(.top, 10)

                    if showError {
                        Text("Қате email немесе құпия сөз")
                            .foregroundColor(.red)
                            .font(.subheadline)
                    }

                    Spacer()
                }
                .padding(.horizontal)
            }
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

    // ============================================================
    // LOGIN FUNCTION
    // ============================================================
    func loginTeacher() {
        let normalizedEmail = email
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        let fetch: NSFetchRequest<Teacher> = Teacher.fetchRequest()
        fetch.predicate = NSPredicate(format: "email ==[c] %@", normalizedEmail)

        do {
            let results = try viewContext.fetch(fetch)

            if results.isEmpty { showError = true; return }

            let teacher = results[0]

            if (teacher.passwordHash ?? "") == password {
                loggedTeacherID = teacher.objectID
                navigate = true
            } else {
                showError = true
            }

        } catch {
            showError = true
        }
    }
}

