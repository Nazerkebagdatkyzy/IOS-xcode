//
//  TeacherDashboard.swift
//  AttendanceTracker
//
//  Created by Nazerke Bagdatkyzy on 05.12.2025.
//

import SwiftUI
import CoreData

struct TeacherDashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext

    // Login кезінде жіберілетін Teacher объектісі
    @ObservedObject var teacher: Teacher

    // Fetch teacher's classes
    @FetchRequest var classes: FetchedResults<ClassRoom>

    init(teacher: Teacher) {
        self.teacher = teacher

        // Fetch classes belonging to this teacher only
        _classes = FetchRequest<ClassRoom>(
            sortDescriptors: [NSSortDescriptor(keyPath: \ClassRoom.name, ascending: true)],
            predicate: NSPredicate(format: "teacher == %@", teacher)
        )
    }

    @State private var showingAddClass = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Қош келдіңіз,")
                            .font(.title3)
                            .foregroundColor(.gray)

                        Text(teacher.name ?? "Мұғалім")
                            .font(.largeTitle)
                            .bold()

                        Text("Мектеп: \(schoolName(for: teacher.schoolID ?? ""))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)

                    // Divider
                    Divider().padding(.horizontal)

                    // Title row + add button
                    HStack {
                        Text("Менің сыныптарым")
                            .font(.title2)
                            .bold()

                        Spacer()

                    }
                    .padding(.horizontal)

                    // Classes List
                    VStack(spacing: 12) {
                        ForEach(classes) { classRoom in
                            NavigationLink(destination: ClassDetailView(classRoom: classRoom)) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(classRoom.name ?? "Сынып")
                                            .font(.headline)
                                            .bold()

                                        Text("Оқушылар: \((classRoom.students as? Set<Student>)?.count ?? 0)")

                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 3)
                            }
                        }

                        if classes.isEmpty {
                            Text("Әзірге сыныптар жоқ")
                                .foregroundColor(.gray)
                                .italic()
                        }
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .padding(.top)
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingAddClass) {
            AddClassView(teacher: teacher)
        }
    }
}

