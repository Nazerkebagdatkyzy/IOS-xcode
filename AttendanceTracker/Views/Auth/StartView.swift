//
//  StartView.swift
//  AttendanceTracker
//

import SwiftUI

struct StartView: View {

    @State private var animateLogo = false
    @State private var animateTitle = false   // ← Тақырып анимациясы

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationView {
            ZStack {

                // MARK: — Артқы фон (қою изумруд)
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(#colorLiteral(red: 0.02, green: 0.20, blue: 0.17, alpha: 1)),
                        Color(#colorLiteral(red: 0.00, green: 0.16, blue: 0.14, alpha: 1))
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 20) {

                    // MARK: — ЛОГОТИП + Тақырып + Анимациялар
                    VStack(spacing: 12) {

                        // 🌟 ЛОГОТИП (алтын + анимация)
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
                            .shadow(color: .yellow.opacity(0.35), radius: 10)
                            .scaleEffect(animateLogo ? 1.10 : 0.92)
                            .opacity(animateLogo ? 1 : 0.7)
                            .animation(
                                .easeInOut(duration: 1.6).repeatForever(autoreverses: true),
                                value: animateLogo
                            )

                        // 🌟 TITLE АНИМАЦИЯ (fade + scale)
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
                            .animation(
                                .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                                value: animateTitle
                            )
                            .shadow(color: .yellow.opacity(0.25), radius: 10)

                        Text("Smart Digital Attendance System")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.75))
                    }
                    .padding(.top, 40)
                    .onAppear {
                        animateLogo = true
                        animateTitle = true
                    }

                    // MARK: — EMERALD GRID (4 жаңа реңк)
                    LazyVGrid(columns: columns, spacing: 16) {

                        // 1 — Emerald Mint (#B6F5DF)
                        gridButton(
                            title: "Мұғалім кіру",
                            icon: "person.crop.rectangle",
                            color: Color(#colorLiteral(red: 0.71, green: 0.96, blue: 0.87, alpha: 1)),
                            destination: TeacherLoginView()
                        )

                        // 2 — Teal Green (#A1EFE2)
                        gridButton(
                            title: "Админ кіру",
                            icon: "person.3",
                            color: Color(#colorLiteral(red: 0.63, green: 0.94, blue: 0.88, alpha: 1)),
                            destination: AdminLoginView()
                        )

                        // 3 — Soft Seafoam (#CFFFF0)
                        gridButton(
                            title: "Мұғалім тіркелу",
                            icon: "pencil.circle.fill",
                            color: Color(#colorLiteral(red: 0.81, green: 1.0, blue: 0.94, alpha: 1)),
                            destination: TeacherRegisterView()
                        )

                        // 4 — Aqua Mist (#D8FFF4)
                        gridButton(
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
            }
        }
    }

    // MARK: — Контейнер компоненті
    @ViewBuilder
    func gridButton<Destination: View>(
        title: String,
        icon: String,
        color: Color,
        destination: Destination
    ) -> some View {

        NavigationLink(destination: destination) {
            VStack(spacing: 12) {

                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(.black.opacity(0.7))

                Text(title)
                    .font(.headline)
                    .foregroundColor(.black.opacity(0.85))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 150)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        color.opacity(0.98),
                        color.opacity(1.0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.22), radius: 10, x: 0, y: 5)
        }
    }
}
