//
//  AdminAddClassView.swift
//  AttendanceTracker
//

import SwiftUI
import CoreData

struct AdminAddClassView: View {

    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Teacher.name, ascending: true)]
    ) private var teachers: FetchedResults<Teacher>

    @State private var name = ""
    @State private var selectedTeacher: Teacher?
    @State private var saved = false
    @State private var showError = false

    var body: some View {

        NavigationView {
            ZStack {

                // 🌿 Пастель жасыл фон (дәл сенің скрин стилің)
                Color(#colorLiteral(red: 0.93, green: 0.98, blue: 0.94, alpha: 1))
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 26) {

                        // TITLE
                        Text("Сынып қосу")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.black.opacity(0.85))
                            .padding(.top, 10)

                        // CLASS NAME FIELD
                        VStack(alignment: .leading, spacing: 8) {

                            Text("Сынып атауы")
                                .foregroundColor(.black.opacity(0.7))
                                .font(.headline)

                            TextField("Мысалы: 5A", text: $name)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(14)
                                .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                        }

                        // TEACHER PICKER
                        VStack(alignment: .leading, spacing: 6) {

                            Text("Мұғалім тағайындау")
                                .foregroundColor(.black.opacity(0.75))
                                .font(.headline)

                            Menu {
                                ForEach(teachers) { teacher in
                                    Button {
                                        selectedTeacher = teacher
                                    } label: {
                                        Text(teacher.name ?? "Аты жоқ")
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedTeacher?.name ?? "Мұғалімді таңдаңыз")
                                        .foregroundColor(
                                            selectedTeacher == nil ?
                                            .gray.opacity(0.6) :
                                            .black.opacity(0.9)
                                        )
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(14)
                                .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                            }

                            if selectedTeacher != nil {
                                Text("Таңдалған: \(selectedTeacher?.name ?? "")")
                                    .foregroundColor(.green)
                                    .font(.subheadline)
                            }
                        }

                        // SAVE BUTTON — сол стиль: жұмсақ жасыл + көлеңке
                        Button(action: saveClass) {
                            Text("Сақтау")
                                .font(.headline)
                                .foregroundColor(.black.opacity(0.8))
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        .background(
                            (name.isEmpty || selectedTeacher == nil)
                            ? Color(#colorLiteral(red: 0.75, green: 0.85, blue: 0.78, alpha: 1))
                            : Color(#colorLiteral(red: 0.66, green: 0.90, blue: 0.78, alpha: 1))
                        )
                        .cornerRadius(16)
                        .disabled(name.isEmpty || selectedTeacher == nil)
                        .shadow(color: .black.opacity(0.12), radius: 8, y: 4)

                        if showError {
                            Text("Қате: сыныпты сақтау мүмкін болмады")
                                .foregroundColor(.red)
                        }

                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
            .alert("Сақталды!", isPresented: $saved) {
                Button("OK") {}
            }
        }
    }

    private func saveClass() {
        guard !name.isEmpty, let teacher = selectedTeacher else {
            showError = true
            return
        }

        let classRoom = ClassRoom(context: viewContext)
        classRoom.id = UUID()
        classRoom.name = name
        classRoom.teacher = teacher
        classRoom.school = teacher.school

        do {
            try viewContext.save()
            saved = true
            name = ""
            selectedTeacher = nil
        } catch {
            showError = true
        }
    }
}
