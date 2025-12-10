//
//  AdminTeacherListView.swift
//  AttendanceTracker
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

        ZStack {

            // 🌈 Пастель премиум фон
            LinearGradient(
                colors: [
                    Color(#colorLiteral(red: 0.78, green: 0.92, blue: 0.88, alpha: 1)),
                    Color(#colorLiteral(red: 0.86, green: 0.96, blue: 0.91, alpha: 1))
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // ✨ Иллюстрациялық элементтер
            Group {
                Circle()
                    .fill(Color.white.opacity(0.18))
                    .frame(width: 260, height: 260)
                    .blur(radius: 40)
                    .offset(x: -140, y: -260)

                RoundedRectangle(cornerRadius: 200)
                    .fill(Color.white.opacity(0.16))
                    .frame(width: 350, height: 240)
                    .rotationEffect(.degrees(-18))
                    .blur(radius: 30)
                    .offset(x: 180, y: -60)

                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 200, height: 200)
                    .blur(radius: 35)
                    .offset(x: -170, y: 210)

                RoundedRectangle(cornerRadius: 160)
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 300, height: 200)
                    .rotationEffect(.degrees(12))
                    .blur(radius: 40)
                    .offset(x: 150, y: 240)
            }
            .allowsHitTesting(false)

            // 🌿 Main Content
            ScrollView {

                VStack(spacing: 22) {

                    // 🔹 Title
                    Text("Мұғалімдер")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black.opacity(0.9))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 10)

                    // 🔹 Teachers List
                    ForEach(teachers) { teacher in
                        NavigationLink(destination: AdminTeacherDetailView(teacher: teacher)) {

                            HStack(spacing: 16) {

                                // 🟩 Avatar
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(#colorLiteral(red: 0.20, green: 0.50, blue: 0.40, alpha: 1)))
                                        .frame(width: 52, height: 52)

                                    let initials = makeInitials(from: teacher.safeName)
                                    Text(initials)
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.white)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(teacher.safeName)
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.black.opacity(0.9))

                                    Text(teacher.safeEmail)
                                        .font(.system(size: 15))
                                        .foregroundColor(.gray)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(18)
                            .shadow(color: .black.opacity(0.10), radius: 6, y: 3)
                        }
                        .padding(.horizontal)
                    }

                    Spacer().frame(height: 20)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - DELETE TEACHER
    private func deleteTeacher(at offsets: IndexSet) {
        for index in offsets {
            viewContext.delete(teachers[index])
        }
        try? viewContext.save()
    }

    // MARK: - INITIALS GENERATOR
    private func makeInitials(from name: String) -> String {
        let comps = name.split(separator: " ")
        let initials = comps.prefix(2)
            .compactMap { $0.first }
            .map { String($0).uppercased() }
            .joined()
        return initials
    }
}

