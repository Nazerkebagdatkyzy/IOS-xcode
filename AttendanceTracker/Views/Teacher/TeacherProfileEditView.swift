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
    @State private var showAchievementsEditor = false
    @State private var showCertificatesEditor = false
    @State private var showSocialLinksEditor = false

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

                    VStack(spacing: 8) {
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            ZStack {
                                if let img = avatarImage {
                                    Image(uiImage: img)
                                        .resizable()
                                        .scaledToFill()
                                } else if let data = teacher.profilePhoto,
                                          let img = UIImage(data: data) {
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

                    SectionCard(title: "Өзі туралы") {
                        TextEditor(text: $aboutText)
                            .frame(height: 130)
                            .padding(10)
                            .background(Color.white)
                            .cornerRadius(12)
                    }

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

                    SectionCard(title: "Дағдылары") {
                        TagsInputView(tags: $skillsTags)
                    }

                    SectionCard(title: "Марапаттар") {
                        VStack(alignment: .leading, spacing: 10) {

                            Button("Басқару") { showAchievementsEditor = true }
                                .foregroundColor(.blue)
                                .sheet(isPresented: $showAchievementsEditor) {
                                    NavigationView {
                                        AchievementsEditorView(items: $achievementsArray)
                                            .navigationBarTitle("Марапаттар", displayMode: .inline)
                                            .toolbar {
                                                ToolbarItem(placement: .navigationBarLeading) {
                                                    Button { showAchievementsEditor = false } label: {
                                                        Image(systemName: "chevron.backward")
                                                            .foregroundColor(.blue)
                                                    }
                                                }
                                            }
                                    }
                                }

                            if achievementsArray.isEmpty {
                                Text("Мәлімет жоқ").foregroundColor(.gray)
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

                    SectionCard(title: "Сертификаттар") {
                        VStack(alignment: .leading, spacing: 10) {

                            Button("Басқару") { showCertificatesEditor = true }
                                .foregroundColor(.blue)
                                .sheet(isPresented: $showCertificatesEditor) {
                                    NavigationView {
                                        EditableListView(title: "Сертификаттар", items: $certificates)
                                            .navigationBarTitle("Сертификаттар", displayMode: .inline)
                                            .toolbar {
                                                ToolbarItem(placement: .navigationBarLeading) {
                                                    Button { showCertificatesEditor = false } label: {
                                                        Image(systemName: "chevron.backward")
                                                            .foregroundColor(.blue)
                                                    }
                                                }
                                            }
                                    }
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

                    SectionCard(title: "Әлеуметтік желілер") {
                        VStack(alignment: .leading, spacing: 10) {

                            Button("Басқару") { showSocialLinksEditor = true }
                                .foregroundColor(.blue)
                                .sheet(isPresented: $showSocialLinksEditor) {
                                    NavigationView {
                                        EditableListView(title: "Әлеуметтік желілер", items: $socialLinks)
                                            .navigationBarTitle("Әлеуметтік желілер", displayMode: .inline)
                                            .toolbar {
                                                ToolbarItem(placement: .navigationBarLeading) {
                                                    Button { showSocialLinksEditor = false } label: {
                                                        Image(systemName: "chevron.backward")
                                                            .foregroundColor(.blue)
                                                    }
                                                }
                                            }
                                    }
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

                    HStack(spacing: 16) {

                        Button { saveProfile() } label: {
                            Text("Сақтау")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green.opacity(0.75))
                                .foregroundColor(.white)
                                .cornerRadius(14)
                        }

                        Button { generatePDFandShare() } label: {
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
                    if let url = generatedPDFURL { ShareSheet(activityItems: [url]) }
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

        achievementsArray = []
        if let arr = teacher.achievements as? [NSDictionary] {
            achievementsArray = arr.compactMap { dict in
                var result: [String: Any] = [:]
                for (k, v) in dict {
                    if let key = k as? String { result[key] = v }
                }
                return result
            }
        } else if let arr = teacher.achievements as? [[String: Any]] {
            achievementsArray = arr
        }

        if let data = teacher.profilePhoto {
            avatarImage = UIImage(data: data)
        }
    }

    // MARK: - Save
    func saveProfile() {
        teacher.aboutMe = aboutText
        teacher.education = educationText
        teacher.experience = experienceValue
        teacher.skills = skillsTags.joined(separator: ", ")
        teacher.certificates = certificates as NSArray
        teacher.socialLinks = socialLinks as NSArray
        teacher.achievements = achievementsArray.map { $0 as NSDictionary } as NSArray
        print("🟢 SAVE TEACHER ID:", teacher.objectID)
        print("🟢 SAVE achievements:", teacher.achievements ?? "nil")

        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("❌ Save error:", error)
        }
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
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 8)
        .padding(.horizontal)
        .transition(.opacity.combined(with: .scale))
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: title)
    }
}

