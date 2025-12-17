import SwiftUI
import CoreData

struct TeacherRegisterView: View {

    @Environment(\.managedObjectContext) private var viewContext

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""

    @State private var selectedCity = ""
    @State private var selectedRegion = ""
    @State private var selectedSchoolID = ""
    @State private var selectedSchoolName = ""


    @State private var regions: [String] = []
    @State private var schools: [String] = []

    @State private var showSuccess = false
    @State private var showError = false

    var body: some View {

        ZStack {
            // 🌑 ҚОЮ EMERALD BACKGROUND → StartView-пен бірдей
            LinearGradient(
                colors: [
                    Color(#colorLiteral(red: 0.02, green: 0.20, blue: 0.17, alpha: 1)),
                    Color(#colorLiteral(red: 0.00, green: 0.16, blue: 0.14, alpha: 1))
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 26) {

                    // TITLE
                    Text("Мұғалім тіркелу")
                        .font(.system(size: 30, weight: .bold))
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
                        .padding(.top, 10)

                    // FIELDS ★ Emerald Style
                    EmeraldField(title: "Аты-жөні", placeholder: "Аты-жөніңіз", text: $name)
                    EmeraldField(title: "Email", placeholder: "Email енгізіңіз", text: $email)
                    EmeraldSecureField(title: "Құпия сөз", placeholder: "Құпия сөз", text: $password)

                    // CITY PICKER
                    EmeraldPicker(
                        title: "Қала",
                        selection: $selectedCity,
                        options: loadCities()
                    )
                    .onChange(of: selectedCity) {
                        regions = loadRegions(for: selectedCity)
                        selectedRegion = ""
                        selectedSchoolID = ""
                    }

                    // REGION PICKER
                    if !regions.isEmpty {
                        EmeraldPicker(
                            title: "Аймақ",
                            selection: $selectedRegion,
                            options: regions
                        )
                        .onChange(of: selectedRegion) {
                            schools = loadSchools(for: selectedCity, region: selectedRegion)
                            selectedSchoolID = ""
                        }
                    }

                    // SCHOOL PICKER
                    if !schools.isEmpty {
                        EmeraldPicker(
                            title: "Мектеп",
                            selection: $selectedSchoolName,
                            options: schools
                        )
                        .onChange(of: selectedSchoolName) {
                            selectedSchoolID = schoolID(forName: selectedSchoolName)
                        }

                    }

                    // REGISTER BUTTON
                    Button(action: registerTeacher) {
                        Text("Тіркелу")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(#colorLiteral(red: 0.71, green: 0.96, blue: 0.87, alpha: 1)),
                                        Color(#colorLiteral(red: 0.63, green: 0.94, blue: 0.88, alpha: 1))
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .foregroundColor(.black.opacity(0.9))
                            .cornerRadius(18)
                            .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
                    }
                    .padding(.top, 15)

                    if showSuccess { Text("Мұғалім сәтті тіркелді!").foregroundColor(.green).bold() }
                    if showError { Text("Барлық өрісті толтырыңыз!").foregroundColor(.red) }

                    Spacer()
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: Register
    func registerTeacher() {

        print("DEBUG 👉", name, email, password, selectedCity, selectedRegion, selectedSchoolID)

        guard
            !name.isEmpty,
            !email.isEmpty,
            !password.isEmpty,
            !selectedCity.isEmpty,
            !selectedRegion.isEmpty,
            !selectedSchoolID.isEmpty
        else {
            showError = true
            return
        }

        let req: NSFetchRequest<School> = School.fetchRequest()
        req.predicate = NSPredicate(format: "id == %@", selectedSchoolID)

        guard let foundSchool = try? viewContext.fetch(req).first else {
            showError = true
            print("❌ School not found by ID")
            return
        }

        let teacher = Teacher(context: viewContext)
        teacher.id = UUID()
        teacher.name = name
        teacher.email = email
        teacher.passwordHash = password
        teacher.city = selectedCity
        teacher.region = selectedRegion
        teacher.schoolID = selectedSchoolID
        teacher.school = foundSchool

        try? viewContext.save()
        showSuccess = true
    }

    
    func schoolID(forName name: String) -> String {
        let req: NSFetchRequest<School> = School.fetchRequest()
        req.predicate = NSPredicate(format: "name == %@", name)

        let school = try? viewContext.fetch(req).first
        return school?.id ?? ""
    }

}

//
// MARK: — REUSABLE COMPONENTS
//

struct EmeraldField: View {
    let title: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {

            Text(title)
                .foregroundColor(.white.opacity(0.85))
                .font(.headline)

            TextField(placeholder, text: $text)
                .padding()
                .background(Color.white.opacity(0.12))
                .cornerRadius(14)
                .foregroundColor(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                )
        }
    }
}

struct EmeraldSecureField: View {
    let title: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {

            Text(title)
                .foregroundColor(.white.opacity(0.85))
                .font(.headline)

            SecureField(placeholder, text: $text)
                .padding()
                .background(Color.white.opacity(0.12))
                .cornerRadius(14)
                .foregroundColor(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                )
        }
    }
}

struct EmeraldPicker: View {
    let title: String
    @Binding var selection: String
    let options: [String]
    var displayMap: ((String) -> String)? = nil

    var body: some View {

        VStack(alignment: .leading, spacing: 6) {

            Text(title)
                .foregroundColor(.white.opacity(0.85))
                .font(.headline)

            Menu {
                ForEach(options, id: \.self) { item in
                    Button { selection = item } label: {
                        Text(displayMap?(item) ?? item)
                    }
                }
            } label: {
                HStack {
                    Text(
                        selection.isEmpty
                        ? "Таңдаңыз"
                        : (displayMap?(selection) ?? selection)
                    )
                    .foregroundColor(.white.opacity(selection.isEmpty ? 0.5 : 1))

                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding()
                .background(Color.white.opacity(0.12))
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                )
            }
        }
    }
}
