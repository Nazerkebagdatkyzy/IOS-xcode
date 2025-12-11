import SwiftUI
import PhotosUI

struct AchievementsEditorView: View {

    @Binding var items: [[String: Any]]

    @State private var newTitle: String = ""
    @State private var selectedPickerItem: PhotosPickerItem?
    @State private var newPhotoData: Data?

    // Full screen preview
    @State private var selectedImage: UIImage?
    @State private var showFullScreen = false

    var body: some View {

        ZStack {
            // ---------- Background ----------
            LinearGradient(
                colors: [Color.white.opacity(0.5),
                         Color.green.opacity(0.07)],
                startPoint: .top,
                endPoint: .bottom
            ).ignoresSafeArea()

            VStack(spacing: 16) {

                // =====================================================
                //                  INPUT BAR
                // =====================================================
                HStack(spacing: 12) {

                    TextField("Марапат атауы", text: $newTitle)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)

                    PhotosPicker(selection: $selectedPickerItem, matching: .images) {
                        Image(systemName: "photo")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                            .padding(10)
                            .background(Color(.systemGray5))
                            .cornerRadius(12)
                    }
                    .onChange(of: selectedPickerItem) { item in
                        Task { @MainActor in
                            if let item = item,
                               let data = try? await item.loadTransferable(type: Data.self) {
                                newPhotoData = data
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }
                        }
                    }

                    Button("Қосу") { addAchievement() }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)

                // =====================================================
                //                  LIST VIEW (Swipe Delete)
                // =====================================================
                List {
                    ForEach(Array(items.indices), id: \.self) { idx in
                        itemCard(idx: idx)
                            .listRowSeparator(.hidden)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    deleteAchievement(idx: idx)
                                } label: {
                                    Label {
                                        Text("Өшіру")
                                    } icon: {
                                        Image(systemName: "trash")
                                    }
                                }
                            }
                    }

                    // ❌ ТАЛАП БОЙЫНША АЛДЫМ
                    // .onMove(perform: moveItem)
                }
                .listStyle(.plain)

                Spacer()
            }

        }
        .navigationTitle("Марапаттар")
        .navigationBarTitleDisplayMode(.inline)

        // ❌ ТАЛАП БОЙЫНША АЛДЫМ
        // .toolbar { EditButton() }

        .fullScreenCover(isPresented: $showFullScreen) {
            if let img = selectedImage {
                ImageFullScreenView(image: img, show: $showFullScreen)
            }
        }
    }

    // =====================================================
    //                   ITEM CARD VIEW
    // =====================================================
    @ViewBuilder
    func itemCard(idx: Int) -> some View {

        HStack(spacing: 14) {

            if let data = items[idx]["photo"] as? Data,
               let img = UIImage(data: data) {

                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 58, height: 58)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .onTapGesture {
                        selectedImage = img
                        showFullScreen = true
                    }
                    .shadow(radius: 3)

            } else {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 58, height: 58)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }

            Text(items[idx]["title"] as? String ?? "")
                .font(.system(size: 17, weight: .medium))

            Spacer()
        }
        .padding(14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.06), radius: 6, y: 4)
    }

    // =====================================================
    //                  ADD ITEM
    // =====================================================
    func addAchievement() {
        let title = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }

        var dict: [String: Any] = ["title": title]
        if let data = newPhotoData { dict["photo"] = data }

        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            items.append(dict)
        }

        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        newTitle = ""
        newPhotoData = nil
        selectedPickerItem = nil
    }

    // =====================================================
    //                 DELETE ITEM
    // =====================================================
    func deleteAchievement(idx: Int) {
        withAnimation(.easeInOut) { items.remove(at: idx) }
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
    }

    // =====================================================
    //         MOVE FUNCTION (енді қолданылмайды)
    // =====================================================
    func moveItem(from: IndexSet, to: Int) {
        items.move(fromOffsets: from, toOffset: to)
    }
}

//
// =====================================================
//      FULL SCREEN IMAGE VIEW
// =====================================================
//
struct ImageFullScreenView: View {

    var image: UIImage
    @Binding var show: Bool

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .onTapGesture { show = false }
        }
    }
}
