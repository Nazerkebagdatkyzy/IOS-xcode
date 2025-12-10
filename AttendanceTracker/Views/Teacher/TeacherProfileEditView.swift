//
//  TeacherProfileEditView.swift
//

import SwiftUI
import PhotosUI
import CoreData
import UIKit

struct TeacherProfileEditView: View {

    @ObservedObject var teacher: Teacher
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    // Photo picker
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var avatarImage: UIImage?

    // Editable fields
    @State private var aboutText = ""
    @State private var educationText = ""
    @State private var experienceValue: Int16 = 0
    @State private var skillsTags: [String] = []
    @State private var certificates: [String] = []
    @State private var socialLinks: [String] = []
    @State private var achievementsArray: [[String: Any]] = []

    // PDF
    @State private var showShare = false
    @State private var generatedPDFURL: URL?

    var body: some View {

        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(#colorLiteral(red: 0.93, green: 1.0, blue: 0.96, alpha: 1)),
                    Color(#colorLiteral(red: 0.86, green: 1.0, blue: 0.93, alpha: 1))
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 22) {

                    // ----------------- AVATAR -----------------
                    VStack(spacing: 8) {
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            ZStack {
                                if let img = avatarImage {
                                    Image(uiImage: img)
                                        .resizable()
                                        .scaledToFill()
                                } else if let data = teacher.profilePhoto, let img = UIImage(data: data) {
                                    Image(uiImage: img)
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .foregroundColor(.gray.opacity(0.5))
                                }
                            }
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.2), radius: 6)
                        }
                        .onChange(of: selectedPhoto) { newItem in
                            Task { @MainActor in
                                if let item = newItem,
                                   let data = try? await item.loadTransferable(type: Data.self) {
                                    teacher.profilePhoto = data
                                    avatarImage = UIImage(data: data)
                                }
                            }
                        }

                        Text(teacher.name ?? "Аты белгісіз")
                            .font(.title2)
                            .bold()

                        Text(teacher.email ?? "Email жоқ")
                            .foregroundColor(.gray)
                    }

                    // ----------------- ABOUT -----------------
                    SectionCard(title: "Өзі туралы") {
                        TextEditor(text: $aboutText)
                            .frame(height: 130)
                            .padding(10)
                            .background(Color.white)
                            .cornerRadius(12)
                    }

                    // ----------------- EDUCATION & EXPERIENCE -----------------
                    SectionCard(title: "Білімі және өтілі") {

                        VStack(alignment: .leading, spacing: 14) {

                            TextField("Білімі", text: $educationText)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)

                            HStack {
                                Text("Өтілі: \(experienceValue) жыл")
                                Spacer()
                                Stepper("", value: $experienceValue, in: 0...50)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                    }

                    // ----------------- SKILLS -----------------
                    SectionCard(title: "Дағдылары") {
                        TagsInputView(tags: $skillsTags)
                    }

                    // ----------------- ACHIEVEMENTS -----------------
                    SectionCard(title: "Марапаттар") {
                        VStack(alignment: .leading, spacing: 10) {

                            NavigationLink("Басқару") {
                                AchievementsEditorView(items: $achievementsArray)
                                    .environment(\.managedObjectContext, viewContext)
                            }

                            if achievementsArray.isEmpty {
                                Text("Мәлімет жоқ")
                                    .foregroundColor(.gray)
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(achievementsArray.indices, id: \.self) { idx in
                                            VStack {
                                                if let d = achievementsArray[idx]["photo"] as? Data,
                                                   let img = UIImage(data: d) {
                                                    Image(uiImage: img)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 80, height: 80)
                                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                                }
                                                Text(achievementsArray[idx]["title"] as? String ?? "")
                                                    .font(.caption)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // ----------------- CERTIFICATES -----------------
                    SectionCard(title: "Сертификаттар") {
                        VStack(alignment: .leading, spacing: 10) {

                            NavigationLink("Басқару") {
                                EditableListView(title: "Сертификаттар", items: $certificates)
                            }

                            if certificates.isEmpty {
                                Text("Мәлімет жоқ").foregroundColor(.gray)
                            } else {
                                ForEach(certificates, id: \.self) { c in
                                    Text("• \(c)")
                                }
                            }
                        }
                    }

                    // ----------------- SOCIAL LINKS -----------------
                    SectionCard(title: "Әлеуметтік желілер") {
                        VStack(alignment: .leading, spacing: 10) {

                            NavigationLink("Басқару") {
                                EditableListView(title: "Әлеуметтік желілер", items: $socialLinks)
                            }

                            if socialLinks.isEmpty {
                                Text("Мәлімет жоқ").foregroundColor(.gray)
                            } else {
                                ForEach(socialLinks, id: \.self) { s in
                                    Text(s).foregroundColor(.blue)
                                }
                            }
                        }
                    }

                    // ----------------- BUTTONS -----------------
                    HStack(spacing: 16) {

                        Button {
                            saveProfile()
                        } label: {
                            Text("Сақтау")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green.opacity(0.75))
                                .foregroundColor(.white)
                                .cornerRadius(14)
                        }

                        Button {
                            generatePDFandShare()
                        } label: {
                            Text("PDF")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .foregroundColor(.black)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.gray.opacity(0.3))
                                )
                        }
                    }
                    .padding(.horizontal)

                }
                .padding(.top, 22)
                .sheet(isPresented: $showShare) {
                    if let url = generatedPDFURL {
                        ShareSheet(activityItems: [url])
                    }
                }
                .onAppear { loadInitial() }
            }
        }
        .navigationTitle("Профильді өзгерту")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Load initial
    func loadInitial() {
        aboutText = teacher.aboutMe ?? ""
        educationText = teacher.education ?? ""
        experienceValue = teacher.experience
        skillsTags = (teacher.skills ?? "")
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
        certificates = teacher.certificates as? [String] ?? []
        socialLinks = teacher.socialLinks as? [String] ?? []
        achievementsArray = teacher.achievements as? [[String: Any]] ?? []
        if let data = teacher.profilePhoto { avatarImage = UIImage(data: data) }
    }

    // MARK: - Save
    func saveProfile() {
        teacher.aboutMe = aboutText
        teacher.education = educationText
        teacher.experience = experienceValue
        teacher.skills = skillsTags.joined(separator: ", ")
        teacher.certificates = certificates as NSArray
        teacher.socialLinks = socialLinks as NSArray
        teacher.achievements = achievementsArray as NSArray

        try? viewContext.save()
        dismiss()
    }

    // MARK: - PDF
    func generatePDFandShare() {
        let exporter = PDFExporter()
        if let url = exporter.exportTeacherResumeToPDF(
            teacher: teacher,
            profileImage: avatarImage,
            about: aboutText,
            education: educationText,
            experience: Int(experienceValue),
            skills: skillsTags,
            achievements: achievementsArray,
            certificates: certificates,
            socialLinks: socialLinks
        ) {
            generatedPDFURL = url
            showShare = true
        }
    }
}

// ------------------- SECTION CARD COMPONENT -------------------
struct SectionCard<Content: View>: View {

    var title: String
    var content: () -> Content

    var body: some View {

        VStack(alignment: .leading, spacing: 14) {

            Text(title)
                .font(.headline)
                .foregroundColor(.black.opacity(0.85))

            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        )
        .padding(.horizontal)
    }
}
