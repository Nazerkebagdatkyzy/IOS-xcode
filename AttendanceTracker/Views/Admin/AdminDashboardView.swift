import SwiftUI
import CoreData

struct AdminDashboardView: View {
    @ObservedObject var admin: SchoolAdmin
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        
        NavigationView {
            ZStack {
                
                // 🌿 Қою пастель жасыл фон (premium стиль)
                LinearGradient(
                    colors: [
                        Color(#colorLiteral(red: 0.78, green: 0.92, blue: 0.88, alpha: 1)),
                        Color(#colorLiteral(red: 0.84, green: 0.95, blue: 0.90, alpha: 1))
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                
                ScrollView {
                    VStack(spacing: 22) {
                        
                        // 🔹 Үлкен, сол жаққа бағытталған "Админ панелі"
                        Text("Админ панелі")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.black.opacity(0.9))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top, 10)
                        
                        
                        // 🔹 Welcome Text
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Қош келдіңіз,")
                                .font(.title3)
                                .foregroundColor(.black.opacity(0.7))
                            
                            Text(admin.name ?? "Админ")
                                .font(.system(size: 26, weight: .semibold))
                                .foregroundColor(.black.opacity(0.9))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 4)
                        
                        
                        // 🔹 Dashboard Buttons
                        VStack(spacing: 18) {
                            
                            if let school = admin.school {
                                NavigationLink(destination: SchoolStatisticsView(school: school)) {
                                    dashboardButton(icon: "chart.bar.doc.horizontal",
                                                    title: "Менің мектебім")
                                }
                            }
                            
                            NavigationLink(destination: AllSchoolsListView()) {
                                dashboardButton(icon: "building.2",
                                                title: "Барлық мектептер")
                            }
                            
                            NavigationLink(destination: AdminClassListView()) {
                                dashboardButton(icon: "building.2.crop.circle",
                                                title: "Сыныптар")
                            }
                            
                            if let school = admin.school {
                                NavigationLink(destination: AdminTeacherListView(school: school)) {
                                    dashboardButton(icon: "person.3.fill",
                                                    title: "Мұғалімдер")
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    
    // MARK: - Dashboard Button Style
    private func dashboardButton(icon: String, title: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.black.opacity(0.8))
            
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black.opacity(0.85))
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.system(size: 16, weight: .medium))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 6, y: 4)
    }
}
