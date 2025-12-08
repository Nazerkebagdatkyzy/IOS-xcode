import SwiftUI
import CoreData

struct StudentDetailView: View {
    @ObservedObject var student: Student
    @Environment(\.managedObjectContext) private var viewContext

    @State private var selectedDate = Date()
    @State private var present = true
    
    @FetchRequest var records: FetchedResults<Attendance>

        init(student: Student) {
            self.student = student

            // Тек осы студентке тиесілі қатысулар
            _records = FetchRequest<Attendance>(
                sortDescriptors: [NSSortDescriptor(keyPath: \Attendance.date, ascending: true)],
                predicate: NSPredicate(format: "student == %@", student)
            )
        }

    var body: some View {
        Form {
            Section(header: Text("Аты")) {
                Text(student.name ?? "")
            }

            Section(header: Text("Қатысу белгілеу")) {
                DatePicker("Күні", selection: $selectedDate, displayedComponents: .date)

                Picker("Қатысу", selection: $present) {
                    Text("Келді").tag(true)
                    Text("Келмеді").tag(false)
                }
                .pickerStyle(.segmented)

                Button("Сақтау") {
                    addAttendance()
                }
            }

            Section(header: Text("Тарих")) {
                if student.attendancesArray.isEmpty {
                    Text("Жазба жоқ")
                } else {
                    ForEach(student.attendancesArray) { record in
                        HStack {
                            Text(dateFormatter.string(from: record.date ?? Date()))
                            Spacer()
                            Image(systemName: record.isPresent ? "checkmark.circle" : "xmark.circle")
                                .foregroundColor(record.isPresent ? .green : .red)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                deleteRecord(record)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }

        }
        .navigationTitle("Студент")
    }

    // MARK: - ADD ATTENDANCE
    private func addAttendance() {
        let record = Attendance(context: viewContext)
        record.id = UUID()
        record.date = Calendar.current.startOfDay(for: selectedDate)
        record.isPresent = present
        student.addToAttendances(record)

        save()
    }

    // MARK: - DELETE ONLY ATTENDANCE (NOT STUDENT!)
    private func deleteRecord(_ record: Attendance) {
        viewContext.delete(record)
        save()
    }

    private func save() {
        do { try viewContext.save() }
        catch { print("Save error:", error) }
    }
}

private let dateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateStyle = .medium
    return f
}()
