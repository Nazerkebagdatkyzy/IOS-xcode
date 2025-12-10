import SwiftUI
import CoreData

struct TeacherDashboardView: View {

    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var teacher: Teacher
    @FetchRequest var classes: FetchedResults<ClassRoom>

    @State private var showingAddClass = false

    init(teacher: Teacher) {
        self.teacher = teacher
        _classes = FetchRequest<ClassRoom>(
            sortDescriptors: [NSSortDescriptor(keyPath: \ClassRoom.name, ascending: true)],
            predicate: NSPredicate(format: "teacher == %@", teacher)
        )
    }

    var body: some View {

        ZStack {
            // Ашық түсті фон
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(#colorLiteral(red: 0.95, green: 1.0, blue: 0.97, alpha: 1)),
                    Color(#colorLiteral(red: 0.88, green: 1.0, blue: 0.93, alpha: 1))
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 25) {

                    // ---------------- HEADER ----------------
                    VStack(alignment: .leading, spacing: 4) {

                        Text("Қош келдіңіз,")
                            .font(.title3)
                            .foregroundColor(.black.opacity(0.6))

                        Text(teacher.name ?? "Мұғалім")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.black)

                        Text("Мектеп: \(schoolName(for: teacher.schoolID ?? ""))")
                            .foregroundColor(.black.opacity(0.6))
                            .font(.subheadline)
                    }
                    .padding(.horizontal)

                    Divider()
                        .padding(.horizontal)

                    // ---------------- PROFILE BUTTON ----------------
                    NavigationLink {
                        TeacherProfileEditView(teacher: teacher)
                    } label: {
                        Text("Профильді өзгерту")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(#colorLiteral(red: 0.75, green: 0.95, blue: 0.88, alpha: 1)))
                            .foregroundColor(.black)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 3)
                    }
                    .padding(.horizontal)

                    // ---------------- TITLE + ADD BUTTON ----------------
                    HStack {
                        Text("Менің сыныптарым")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.black)

                        Spacer()
                    }

                    .padding(.horizontal)

                    // ---------------- CLASS CARDS ----------------
                    VStack(spacing: 14) {
                        ForEach(classes) { classRoom in
                            NavigationLink(destination: ClassDetailView(classRoom: classRoom)) {

                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {

                                        Text(classRoom.name ?? "Сынып")
                                            .font(.headline)
                                            .foregroundColor(.black)

                                        Text("Оқушылар: \((classRoom.students as? Set<Student>)?.count ?? 0)")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
                            }
                        }

                        if classes.isEmpty {
                            Text("Әзірге сыныптар жоқ")
                                .foregroundColor(.gray)
                                .italic()
                                .padding(.top, 10)
                        }
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .padding(.top)
            }
        }
    }
}

struct TeacherDashboardView_Previews: PreviewProvider {
    static var previews: some View {

        // Жалған teacher объектісін preview үшін ойдан жасаймыз
        let teacher = Teacher(context: PersistenceController.shared.container.viewContext)
        teacher.name = "Мұғалім"
        teacher.schoolID = "school1"

        return NavigationView {
            TeacherDashboardView(teacher: teacher)
        }
    }
}
