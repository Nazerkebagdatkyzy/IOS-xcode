//
//  AddClassView.swift
//  AttendanceTracker
//
//  Created by Nazerke Bagdatkyzy on 05.12.2025.
//

import SwiftUI
import CoreData

struct AddClassView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var teacher: Teacher

    @State private var className: String = ""
    @State private var showError = false

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("Жаңа сынып қосу")
                    .font(.title2).bold()

                TextField("Сынып атауы (мысалы: 5A)", text: $className)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)

                Button(action: addClass) {
                    Text("Қосу")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(className.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(className.isEmpty)

                if showError {
                    Text("Қате: сыныпты қосу мүмкін болмады")
                        .foregroundColor(.red)
                }

                Spacer()
            }
            .padding()
            .navigationBarTitle("Сынып қосу", displayMode: .inline)
            .navigationBarItems(leading: Button("Болдырмау") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    private func addClass() {
        let newClass = ClassRoom(context: viewContext)
        newClass.id = UUID()
        newClass.name = className.trimmingCharacters(in: .whitespacesAndNewlines)
        newClass.teacher = teacher

        // School relation (if exists)
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

