import SwiftUI
import CoreData

struct ClassDetailView: View {

    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var classRoom: ClassRoom

    @StateObject private var vm: ClassDetailViewModel

    // ✅ МІНДЕТТІ INIT
    init(classRoom: ClassRoom) {
        self.classRoom = classRoom
        _vm = StateObject(
            wrappedValue: ClassDetailViewModel(
                classRoom: classRoom,
                context: PersistenceController.shared.container.viewContext
            )
        )
    }

    var body: some View {
        Form {

            // ------------------------------
            // КҮН
            // ------------------------------
            Section(header: Text("Күн")) {
                DatePicker(
                    "Күнді таңдаңыз",
                    selection: $vm.date,
                    displayedComponents: .date
                )
                .onChange(of: vm.date) { _ in
                    vm.loadExisting()
                }
            }

            // ------------------------------
            // ОҚУШЫЛАР
            // ------------------------------
            Section(header: Text("Сынып: \(classRoom.name ?? "") — Оқушылар")) {
                ForEach(vm.students, id: \.objectID) { student in
                    StudentAttendanceRow(
                        student: student,
                        isPresent: Binding(
                            get: { vm.tempPresence[student.objectID] ?? true },
                            set: { vm.tempPresence[student.objectID] = $0 }
                        ),
                        tardyMinutes: Binding(
                            get: { vm.tardyMinutes[student.objectID] ?? 0 },
                            set: { vm.tardyMinutes[student.objectID] = $0 }
                        ),
                        tardyReason: Binding(
                            get: { vm.tardyReason[student.objectID] ?? "" },
                            set: { vm.tardyReason[student.objectID] = $0 }
                        )
                    )
                }
            }

            // ------------------------------
            // ТҮЙМЕЛЕР
            // ------------------------------
            Section {
                Button("Барлығын КЕЛДІ қылу") {
                    vm.students.forEach {
                        vm.tempPresence[$0.objectID] = true
                        vm.tardyMinutes[$0.objectID] = 0
                        vm.tardyReason[$0.objectID] = ""
                    }
                }

                Button(action: vm.saveAttendance) {
                    if vm.saving {
                        ProgressView()
                    } else {
                        Text("Сақтау").bold()
                    }
                }

                .disabled(vm.saving)
            }
        }
        .navigationTitle("Attendance — \(classRoom.name ?? "")")
        .alert("Сақталды!", isPresented: $vm.showSavedAlert) {
            Button("OK") {}
        }
        .toolbar {
            NavigationLink(destination: ClassStatisticsView(classRoom: classRoom)) {
                Image(systemName: "chart.bar.fill")
            }
        }
    }
}
