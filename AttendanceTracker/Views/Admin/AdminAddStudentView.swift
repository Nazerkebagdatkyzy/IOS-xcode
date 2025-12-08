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
        NavigationView {
            Form {
                Section(header: Text("Студент")) {
                    TextField("Аты-жөні", text: $name)

                    TextField("Нөмірі", text: $number)
                        .keyboardType(.numberPad)
                }

                Button("Сақтау") {
                    saveStudent()
                }
            }
            .navigationTitle("Студент қосу")
            .alert("Қате", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Нөмір дұрыс емес немесе бос!")
            }
        }
    }

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
