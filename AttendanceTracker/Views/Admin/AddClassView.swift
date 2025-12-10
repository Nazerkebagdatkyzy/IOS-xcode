import SwiftUI
import CoreData

struct AddClassView: View {

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var teacher: Teacher

    @State private var className: String = ""
    @State private var showError = false

    var body: some View {

        ZStack {
            // EMERALD BACKGROUND
            LinearGradient(
                colors: [
                    Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)),
                    Color(#colorLiteral(red: 0, green: 0.7932468057, blue: 0.6917395592, alpha: 1))
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 26) {

                // TITLE
                Text("Жаңа сынып қосу")
                    .font(.system(size: 28, weight: .bold))
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

                // INPUT FIELD
                VStack(alignment: .leading, spacing: 6) {
                    Text("Сынып атауы")
                        .foregroundColor(.white.opacity(0.85))
                        .font(.headline)

                    TextField("Мысалы: 5A", text: $className)
                        .padding()
                        .background(Color.white.opacity(0.12))
                        .cornerRadius(14)
                        .foregroundColor(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                }
                .padding(.horizontal)

                // SUBMIT BUTTON
                Button(action: addClass) {
                    Text("Қосу")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        // --------- FIXED: use AnyView to keep ternary branches same type ----------
                        .background(
                            className.isEmpty
                            ? AnyView(Color.gray.opacity(0.4))
                            : AnyView(
                                LinearGradient(
                                    colors: [
                                        Color(#colorLiteral(red: 0.71, green: 0.96, blue: 0.87, alpha: 1)),
                                        Color(#colorLiteral(red: 0.63, green: 0.94, blue: 0.88, alpha: 1))
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        )
                        .foregroundColor(.black.opacity(className.isEmpty ? 0.4 : 0.9))
                        .cornerRadius(18)
                        .shadow(color: .black.opacity(0.25), radius: 10, y: 4)
                }
                .disabled(className.isEmpty)
                .padding(.horizontal)

                if showError {
                    Text("Қате: сыныпты қосу мүмкін болмады")
                        .foregroundColor(.red)
                        .padding(.top, -10)
                }

                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // CANCEL BUTTON
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Болдырмау") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white.opacity(0.9))
            }
        }
    }

    // MARK: – SAVE NEW CLASS
    private func addClass() {
        let newClass = ClassRoom(context: viewContext)
        newClass.id = UUID()
        newClass.name = className.trimmingCharacters(in: .whitespacesAndNewlines)
        newClass.teacher = teacher

        if let school = teacher.school {
            newClass.school = school
        }

        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Failed to save class: \(error)")
            showError = true
        }
    }
}
