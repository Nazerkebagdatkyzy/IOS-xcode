//
//  AdminAddStudentView.swift
//

import SwiftUI
import CoreData

struct AdminAddStudentView: View {

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var classRoom: ClassRoom
    
    @State private var name = ""
    @State private var number = ""
    @State private var showError = false
    
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
                VStack(spacing: 24) {

                    // 🔹 Title
                    Text("Студент қосу")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.black.opacity(0.9))
                        .padding(.top, 10)

                    
                    // 🔹 INPUT FORM CARD
                    VStack(alignment: .leading, spacing: 18) {
                        
                        Text("Аты-жөні")
                            .foregroundColor(.black.opacity(0.7))
                            .font(.headline)

                        TextField("Мысалы: Айым Бағдатқызы", text: $name)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(14)
                            .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                        

                        Text("Нөмірі")
                            .foregroundColor(.black.opacity(0.7))
                            .font(.headline)

                        TextField("Студент нөмірі", text: $number)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(14)
                            .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                    }
                    .padding()
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
                    .padding(.horizontal)


                    // 🔹 SAVE BUTTON
                    Button(action: saveStudent) {
                        Text("Сақтау")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(#colorLiteral(red: 0.20, green: 0.50, blue: 0.40, alpha: 1)))
                            .cornerRadius(18)
                            .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)

                    Spacer()
                }
            }
        }
        .alert("Қате", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Нөмір дұрыс емес немесе бос!")
        }
    }
    
    
    // MARK: - SAVE STUDENT
    private func saveStudent() {
        
        guard !name.isEmpty,
              let num = Int16(number),
              num > 0 else {
            showError = true
            return
        }

        let st = Student(context: viewContext)
        st.id = UUID()
        st.name = name
        st.studentNumber = num
        st.classRoom = classRoom
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Save error:", error)
        }
    }
}

