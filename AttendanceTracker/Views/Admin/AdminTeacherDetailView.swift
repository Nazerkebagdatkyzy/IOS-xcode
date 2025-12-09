//
//  AdminTeacherDetailView.swift
//  AttendanceTracker
//
//  Created by Nazerke Bagdatkyzy on 05.12.2025.
//
//

import SwiftUI
import Foundation

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
    
    var safeAchievements: [String] { achievements as? [String] ?? [] }
    var safeCertificates: [String] { certificates as? [String] ?? [] }
    var safeSocialLinks: [String] { socialLinks as? [String] ?? [] }
}

struct AdminTeacherDetailView: View {
    @ObservedObject var teacher: Teacher
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // MARK: - Photo
                if let data = teacher.profilePhoto,
                   let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 130, height: 130)
                        .clipShape(Circle())
                        .shadow(radius: 6)
                        .padding(.top, 20)
                } else {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 130, height: 130)
                            .shadow(radius: 6)
                        Text(initials(of: teacher.safeName))
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 20)
                }
                
                // MARK: - Name
                VStack(spacing: 6) {
                    Text(teacher.safeName)
                        .font(.title)
                        .bold()
                    Text(teacher.safeEmail)
                        .foregroundColor(.gray)
                }
                
                // MARK: - Basic Info
                infoCard(
                    title: "Жеке мәлімет",
                    items: [
                        ("Аты-жөні", teacher.safeName),
                        ("Email", teacher.safeEmail),
                        ("Телефон", teacher.phone ?? "Көрсетілмеген"),
                        ("Қала", teacher.safeCity),
                        ("Өңір", teacher.safeRegion),
                        ("Мектебі", teacher.safeSchool)
                    ]
                )
                
                // MARK: - Resume Section
                infoCard(
                    title: "Резюме",
                    items: [
                        ("Білімі", teacher.safeEducation),
                        ("Тәжірибесі", teacher.safeExperience),
                        ("Дағдылары", teacher.safeSkills)
                    ]
                )
                
                // MARK: - About Me
                longTextCard(
                    title: "Өзі туралы",
                    text: teacher.safeAbout
                )
                
                // MARK: - Achievements
                listCard(
                    title: "Марапаттар",
                    items: teacher.safeAchievements
                )
                
                // MARK: - Certificates
                listCard(
                    title: "Сертификаттар",
                    items: teacher.safeCertificates
                )
                
                // MARK: - Social Links
                listCard(
                    title: "Әлеуметтік желілер",
                    items: teacher.safeSocialLinks
                )
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Мұғалім профилі")
    }
    
    // MARK: - Info Card
    func infoCard(title: String, items: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .padding(.bottom, 5)
            
            ForEach(items, id: \.0) { item in
                HStack {
                    Text(item.0 + ":")
                        .foregroundColor(.gray)
                    Spacer()
                    Text(item.1)
                }
                Divider()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4)
    }
    
    // MARK: - Long Text Card
    func longTextCard(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            
            Text(text)
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
            
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4)
    }
    
    // MARK: - List Card
    func listCard(title: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            
            if items.isEmpty {
                Text("Мәлімет жоқ")
                    .foregroundColor(.gray)
            } else {
                ForEach(items, id: \.self) { item in
                    HStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                        
                        Text(item)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4)
    }
    
    // MARK: - Initials
    func initials(of name: String) -> String {
        let parts = name.split(separator: " ")
        return parts.prefix(2).compactMap { $0.first }.map(String.init).joined()
    }
}
