import SwiftUI
import PhotosUI

struct AchievementsEditorView: View {
    @Binding var items: [[String: Any]]

    @State private var newTitle: String = ""
    @State private var selectedPickerItem: PhotosPickerItem?
    @State private var newPhotoData: Data?

    var body: some View {
        ZStack {
            backgroundView
            contentView
        }
        .navigationTitle("Марапаттар")
        .onChange(of: selectedPickerItem) { loadSelectedImage($0) }
    }
}

private extension AchievementsEditorView {

    // ------------------ BACKGROUND ------------------
    var backgroundView: some View {
        LinearGradient(
            colors: [
                Color.white.opacity(0.5),
                Color.green.opacity(0.08)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    // ------------------ MAIN CONTENT ------------------
    var contentView: some View {
        VStack(spacing: 16) {
            inputBar
            achievementsList
            Spacer()
        }
    }

    // ------------------ INPUT BAR ------------------
    var inputBar: some View {
        HStack(spacing: 12) {

            TextField("Марапат атауы", text: $newTitle)
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            PhotosPicker(selection: $selectedPickerItem, matching: .images) {
                Image(systemName: "photo")
                    .font(.title3)
                    .padding(10)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Button("Қосу") { addAchievement() }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding(.horizontal)
    }

    // ------------------ ACHIEVEMENTS LIST ------------------
    var achievementsList: some View {
        List {
            ForEach(items.indices, id:\.self) { idx in
                achievementRow(idx: idx)
            }
            .onDelete { offsets in deleteItems(at: offsets) }
        }
        .scrollContentBackground(.hidden)
    }

    // ------------------ SINGLE ROW ------------------
    func achievementRow(idx: Int) -> some View {
        HStack(spacing: 12) {

            if let data = items[idx]["photo"] as? Data,
               let ui = UIImage(data: data) {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 48, height: 48)
            }

            Text(items[idx]["title"] as? String ?? "")
                .font(.headline)

            Spacer()

            Button(role: .destructive) {
                withAnimation(.easeInOut) {
                    // remove using IndexSet to avoid overload ambiguity
                    deleteItems(at: IndexSet(integer: idx))
                }
            } label: {
                Image(systemName: "trash")
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
        }
        .padding(.vertical, 6)
    }

    // ------------------ ACTIONS ------------------

    func addAchievement() {
        guard !newTitle.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        var dict: [String: Any] = ["title": newTitle]
        if let d = newPhotoData { dict["photo"] = d }

        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            items.append(dict)
        }

        newTitle = ""
        newPhotoData = nil
        selectedPickerItem = nil
    }

    func deleteItems(at offsets: IndexSet) {
        withAnimation(.easeInOut) {
            items.remove(atOffsets: offsets)
        }
    }

    func loadSelectedImage(_ item: PhotosPickerItem?) {
        Task { @MainActor in
            guard let item else { return }
            if let d = try? await item.loadTransferable(type: Data.self) {
                newPhotoData = d
            }
        }
    }
}
