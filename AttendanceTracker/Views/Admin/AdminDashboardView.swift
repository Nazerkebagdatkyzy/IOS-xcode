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
                
                
                // 🔹 ТЕК ӨЗ МЕКТЕБІНІҢ СТАТИСТИКАСЫ
                if let school = admin.school {
                    NavigationLink(
                        destination: SchoolStatisticsView(school: school)
                    ) {
                        dashboardButton(icon: "chart.bar.doc.horizontal",
                                        title: "Менің мектебім")
                    }
                }
                
                
                // 🔹 БАРЛЫҚ МЕКТЕПТЕР ТІЗІМІ (ЖАҢА!!)
                NavigationLink(destination: AllSchoolsListView()) {
                    dashboardButton(icon: "building.2", title: "Барлық мектептер")
                }
                
                
                // 🔹 Сыныптар
                NavigationLink(destination: AdminClassListView()) {
                    dashboardButton(icon: "building.2.crop.circle",
                                    title: "Сыныптар")
                }
                
                
                // 🔹 Мұғалімдер
                if let school = admin.school {
                    NavigationLink(destination: AdminTeacherListView(school: school)) {
                        dashboardButton(icon: "person.3.fill",
                                        title: "Мұғалімдер")
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Админ панелі")
        }
    }
    
    
    private func dashboardButton(icon: String, title: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
            Text(title)
                .font(.headline)
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}
