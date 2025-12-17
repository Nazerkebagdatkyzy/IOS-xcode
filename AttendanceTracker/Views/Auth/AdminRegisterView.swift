import SwiftUI
import CoreData

struct AdminRegisterView: View {

    @Environment(\.managedObjectContext) private var viewContext

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""

    @State private var selectedCity = ""
    @State private var selectedRegion = ""
    @State private var selectedSchoolID = ""

    @State private var regions: [String] = []
    @State private var schools: [String] = []

    @State private var success = false
    @State private var error = false

    var body: some View {

        ZStack {
            // EMERALD BACKGROUND
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
                VStack(spacing: 28) {

                    // TITLE
                    Text("Админ тіркелу")
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

                    // INPUTS
                    EmeraldField(title: "Аты", placeholder: "Аты-жөніңіз", text: $name)
                    EmeraldField(title: "Email", placeholder: "Email енгізіңіз", text: $email)
                    EmeraldSecureField(title: "Құпия сөз", placeholder: "Құпия сөз", text: $password)

                    // CITY
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

                    // REGION
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

                    // SCHOOL
                    if !schools.isEmpty {
                        EmeraldPicker(
                            title: "Мектеп",
                            selection: $selectedSchoolID,
                            options: schools,
                            displayMap: { schoolName(for: $0) }
                        )
                    }

                    // REGISTER BUTTON
                    Button(action: registerAdmin) {
                        Text("Админді тіркеу")
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
                            .shadow(color: .black.opacity(0.25), radius: 10, y: 5)
                    }
                    .padding(.top, 10)

                    if success { Text("Сәтті тіркелді!").foregroundColor(.green).bold() }
                    if error { Text("Барлық өрісті толтырыңыз!").foregroundColor(.red) }

                    Spacer()
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: REGISTER ADMIN
    private func registerAdmin() {

        guard !name.isEmpty,
              !email.isEmpty,
              !password.isEmpty,
              !selectedSchoolID.isEmpty else {
            error = true
            return
        }

        // FIND SCHOOL by ID
        let req: NSFetchRequest<School> = School.fetchRequest()
        req.predicate = NSPredicate(format: "id == %@", selectedSchoolID)

        guard let school = try? viewContext.fetch(req).first else {
            error = true
            return
        }

        let admin = SchoolAdmin(context: viewContext)
        admin.id = UUID()
        admin.name = name
        admin.email = email
        admin.passwordHash = password

        admin.schoolID = school.id
        admin.school = school

        try? viewContext.save()
        success = true
    }
    // MARK: - Helpers

    func schoolName(for id: String) -> String {
        let req: NSFetchRequest<School> = School.fetchRequest()
        req.predicate = NSPredicate(format: "id == %@", id)
        return (try? viewContext.fetch(req).first)?.name ?? id
    }

    func loadCities() -> [String] {
        let req: NSFetchRequest<School> = School.fetchRequest()
        let schools = (try? viewContext.fetch(req)) ?? []
        return Array(Set(schools.map { $0.city ?? "" })).sorted()
    }

    func loadRegions(for city: String) -> [String] {
        let req: NSFetchRequest<School> = School.fetchRequest()
        req.predicate = NSPredicate(format: "city == %@", city)
        let schools = (try? viewContext.fetch(req)) ?? []
        return Array(Set(schools.map { $0.region ?? "" })).sorted()
    }

    func loadSchools(for city: String, region: String) -> [String] {
        let req: NSFetchRequest<School> = School.fetchRequest()
        req.predicate = NSPredicate(
            format: "city == %@ AND region == %@", city, region
        )
        let schools = (try? viewContext.fetch(req)) ?? []
        return schools.map { $0.id ?? "" }
    }

    
}

