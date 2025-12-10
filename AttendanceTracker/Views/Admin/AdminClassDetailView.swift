//
//  AdminClassDetailView.swift
//  AttendanceTracker
//

import SwiftUI
import CoreData

struct AdminClassDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var classRoom: ClassRoom

    @State private var showAddStudent = false

    private var students: [Student] {
        (classRoom.students as? Set<Student>)?
            .sorted { $0.studentNumber < $1.studentNumber } ?? []
    }

    var body: some View {
        ZStack {

            // 🌿 Premium пастель жасыл фон
            LinearGradient(
                colors: [
                    Color(#colorLiteral(red: 0.78, green: 0.92, blue: 0.88, alpha: 1)),
                    Color(#colorLiteral(red: 0.85, green: 0.96, blue: 0.90, alpha: 1))
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {

                VStack(alignment: .leading, spacing: 28) {

                    // 🔹 Title
                    Text(classRoom.name ?? "Сынып")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.black.opacity(0.9))
                        .padding(.top, 10)
                        .padding(.horizontal)

                    // 🔹 CLASS INFO CARD
                    HStack(spacing: 16) {

                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(#colorLiteral(red: 0.20, green: 0.50, blue: 0.40, alpha: 1)))
                                .frame(width: 60, height: 60)

                            Image(systemName: "graduationcap.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 26))
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Сынып туралы")
                                .font(.headline)
                                .foregroundColor(.black.opacity(0.7))

                            Text("Атауы: \(classRoom.name ?? "Анықталмаған")")
                                .foregroundColor(.black.opacity(0.85))

                            Text("Студенттер саны: \(students.count)")
                                .foregroundColor(.black.opacity(0.85))
                        }

                        Spacer()
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(18)
                    .shadow(color: .black.opacity(0.10), radius: 6, y: 3)
                    .padding(.horizontal)

                    // 🔹 Students Header
                    HStack {
                        Text("Студенттер")
                            .font(.headline)
                            .foregroundColor(.black.opacity(0.75))

                        Spacer()

                        Button(action: { showAddStudent = true }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(Color(#colorLiteral(red: 0.20, green: 0.50, blue: 0.40, alpha: 1)))
                                .font(.system(size: 28))
                        }
                    }
                    .padding(.horizontal)

                    // 🔹 Students List — жұмыс істейтін NavigationLink
                    if students.isEmpty {

                        Text("Студенттер жоқ")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.07), radius: 5, y: 3)
                            .padding(.horizontal)

                    } else {

                        ForEach(students) { st in

                            NavigationLink(destination: AdminStudentDetailView(student: st)) {

                                HStack(spacing: 16) {

                                    // Аватар стиліндегі иконка
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(#colorLiteral(red: 0.20, green: 0.50, blue: 0.40, alpha: 1)))
                                            .frame(width: 52, height: 52)

                                        Image(systemName: "person.fill")
                                            .foregroundColor(.white)
                                            .font(.system(size: 22))
                                    }

                                    VStack(alignment: .leading, spacing: 4) {

                                        Text(st.name ?? "Аты жоқ")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.black)

                                        Text("№\(st.studentNumber)")
                                            .foregroundColor(.gray)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: .black.opacity(0.10), radius: 6, y: 3)
                            }
                            .padding(.horizontal)
                        }
                        .onDelete(perform: deleteStudent)
                    }

                    Spacer().frame(height: 20)
                }
            }
        }
        .sheet(isPresented: $showAddStudent) {
            AdminAddStudentView(classRoom: classRoom)
        }
    }

    private func deleteStudent(at offsets: IndexSet) {
        let list = students
        for index in offsets { viewContext.delete(list[index]) }
        try? viewContext.save()
    }
}

