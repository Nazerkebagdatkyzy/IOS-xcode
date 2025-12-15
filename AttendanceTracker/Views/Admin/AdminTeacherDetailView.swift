//
//  AdminTeacherDetailView.swift
//  AttendanceTracker
//

import SwiftUI
import Foundation
import UIKit

// MARK: - Safe access extension
extension Teacher {

    var safeName: String { name ?? "Аты белгісіз" }
    var safeEmail: String { email ?? "Email жоқ" }
    var safeCity: String { city ?? "Белгісіз" }
    var safeRegion: String { region ?? "Белгісіз" }
    var safeSchool: String { schoolID ?? "Белгісіз" }
    var safeEducation: String { education ?? "Көрсетілмеген" }
    var safeSkills: String { skills ?? "Көрсетілмеген" }
    var safeAbout: String { aboutMe ?? "Мәлімет толтырылмаған" }
    var safeExperience: String { "\(experience) жыл" }

    // ✅ МАРАПАТТАР (AchievementsEditorView сақтаған форматпен)
    var safeAchievementsText: String {
        guard let arr = achievements as? [[String: Any]] else {
            return "Мәлімет жоқ"
        }

        let titles = arr.compactMap { $0["title"] as? String }
        return titles.isEmpty ? "Мәлімет жоқ" : titles.joined(separator: "\n")
    }

    // ✅ СЕРТИФИКАТТАР
    var safeCertificatesText: String {
        guard let arr = certificates as? [String], !arr.isEmpty else {
            return "Мәлімет жоқ"
        }
        return arr.joined(separator: "\n")
    }

    // ✅ ӘЛЕУМЕТТІК ЖЕЛІЛЕР
    var safeSocialLinksText: String {
        guard let arr = socialLinks as? [String], !arr.isEmpty else {
            return "Мәлімет жоқ"
        }
        return arr.joined(separator: "\n")
    }
}

// MARK: - Mint palette
extension Color {
    static let mintDark = Color(red: 0.15, green: 0.52, blue: 0.46)
    static let mintSoft = Color(red: 0.85, green: 0.97, blue: 0.93)
}

struct AdminTeacherDetailView: View {

    @ObservedObject var teacher: Teacher

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {

                // MARK: - Avatar
                avatarSection
                    .padding(.top, 20)

                // MARK: - Name
                VStack(spacing: 4) {
                    Text(teacher.safeName)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.black)

                    Text(teacher.safeEmail)
                        .foregroundColor(.gray)
                }

                // MARK: - INFO CARD
                infoCard(
                    title: "ЖЕКЕ МӘЛІМЕТ",
                    items: [
                        ("Аты-жөні", teacher.safeName),
                        ("Email", teacher.safeEmail),
                        ("Телефон", teacher.phone ?? "Көрсетілмеген"),
                        ("Қала", teacher.safeCity),
                        ("Өңір", teacher.safeRegion),
                        ("Мектебі", teacher.safeSchool)
                    ]
                )

                // MARK: - RESUME CARD
                infoCard(
                    title: "РЕЗЮМЕ",
                    items: [
                        ("Білімі", teacher.safeEducation),
                        ("Тәжірибесі", teacher.safeExperience),
                        ("Дағдылары", teacher.safeSkills)
                    ]
                )

                // MARK: - ӨЗІ ТУРАЛЫ
                sectionCard(
                    title: "ӨЗІ ТУРАЛЫ",
                    content: teacher.safeAbout
                )

                // MARK: - МАРАПАТТАР
                sectionCard(
                    title: "МАРАПАТТАР",
                    content: teacher.safeAchievementsText
                )

                // MARK: - СЕРТИФИКАТТАР
                sectionCard(
                    title: "СЕРТИФИКАТТАР",
                    content: teacher.safeCertificatesText
                )

                // MARK: - ӘЛЕУМЕТТІК ЖЕЛІЛЕР
                sectionCard(
                    title: "ӘЛЕУМЕТТІК ЖЕЛІЛЕР",
                    content: teacher.safeSocialLinksText
                )

                Spacer()
            }
            .padding(.horizontal, 16)
        }
        .background(Color.mintSoft.opacity(0.25))
        .navigationTitle("Мұғалім профилі")
        .onAppear {
            print("🔵 ADMIN achievements:", teacher.achievements ?? "nil")
        }
    } // ← ← ← МІНЕ ОСЫ `}` ЖЕТПЕЙ ТҰРҒАН

    // MARK: - Avatar section
    private var avatarSection: some View {
        Group {
            if let data = teacher.profilePhoto,
               let image = UIImage(data: data) {

                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .shadow(color: Color.mintDark.opacity(0.35), radius: 12)

            } else {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 150, height: 150)
                        .shadow(color: Color.mintDark.opacity(0.35), radius: 12)

                    Text(initials(of: teacher.safeName))
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.mintDark)
                }
            }
        }
    }

    // MARK: - INFO CARD
    func infoCard(title: String, items: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundColor(.mintDark)

            ForEach(items, id: \.0) { item in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(item.0 + ":")
                            .foregroundColor(.mintDark)
                            .fontWeight(.medium)
                        Spacer()
                        Text(item.1)
                            .foregroundColor(.black)
                    }
                    Divider()
                        .background(Color.mintDark.opacity(0.25))
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(26)
        .shadow(color: Color.mintDark.opacity(0.12), radius: 12)
    }

    // MARK: - SECTION CARD
    func sectionCard(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.mintDark)

            Text(content)
                .foregroundColor(.gray)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(26)
        .shadow(color: Color.mintDark.opacity(0.12), radius: 12)
    }

    // MARK: - Initials
    func initials(of name: String) -> String {
        name.split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }
            .map(String.init)
            .joined()
    }
}
