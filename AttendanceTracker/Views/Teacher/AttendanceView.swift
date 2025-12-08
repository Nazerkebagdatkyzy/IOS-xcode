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
    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var student: Student

    @State private var selectedDate = Date()
    @State private var status: AttendanceStatus = .present
    @State private var note: String = ""
    @State private var existingAttendance: Attendance? = nil
    @State private var showSaved = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Оқушы")) {
                    Text(student.name ?? "")
                        .font(.headline)
                    let num = student.studentNumber
                    Text("№\(num)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                }

                Section(header: Text("Күні мен статус")) {
                    DatePicker("Күн", selection: $selectedDate, displayedComponents: .date)
                    Picker("Статус", selection: $status) {
                        ForEach(AttendanceStatus.allCases, id: \.self) { s in
                            Text(s.display).tag(s)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section(header: Text("Ескертпе (міндетті емес)")) {
                    TextField("Ескертпе", text: $note)
                }

                Section {
                    Button(action: saveAttendance) {
                        Text(existingAttendance == nil ? "Сақтау" : "Жаңарту")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationBarTitle("Attendance", displayMode: .inline)
            .navigationBarItems(leading: Button("Болдырмау") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Өшір") {
                deleteAttendance()
            }.foregroundColor(.red))
            .onAppear(perform: loadExisting)
            .alert(isPresented: $showSaved) {
                Alert(title: Text("Сәтті"), message: Text("Жазба сақталды"), dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                })
            }
        }
    }

    private func startOfDay(for date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }

    private func loadExisting() {
        let req: NSFetchRequest<Attendance> = Attendance.fetchRequest()
        req.predicate = NSPredicate(format: "student == %@ AND date >= %@ AND date < %@",
                                   student,
                                   startOfDay(for: selectedDate) as CVarArg,
                                   Calendar.current.date(byAdding: .day, value: 1, to: startOfDay(for: selectedDate))! as CVarArg)
        req.fetchLimit = 1
        do {
            let arr = try viewContext.fetch(req)
            if let found = arr.first {
                existingAttendance = found
                status = AttendanceStatus(rawValue: found.status ?? "") ?? .present
                note = found.note ?? ""
            }
        } catch {
            print("Failed to fetch existing attendance: \(error)")
        }
    }

    private func saveAttendance() {
        if let att = existingAttendance {
            att.status = status.rawValue
            att.note = note
            att.date = selectedDate
        } else {
            let att = Attendance(context: viewContext)
            att.id = UUID()
            att.date = selectedDate
            att.status = status.rawValue
            att.note = note
            att.student = student
        }

        do {
            try viewContext.save()
            showSaved = true
        } catch {
            print("Save attendance error: \(error)")
        }
    }

    private func deleteAttendance() {
        if let att = existingAttendance {
            viewContext.delete(att)
            do {
                try viewContext.save()
                presentationMode.wrappedValue.dismiss()
            } catch {
                print("Delete attendance error: \(error)")
            }
        } else {
            // nothing to delete
            presentationMode.wrappedValue.dismiss()
        }
    }
}

