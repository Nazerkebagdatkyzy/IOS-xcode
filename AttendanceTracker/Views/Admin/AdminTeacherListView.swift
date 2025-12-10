//
//  AdminTeacherListView.swift
//  AttendanceTracker
//
//  Created by Nazerke Bagdatkyzy on 05.12.2025.
//
import SwiftUI
import CoreData

struct AdminTeacherListView: View {

    @ObservedObject var school: School
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest private var teachers: FetchedResults<Teacher>

    init(school: School) {
        self.school = school

        let req: NSFetchRequest<Teacher> = Teacher.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(keyPath: \Teacher.name, ascending: true)]
        req.predicate = NSPredicate(format: "schoolID == %@", school.id ?? "")

        _teachers = FetchRequest(fetchRequest: req)
    }

    var body: some View {
        List {
            ForEach(teachers) { teacher in
                NavigationLink {
                    AdminTeacherDetailView(teacher: teacher)
                } label: {
                    VStack(alignment: .leading) {
                        Text(teacher.safeName)
                            .font(.headline)
                        Text(teacher.safeEmail)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 6)
                }
            }
            .onDelete(perform: deleteTeacher)   // 👈 МІНЕ ОСЫ СЫРҒЫТУ АРҚЫЛЫ ӨШІРЕДІ
        }
        .navigationTitle("Мұғалімдер")
    }

    // DELETE FUNCTION
    private func deleteTeacher(at offsets: IndexSet) {
        for index in offsets {
            let teacher = teachers[index]
            viewContext.delete(teacher)
        }

        do {
            try viewContext.save()
        } catch {
            print("Error deleting teacher:", error.localizedDescription)
        }
    }
}


struct AdminTeacherListView_Previews: PreviewProvider {
    static var previews: some View {

        let context = PersistenceController.shared.container.viewContext

        // Dummy school for preview
        let school = School(context: context)
        school.id = "school1"
        school.name = "School №1"

        // Dummy teacher for preview
        let sampleTeacher = Teacher(context: context)
        sampleTeacher.name = "Айым"
        sampleTeacher.email = "aiym@example.com"
        sampleTeacher.schoolID = "school1"

        return NavigationView {
            AdminTeacherListView(school: school)
        }
    }
}

