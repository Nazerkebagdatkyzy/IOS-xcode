import SwiftUI
import CoreData

struct TeacherRegisterView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""

    @State private var selectedCity = ""
    @State private var selectedRegion = ""
    @State private var selectedSchoolID = ""   // ← ID сақталады

    @State private var regions: [String] = []
    @State private var schools: [String] = []

    @State private var showSuccess = false
    @State private var showError = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                
                Text("Мұғалім тіркелу")
                    .font(.title2).bold()

                TextField("Аты-жөні", text: $name)
                    .padding().background(Color(.secondarySystemBackground)).cornerRadius(10)

                TextField("Email", text: $email)
                    .padding().background(Color(.secondarySystemBackground)).cornerRadius(10)

                SecureField("Құпия сөз", text: $password)
                    .padding().background(Color(.secondarySystemBackground)).cornerRadius(10)

                // CITY
                Picker("Қала", selection: $selectedCity) {
                    ForEach(loadCities(), id: \.self) { city in
                        Text(city)
                    }
                }
                .onChange(of: selectedCity) {
                    regions = loadRegions(for: selectedCity)
                    selectedRegion = ""
                    selectedSchoolID = ""
                }

                // REGION
                if !regions.isEmpty {
                    Picker("Аймақ", selection: $selectedRegion) {
                        ForEach(regions, id: \.self) { region in
                            Text(region)
                        }
                    }
                    .onChange(of: selectedRegion) {
                        schools = loadSchools(for: selectedCity, region: selectedRegion)
                        selectedSchoolID = ""
                    }
                }

                // SCHOOL (ID LIST)
                if !schools.isEmpty {
                    Picker("Мектеп", selection: $selectedSchoolID) {
                        ForEach(schools, id: \.self) { schoolID in
                            Text(schoolName(for: schoolID))
                                .tag(schoolID)
                        }
                    }
                }

                Button("Тіркелу") {
                    registerTeacher()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                if showSuccess { Text("Мұғалім сәтті тіркелді!").foregroundColor(.green) }
                if showError { Text("Барлық өрісті толтырыңыз!").foregroundColor(.red) }

                Spacer()
            }
            .padding()
        }
    }

    // MARK: - REGISTER TEACHER (correct version)
    func registerTeacher() {
        guard !name.isEmpty,
              !email.isEmpty,
              !password.isEmpty,
              !selectedSchoolID.isEmpty else {
            showError = true
            return
        }

        // 1️⃣ Мектепті оның ID бойынша Core Data-дан табамыз
        let req: NSFetchRequest<School> = School.fetchRequest()
        req.predicate = NSPredicate(format: "id == %@", selectedSchoolID)

        guard let foundSchool = try? viewContext.fetch(req).first else {
            print("❌ School not found")
            showError = true
            return
        }

        // 2️⃣ Мұғалім жасаймыз
        let teacher = Teacher(context: viewContext)
        teacher.id = UUID()
        teacher.name = name
        teacher.email = email
        teacher.passwordHash = password
        teacher.city = selectedCity
        teacher.region = selectedRegion
        teacher.schoolID = selectedSchoolID

        // 3️⃣ ЕҢ МАҢЫЗДЫ ЖЕР: RELATIONSHIP
        teacher.school = foundSchool

        // 4️⃣ Сақтау
        try? viewContext.save()
        showSuccess = true

        print("🎉 NEW TEACHER CREATED")
        print("Teacher linked school:", teacher.school?.name ?? "nil")
    }
}
