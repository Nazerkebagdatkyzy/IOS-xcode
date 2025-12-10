//
//  ClassDetailView.swift
//  AttendanceTracker
//

import SwiftUI
import CoreData

struct ClassDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var classRoom: ClassRoom
    
    @State private var date = Date()
    @State private var tempPresence: [NSManagedObjectID : Bool] = [:]   // ← ТЕК isPresent
    @State private var saving = false
    @State private var showSavedAlert = false
    @State private var openStudent: Student?
    
    
    // ------------------------------
    // СТУДЕНТТЕР ТІЗІМІ
    // ------------------------------
    private var students: [Student] {
        if let set = classRoom.students as? Set<Student> {
            let unique = Array(Set(set))   // нақты Set фильтр
            return unique.sorted { ($0.studentNumber) < ($1.studentNumber) }
        }
        return []
    }
    
    
    var body: some View {
        VStack {
            Form {
                // ------------------------------
                // КҮН ТАҢДАУ
                // ------------------------------
                Section(header: Text("Күн")) {
                    DatePicker("Күнді таңдаңыз", selection: $date, displayedComponents: .date)
                        .onChange(of: date) { _ in loadExistingForDate() }
                }
                
                // ------------------------------
                // ОҚУШЫЛАР ТІЗІМІ — КЕЛДІ / КЕЛМЕДІ
                // ------------------------------
                Section(header: Text("Сынып: \(classRoom.name ?? "") — Оқушылар")) {
                    ForEach(students, id: \.objectID) { student in
                        
                        VStack(alignment: .leading, spacing: 6) {
                            
                            HStack {
                                // 🔵 Сол жақ — студент аты
                                VStack(alignment: .leading) {
                                    Text(student.name ?? "Аты жоқ")
                                    Text("№\(student.studentNumber)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                // 🟢 Toggle (келмеді / келді)
                                Toggle("", isOn: Binding(
                                    get: { tempPresence[student.objectID] ?? true },
                                    set: { newValue in
                                        tempPresence[student.objectID] = newValue
                                    }
                                ))
                                .toggleStyle(SwitchToggleStyle(tint: .green))
                                .labelsHidden()
                            }
                            
                            NavigationLink(destination: StudentHistoryView(student: student)) {
                                HStack {
                                    Text("Ақпарат")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                    
                                    Spacer()
                                }
                            }
                            .buttonStyle(PlainButtonStyle()) // ← басқанда түсі өзгеріп кетпеу үшін
                            
                            
                            .padding(.top, 4)
                            
                            Divider()
                        }
                        .padding(.vertical, 4)
                    }
                    
                    .onDelete { deleteStudents(at: $0) }
                }
                
                
                
                // ------------------------------
                // ТҮЙМЕЛЕР
                // ------------------------------
                Section {
                    Button("Барлығын КЕЛДІ қылу") {
                        markAllPresent()
                    }
                    
                    Button(action: saveAttendance) {
                        saving
                        ? AnyView(ProgressView())
                        : AnyView(Text("Сақтау").bold())
                    }
                    .disabled(saving)
                }
            }
        }
        .navigationTitle("Attendance — \(classRoom.name ?? "")")
        .onAppear { loadExistingForDate() }
        .alert("Сақталды!", isPresented: $showSavedAlert) {
            Button("OK") {}
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: ClassStatisticsView(classRoom: classRoom)) {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(.blue)
                }
            }
        }
        
    }
    
    
    // ------------------------------
    // КҮН БАСТАУЫН АЛУ
    // ------------------------------
    private func startOfDay(_ d: Date) -> Date {
        Calendar.current.startOfDay(for: d)
    }
    //delete
    
    private func deleteStudents(at offsets: IndexSet) {
        let all = students
        for index in offsets {
            let student = all[index]
            
            // Тек сыныптан өшіру
            student.classRoom = nil
            
            // Сол студентке қатысты attendance-ті де өшіреміз
            let req: NSFetchRequest<Attendance> = Attendance.fetchRequest()
            req.predicate = NSPredicate(format: "student == %@", student)
            
            if let list = try? viewContext.fetch(req) {
                for a in list { viewContext.delete(a) }
            }
            
            viewContext.delete(student)
        }
        
        do {
            try viewContext.save()
        } catch {
            print("Delete error:", error)
        }
    }
    
    
    // ------------------------------
    // БЕЛГІЛІ КҮННІҢ ATTENDANCE-ЫН ЖҮКТЕУ
    // ------------------------------
    private func loadExistingForDate() {
        tempPresence = [:]
        
        let req: NSFetchRequest<Attendance> = Attendance.fetchRequest()
        let dayStart = startOfDay(date)
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: dayStart)!
        
        req.predicate = NSPredicate(
            format: "classRoom == %@ AND date >= %@ AND date < %@",
            classRoom, dayStart as CVarArg, nextDay as CVarArg
        )
        
        do {
            let list = try viewContext.fetch(req)
            
            for student in students {
                if let att = list.first(where: { $0.student == student }) {
                    tempPresence[student.objectID] = att.isPresent
                } else {
                    tempPresence[student.objectID] = true   // default = present (OK)
                }
            }
        } catch {
            print("ERROR loading attendance:", error)
        }
    }
    
    // ------------------------------
    // БАРЛЫҒЫН КЕЛДІ ҚЫЛУ
    // ------------------------------
    private func markAllPresent() {
        students.forEach { tempPresence[$0.objectID] = true }
    }
    
    // ------------------------------
    // ATTENDANCE САҚТАУ
    // ------------------------------
    private func saveAttendance() {
        saving = true

        let dayStart = startOfDay(date)
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: dayStart)!

        for student in students {

            let isPresent = tempPresence[student.objectID] ?? true

            // Дәл осы күн үшін Attendance бар ма?
            let req: NSFetchRequest<Attendance> = Attendance.fetchRequest()
            req.predicate = NSPredicate(
                format: "student == %@ AND classRoom == %@ AND date >= %@ AND date < %@",
                student, classRoom, dayStart as CVarArg, nextDay as CVarArg
            )
            req.fetchLimit = 1

            let found = try? viewContext.fetch(req)

            if let existing = found?.first {
                // 🔵 Бар болса → тек статусын жаңартамыз
                existing.isPresent = isPresent
            } else {
                // 🔵 Жоқ болса → жаңа Attendance жасаймыз
                let att = Attendance(context: viewContext)
                att.id = UUID()
                att.student = student
                att.classRoom = classRoom
                att.date = dayStart        // 🎯 ЕҢ ДҰРЫСЫ: startOfDay
                att.isPresent = isPresent
            }
        }

        do {
            try viewContext.save()
        } catch {
            print("SAVE ERROR:", error)
        }

        saving = false
        showSavedAlert = true
    }

    
    
}
