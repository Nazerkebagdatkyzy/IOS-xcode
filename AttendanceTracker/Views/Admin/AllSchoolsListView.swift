import SwiftUI
import CoreData

struct AllSchoolsListView: View {
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \School.name, ascending: true)]
    ) private var schools: FetchedResults<School>
    
    var body: some View {
        
        ZStack {
            
            // 🌿 Қою пастель көк-жасыл фон
            LinearGradient(
                colors: [
                    Color(#colorLiteral(red: 0.78, green: 0.92, blue: 0.88, alpha: 1)), // қоюырақ
                    Color(#colorLiteral(red: 0.84, green: 0.95, blue: 0.90, alpha: 1))
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // 🔹 Title
                    Text("Барлық мектептер")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black.opacity(0.9))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                    
                    // 🔹 Schools List
                    ForEach(schools) { school in
                        NavigationLink(destination: SchoolStatisticsView(school: school)) {
                            
                            HStack(spacing: 16) {
                                
                                // 🏫 Мектеп ИКОНКАСЫ
                                ZStack {
                                    Circle()
                                        .fill(Color(#colorLiteral(red: 0.91, green: 0.98, blue: 0.95, alpha: 1)))
                                        .frame(width: 50, height: 50)
                                    
                                    Image(systemName: "building.columns.fill")
                                        .foregroundColor(Color(#colorLiteral(red: 0.25, green: 0.50, blue: 0.45, alpha: 1)))
                                        .font(.system(size: 24, weight: .semibold))
                                }
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    
                                    Text(school.name ?? "Атауы жоқ")
                                        .font(.system(size: 21, weight: .semibold))
                                        .foregroundColor(.black.opacity(0.9))
                                    
                                    Text("\(school.city ?? "") • \(school.region ?? "")")
                                        .font(.system(size: 15))
                                        .foregroundColor(.black.opacity(0.55))
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 16))
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            
                            // 🌈 Пастель ақ-көк градиент карточка
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(#colorLiteral(red: 0.98, green: 1.0, blue: 1.0, alpha: 1)),
                                        Color(#colorLiteral(red: 0.92, green: 0.97, blue: 0.99, alpha: 1))
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(18)
                            .shadow(color: .black.opacity(0.10), radius: 6, y: 4)
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
