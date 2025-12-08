//
//  AdminDashboard.swift
//  AttendanceTracker
//
//  Created by Nazerke Bagdatkyzy on 05.12.2025.
//
import SwiftUI
import CoreData

struct AdminDashboardView: View {
    @ObservedObject var admin: SchoolAdmin
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {

                Text("Қош келдіңіз, \(admin.name ?? "Админ")")
                    .font(.title2).bold()

                // School statistics button
                NavigationLink(destination: SchoolStatisticsView(school: fetchSchool())) {
                    dashboardButton(icon: "chart.bar.fill", title: "Мектеп статистикасы")
                }


                // ---- Сыныптар ----
                NavigationLink(destination: AdminClassListView()) {
                    dashboardButton(icon: "building.2.crop.circle", title: "Сыныптар")
                }

                // ---- Мұғалімдер ----
                NavigationLink(destination: AdminTeacherListView()) {
                    dashboardButton(icon: "person.3.fill", title: "Мұғалімдер")
                }


                Spacer()
            }
            .padding()
            .navigationTitle("Админ панелі")
        }
    }

    private func dashboardButton(icon: String, title: String) -> some View {
        HStack {
            Image(systemName: icon).font(.title2)
            Text(title).font(.headline)
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private func fetchSchool() -> School {
        let req: NSFetchRequest<School> = School.fetchRequest()
        req.predicate = NSPredicate(format: "id == %@", admin.schoolID ?? "")
        let res = try? viewContext.fetch(req)
        return res?.first ?? School()
    }
}

