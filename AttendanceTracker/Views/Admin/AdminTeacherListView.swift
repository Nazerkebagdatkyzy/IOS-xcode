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

        // ❗️Басты өзгеріс — schoolID арқылы фильтрлеу
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
                }
            }
        }
        .navigationTitle("Мұғалімдер")
    }
}
