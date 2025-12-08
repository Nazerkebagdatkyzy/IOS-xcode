//
//  AdminAddTeacherView.swift
//  AttendanceTracker
//
//  Created by Nazerke Bagdatkyzy on 05.12.2025.
//
import SwiftUI
import CoreData


struct AdminAddTeacherView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var saved = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Аты-жөні")) {
                    TextField("Аты", text: $name)
                }
                Section(header: Text("Email")) {
                    TextField("Email", text: $email)
                }
                Section(header: Text("Құпия сөз")) {
                    SecureField("Password", text: $password)
                }

                Button("Сақтау") {
                    let t = Teacher(context: viewContext)
                    t.id = UUID()
                    t.name = name
                    t.email = email
                    t.passwordHash = password
                    try? viewContext.save()
                    saved = true
                }
            }
            .navigationTitle("Мұғалім қосу")
            .alert(isPresented: $saved) {
                Alert(title: Text("Сақталды"), message: Text("Жаңа мұғалім қосылды"), dismissButton: .default(Text("OK")))
            }
        }
    }
}

