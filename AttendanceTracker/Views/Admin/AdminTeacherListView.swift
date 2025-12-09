//
//  AdminTeacherListView.swift
//  AttendanceTracker
//
//  Created by Nazerke Bagdatkyzy on 05.12.2025.
//
import SwiftUI
import CoreData

struct AdminTeacherListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Teacher.name, ascending: true)]
    ) private var teachers: FetchedResults<Teacher>

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
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }

            }
        }
        .navigationTitle("Мұғалімдер")
    }
}
