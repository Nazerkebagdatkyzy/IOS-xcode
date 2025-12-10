import SwiftUI
import CoreData

struct AdminStudentDetailView: View {

    @ObservedObject var student: Student
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {

        ZStack {

            // 🌿 Пастель жасыл фон
            LinearGradient(
                colors: [
                    Color(#colorLiteral(red: 0.78, green: 0.92, blue: 0.88, alpha: 1)),
                    Color(#colorLiteral(red: 0.85, green: 0.96, blue: 0.90, alpha: 1))
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {

                VStack(spacing: 28) {

                    // 🔹 Үлкен жасыл студент иконкасы
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(#colorLiteral(red: 0.20, green: 0.50, blue: 0.40, alpha: 1)))
                            .frame(width: 110, height: 110)
                            .shadow(color: .black.opacity(0.15), radius: 8, y: 4)

                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 50, weight: .bold))
                    }
                    .padding(.top, 20)

                    // 🔹 Student Info Card
                    VStack(alignment: .leading, spacing: 12) {

                        Text(student.name ?? "Аты жоқ")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.black.opacity(0.9))

                        HStack {
                            Text("Нөмірі:")
                                .foregroundColor(.gray)
                            Text("№\(student.studentNumber)")
                                .foregroundColor(.black.opacity(0.8))
                        }

                        if let className = student.classRoom?.name {
                            HStack {
                                Text("Сыныбы:")
                                    .foregroundColor(.gray)
                                Text(className)
                                    .foregroundColor(.black.opacity(0.8))
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(18)
                    .shadow(color: .black.opacity(0.10), radius: 6, y: 4)
                    .padding(.horizontal)

                    Spacer().frame(height: 20)
                }
            }
        }
        .navigationTitle("Студент")
        .navigationBarTitleDisplayMode(.inline)
    }
}
