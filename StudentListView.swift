import SwiftUI
import CoreData

struct StudentListView: View {
    @ObservedObject var group: Group
    @Environment(\.managedObjectContext) private var viewContext

    // MARK: - Sheet басқару
    enum ActiveSheet: Identifiable {
        case addStudent
        case stats

        var id: Int { hashValue }
    }

    @State private var activeSheet: ActiveSheet?

    // MARK: - Дұрыс FetchRequest (маңызды!)
    @FetchRequest var students: FetchedResults<Student>

    init(group: Group) {
        self.group = group

        // Тек осы топқа тиісті студенттерді шақыру
        _students = FetchRequest<Student>(
            sortDescriptors: [NSSortDescriptor(keyPath: \Student.name, ascending: true)],
            predicate: NSPredicate(format: "group == %@", group)
        )
    }

    var body: some View {
        List {
            ForEach(students) { student in
                NavigationLink(destination: StudentDetailView(student: student)) {
                    HStack {
                        Text(student.name ?? "Студент")
                        Spacer()
                        Text(String(format: "%.0f%%", student.presencePercentage()))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .onDelete(perform: deleteStudents) 
        }
        .navigationTitle(group.name ?? "Топ")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button(action: {
                        activeSheet = .stats
                    }) {
                        Image(systemName: "chart.bar")
                    }

                    Button(action: {
                        activeSheet = .addStudent
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }

        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .addStudent:
                NavigationView {
                    AddStudentView(group: group)
                        .environment(\.managedObjectContext, viewContext)
                }

            case .stats:
                NavigationView {
                    StatsView(group: group)
                        .environment(\.managedObjectContext, viewContext)
                }
            }
        }

    }

    // MARK: - Delete student
    private func deleteStudents(offsets: IndexSet) {
        withAnimation {
            offsets.map { students[$0] }.forEach(viewContext.delete)
            save()
        }
    }

    private func save() {
        do { try viewContext.save() }
        catch { print("Save error: \(error)") }
    }
}
