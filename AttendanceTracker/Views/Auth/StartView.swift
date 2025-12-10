//
//  StartView.swift
//  AttendanceTracker
//

import SwiftUI
import CoreData

struct StartView: View {

    @State private var animateLogo = false
    @State private var animateTitle = false
    @State private var shimmer = false
    @State private var ripple = false

    // Core Data context
    private var viewContext: NSManagedObjectContext {
        PersistenceController.shared.container.viewContext
    }

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationView {
            ZStack {
                // BG gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(#colorLiteral(red: 0.02, green: 0.20, blue: 0.17, alpha: 1)),
                        Color(#colorLiteral(red: 0.00, green: 0.16, blue: 0.14, alpha: 1))
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 25) {

                    // LOGO
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.15), lineWidth: 3)
                            .frame(width: 120, height: 120)
                            .scaleEffect(ripple ? 1.6 : 0.8)
                            .opacity(ripple ? 0 : 1)
                            .animation(.easeOut(duration: 2.2).repeatForever(autoreverses: false),
                                       value: ripple)

                        Image(systemName: "network")
                            .font(.system(size: 65, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(#colorLiteral(red: 1.0, green: 0.93, blue: 0.70, alpha: 1)),
                                        Color(#colorLiteral(red: 1.0, green: 0.83, blue: 0.46, alpha: 1))
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .scaleEffect(animateLogo ? 1.10 : 0.92)
                            .opacity(animateLogo ? 1 : 0.7)
                            .shadow(color: .yellow.opacity(0.35), radius: 10)
                            .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true),
                                       value: animateLogo)
                    }

                    // TITLE + SHIMMER
                    ZStack {
                        Text("Attendance Tracker")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(#colorLiteral(red: 1.0, green: 0.96, blue: 0.82, alpha: 1)),
                                        Color(#colorLiteral(red: 1.0, green: 0.88, blue: 0.52, alpha: 1))
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .scaleEffect(animateTitle ? 1.04 : 0.97)
                            .opacity(animateTitle ? 1 : 0.75)
                            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                                       value: animateTitle)

                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.1), Color.white, Color.white.opacity(0.1)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .rotationEffect(.degrees(30))
                            .offset(x: shimmer ? 250 : -250)
                            .blendMode(.overlay)
                            .animation(.linear(duration: 2.2).repeatForever(autoreverses: false),
                                       value: shimmer)
                    }

                    Text("Smart Digital Attendance System")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.75))

                    // GRID BUTTONS
                    LazyVGrid(columns: columns, spacing: 18) {

                        emeraldButton(
                            title: "Мұғалім кіру",
                            icon: "person.crop.rectangle",
                            color: Color(#colorLiteral(red: 0.71, green: 0.96, blue: 0.87, alpha: 1)),
                            destination: TeacherLoginView()
                        )

                        emeraldButton(
                            title: "Админ кіру",
                            icon: "person.3",
                            color: Color(#colorLiteral(red: 0.63, green: 0.94, blue: 0.88, alpha: 1)),
                            destination: AdminLoginView()
                        )

                        emeraldButton(
                            title: "Мұғалім тіркелу",
                            icon: "pencil.circle.fill",
                            color: Color(#colorLiteral(red: 0.81, green: 1.0, blue: 0.94, alpha: 1)),
                            destination: TeacherRegisterView()
                        )

                        emeraldButton(
                            title: "Админ тіркелу",
                            icon: "lock.shield.fill",
                            color: Color(#colorLiteral(red: 0.85, green: 1.0, blue: 0.96, alpha: 1)),
                            destination: AdminRegisterView()
                        )
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .padding()
                .onAppear {
                    animateLogo = true
                    animateTitle = true
                    shimmer = true
                    ripple = true

                    createDefaultSchoolIfNeeded()   // ← МЕКТЕПТІ ОСЫ ЖЕРДЕ ҚҰРАДЫ
                }
            }
        }
    }

    // MARK: — EMERALD BUTTON
    @ViewBuilder
    func emeraldButton<Destination: View>(
        title: String,
        icon: String,
        color: Color,
        destination: Destination
    ) -> some View {

        @State var hover = false

        NavigationLink(destination: destination) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(.black.opacity(0.75))

                Text(title)
                    .font(.headline)
                    .foregroundColor(.black.opacity(0.85))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 150)
            .background(color)
            .cornerRadius(22)
            .scaleEffect(hover ? 1.03 : 1.0)
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: hover)
            .onLongPressGesture(minimumDuration: .infinity, pressing: { pressed in
                hover = pressed
            }, perform: {})
        }
    }

    // MARK: — DEFAULT МЕКТЕП ҚҰРУ
    private func createDefaultSchoolIfNeeded() {
        let req: NSFetchRequest<School> = School.fetchRequest()

        if let count = try? viewContext.count(for: req), count == 0 {

            let school = School(context: viewContext)
            school.id = UUID().uuidString
            school.name = "№1 Мектеп"
            school.city = "Astana"
            school.region = "Kazakhstan"

            try? viewContext.save()
            print("✔ Default school CREATED")
        } else {
            print("ℹ School already exists")
        }
    }
}
