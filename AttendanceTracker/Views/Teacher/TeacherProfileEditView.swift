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
    @Environment(\.presentationMode) var presentationMode

    // Photo picker
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var avatarImage: UIImage?

    // Local editable copies (so UI is snappy)
    @State private var aboutText = ""
    @State private var educationText = ""
    @State private var experienceValue: Int16 = 0
    @State private var skillsTags: [String] = []
    @State private var certificates: [String] = []
    @State private var socialLinks: [String] = []

    // Achievements: array of dictionaries: ["title": String, "photo": Data?]
    @State private var achievementsArray: [[String: Any]] = []

    // PDF sheet
    @State private var showShare = false
    @State private var generatedPDFURL: URL?

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                // Avatar
                VStack {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        if let img = avatarImage {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .shadow(radius: 6)
                        } else if let data = teacher.profilePhoto, let img = UIImage(data: data) {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .shadow(radius: 6)
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.12))
                                .frame(width: 120, height: 120)
                                .overlay(Text(initials(of: teacher.name ?? "")))
                                .shadow(radius: 6)
                        }
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
                    .padding(.bottom, 6)
                }

                // Name + Email (read-only)
                VStack(spacing: 4) {
                    Text(teacher.name ?? "Аты белгісіз")
                        .font(.title2)
                        .bold()
                    Text(teacher.email ?? "Email жоқ")
                        .foregroundColor(.gray)
                }

                // About
                VStack(alignment: .leading) {
                    Text("Өзі туралы").font(.headline)
                    TextEditor(text: $aboutText)
                        .frame(minHeight: 120)
                        .padding(8)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .cornerRadius(10)
                }.padding(.horizontal)

                // Education + Experience + Skills tags
                VStack(alignment: .leading, spacing: 12) {
                    Text("Білімі").font(.headline)
                    TextField("Білімі", text: $educationText)
                        .textFieldStyle(.roundedBorder)

                    HStack {
                        Text("Өтілі: \(experienceValue) жыл").font(.headline)
                        Spacer()
                    }
                    Stepper("", value: $experienceValue, in: 0...50)

                    Text("Дағдылары").font(.headline)
                    TagsInputView(tags: $skillsTags)
                }
                .padding(.horizontal)

                // Achievements editor
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Марапаттар").font(.headline)
                        Spacer()
                        NavigationLink("Басқару") {
                            AchievementsEditorView(items: $achievementsArray)
                                .environment(\.managedObjectContext, viewContext)
                        }
                    }

                    if achievementsArray.isEmpty {
                        Text("Мәлімет жоқ").foregroundColor(.gray)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing:10) {
                                ForEach(achievementsArray.indices, id: \.self) { idx in
                                    VStack {
                                        if let d = achievementsArray[idx]["photo"] as? Data, let img = UIImage(data: d) {
                                            Image(uiImage: img)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 86, height: 86)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                        } else {
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.1))
                                                .frame(width: 86, height: 86)
                                                .cornerRadius(8)
                                        }
                                        Text(achievementsArray[idx]["title"] as? String ?? "")
                                            .font(.caption)
                                            .frame(maxWidth: 86)
                                            .multilineTextAlignment(.center)
                                    }
                                }
                            }.padding(.vertical, 6)
                        }
                    }
                }
                .padding(.horizontal)

                // Certificates
                VStack(alignment:.leading) {
                    HStack {
                        Text("Сертификаттар").font(.headline)
                        Spacer()
                        NavigationLink("Басқару") {
                            EditableListView(title: "Сертификаттар", items: $certificates)
                        }
                    }
                    if certificates.isEmpty { Text("Мәлімет жоқ").foregroundColor(.gray) }
                    else {
                        ForEach(certificates, id:\.self) { c in
                            Text("• \(c)").lineLimit(1)
                        }
                    }
                }
                .padding(.horizontal)

                // Social links
                VStack(alignment:.leading) {
                    HStack {
                        Text("Әлеуметтік желілер").font(.headline)
                        Spacer()
                        NavigationLink("Басқару") {
                            EditableListView(title:"Әлеуметтік желілер", items: $socialLinks)
                        }
                    }
                    if socialLinks.isEmpty { Text("Мәлімет жоқ").foregroundColor(.gray) }
                    else {
                        ForEach(socialLinks, id:\.self) { s in
                            Text(s).lineLimit(1).foregroundColor(.blue)
                        }
                    }
                }
                .padding(.horizontal)

                // Buttons: Save, Generate PDF
                HStack(spacing: 12) {
                    Button("Сақтау") {
                        saveProfile()
                    }
                    .buttonStyle(.borderedProminent)

                    Button("PDF жасау") {
                        generatePDFandShare()
                    }
                    .buttonStyle(.bordered)
                }
                .padding()

                Spacer()
            }
            .padding(.top)
            .onAppear { loadInitial() }
            .sheet(isPresented: $showShare) {
                if let url = generatedPDFURL {
                    ShareSheet(activityItems: [url])
                }
            }
        }
        .navigationTitle("Профильді өзгерту")
    }

    // MARK: - Load initial values from teacher
    func loadInitial() {
        aboutText = teacher.aboutMe ?? ""
        educationText = teacher.education ?? ""
        experienceValue = teacher.experience
        // skills stored as comma separated string in CoreData
        skillsTags = (teacher.skills ?? "").split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        certificates = (teacher.certificates as? [String]) ?? []
        socialLinks = (teacher.socialLinks as? [String]) ?? []
        // achievements - stored as NSArray of NSDictionary-like objects
        if let arr = teacher.achievements as? [[String: Any]] {
            achievementsArray = arr
        } else {
            achievementsArray = []
        }
        if let data = teacher.profilePhoto { avatarImage = UIImage(data: data) }
    }

    // MARK: - Save back to CoreData
    func saveProfile() {
        teacher.aboutMe = aboutText
        teacher.education = educationText
        teacher.experience = experienceValue
        teacher.skills = skillsTags.joined(separator: ", ")
        // certificates & socialLinks as NSArray
        teacher.certificates = certificates as NSArray
        teacher.socialLinks = socialLinks as NSArray
        // achievementsArray -> NSArray
        teacher.achievements = achievementsArray as NSArray
        do {
            try viewContext.save()
            // dismiss
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Save error:", error)
        }
    }

    // MARK: - PDF Generation
    func generatePDFandShare() {
        // build simple PDF using PDFExporter helper
        let exporter = PDFExporter()
        if let url = exporter.exportTeacherResumeToPDF(teacher: teacher,
                                                       profileImage: avatarImage,
                                                       about: aboutText,
                                                       education: educationText,
                                                       experience: Int(experienceValue),
                                                       skills: skillsTags,
                                                       achievements: achievementsArray,
                                                       certificates: certificates,
                                                       socialLinks: socialLinks) {
            generatedPDFURL = url
            showShare = true
        }
    }

    // Helpers
    func initials(of name: String) -> String {
        let parts = name.split(separator: " ")
        return parts.prefix(2).compactMap { $0.first }.map(String.init).joined()
    }
}
