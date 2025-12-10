//
//  AdminClassListView.swift
//  AttendanceTracker
//

import SwiftUI
import CoreData

struct AdminClassListView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ClassRoom.name, ascending: true)]
    ) private var classes: FetchedResults<ClassRoom>

    @State private var showAddClass = false
    @State private var offsetX: [NSManagedObjectID : CGFloat] = [:]  // swipe offsets
    
    var body: some View {

        NavigationView {
            ZStack {

                // 🌿 Пастель жасыл фон (өзгертілмеген)
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

                        // 🔹 Title (сол қалпында)
                        Text("Сыныптар")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.black.opacity(0.9))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top, 10)

                        // 🔹 Each Class Card with SWIPE gesture (design untouched)
                        ForEach(classes) { classRoom in
                            
                            ZStack(alignment: .trailing) {

                                // ❌ DELETE BUTTON (сырғытқанда шығады)
                                Button {
                                    deleteClassManual(classRoom)
                                } label: {
                                    Text("Өшіру")
                                        .foregroundColor(.white)
                                        .font(.system(size: 18, weight: .bold))
                                        .frame(width: 90, height: 70)
                                        .background(Color.red)
                                        .cornerRadius(16)
                                }
                                .opacity(offsetX[classRoom.objectID] == -80 ? 1 : 0)

                                // 🌿 CARD (дизайн өзгермеген)
                                HStack(spacing: 16) {

                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(#colorLiteral(red: 0.20, green: 0.50, blue: 0.40, alpha: 1)))
                                            .frame(width: 55, height: 55)

                                        Image(systemName: "person.3.fill")
                                            .foregroundColor(.white)
                                            .font(.system(size: 24, weight: .semibold))
                                    }

                                    NavigationLink(destination: AdminClassDetailView(classRoom: classRoom)) {
                                        VStack(alignment: .leading, spacing: 6) {

                                            Text(classRoom.name ?? "Аты жоқ")
                                                .font(.system(size: 20, weight: .semibold))
                                                .foregroundColor(.black.opacity(0.9))

                                            Text("Оқушылар саны: \(classRoom.students?.count ?? 0)")
                                                .font(.system(size: 15))
                                                .foregroundColor(.gray)
                                        }
                                    }

                                    Spacer()
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(18)
                                .shadow(color: .black.opacity(0.10), radius: 6, y: 3)
                                .offset(x: offsetX[classRoom.objectID] ?? 0)
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            if value.translation.width < 0 { // left swipe
                                                offsetX[classRoom.objectID] = max(value.translation.width, -80)
                                            }
                                            if value.translation.width > 0 {
                                                offsetX[classRoom.objectID] = 0
                                            }
                                        }
                                        .onEnded { _ in
                                            if (offsetX[classRoom.objectID] ?? 0) < -40 {
                                                offsetX[classRoom.objectID] = -80
                                            } else {
                                                offsetX[classRoom.objectID] = 0
                                            }
                                        }
                                )
                            }
                            .padding(.horizontal)
                        }

                        Spacer().frame(height: 20)
                    }
                }

                // ➕ Add Button (өзгермеген)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showAddClass = true }) {
                            Image(systemName: "plus")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color(#colorLiteral(red: 0.20, green: 0.50, blue: 0.40, alpha: 1)))
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
                        }
                        .padding()
                    }
                }
            }
            .sheet(isPresented: $showAddClass) {
                AdminAddClassView()
            }
        }
    }

    // ❌ Delete function
    private func deleteClassManual(_ classRoom: ClassRoom) {
        viewContext.delete(classRoom)
        do { try viewContext.save() } catch {
            print("Өшіру қатесі:", error.localizedDescription)
        }
    }
}
