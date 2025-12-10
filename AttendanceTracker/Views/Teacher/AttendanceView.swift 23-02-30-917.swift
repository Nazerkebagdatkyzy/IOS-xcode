//
//  AttendanceView.swift
//  AttendanceTracker
//
//  Created by Nazerke Bagdatkyzy on 05.12.2025.
//
import SwiftUI
import CoreData

enum AttendanceStatus: String, CaseIterable {
    case present = "present"
    case absent = "absent"
    case late = "late"

    var display: String {
        switch self {
        case .present: return "Келді"
        case .absent: return "Келмеді"
        case .late: return "Кешікті"
        }
    }
}

struct AttendanceView: View {

    @Environment(\.managedObjectContext) private var viewContext

    let student: Student
    let classRoom: ClassRoom   // ← МІНДЕТТІ ТҮРДЕ ОСЫ ЖЕРДЕ ТҰРУ КЕРЕК !!!

    @State private var selectedDate = Date()
    @State private var isPresent: Bool = true     // ← МІНДЕТТІ
    @State private var existingAttendance: Attendance?

    @State private var showSaved = false

    var body: some View {
        Form {
            Section("Оқушы") {
                Text(student.name ?? "Аты жоқ")
            }

            Section("Дата") {
                DatePicker("Күні", selection: $selectedDate, displayedComponents: .date)
                    .onChange(of: selectedDate) { _ in
                        loadExisting()
                    }
            }

            Section("Қатысу") {
                Toggle("Қатысты", isOn: $isPresent)
                    .toggleStyle(SwitchToggleStyle(tint: .green))
            }

            Button("Сақтау") {
                saveAttendance()
            }
            .buttonStyle(.borderedProminent)
        }
        .onAppear {
            loadExisting()
        }
        .alert("Сақталды!", isPresented: $showSaved) {
            Button("OK") { }
        }
    }

    // MARK: -------------------------
    // MARK: LOAD EXISTING
    // ------------------------------
    private func loadExisting() {
        let req: NSFetchRequest<Attendance> = Attendance.fetchRequest()
        req.predicate = NSPredicate(
            format: "student == %@ AND classRoom == %@ AND date == %@",
            student, classRoom, selectedDate as NSDate
        )

        do {
            let arr = try viewContext.fetch(req)
            if let found = arr.first {
                existingAttendance = found
                isPresent = found.isPresent   // ← Attendance ішіндегі ФАКТІКАЛЫ ӨРІС
            }
        } catch {
            print("Failed to load existing attendance:", error)
        }
    }

    // MARK: -------------------------
    // MARK: SAVE
    // ------------------------------
    private func saveAttendance() {

        if let att = existingAttendance {
            // update
            att.date = selectedDate
            att.isPresent = isPresent

        } else {
            // create new
            let att = Attendance(context: viewContext)
            att.id = UUID()
            att.date = selectedDate
            att.isPresent = isPresent
            att.student = student
            att.classRoom = classRoom
        }

        do {
            try viewContext.save()
            showSaved = true
        } catch {
            print("Save error:", error)
        }
    }
}
