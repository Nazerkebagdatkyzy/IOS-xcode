//
//  TagsInputView.swift
//  AttendanceTracker
//
//  Created by Nazerke Bagdatkyzy on 09.12.2025.
//
import SwiftUI

struct TagsInputView: View {
    @Binding var tags: [String]
    @State private var newTag: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                TextField("Жаңа дағды қосу", text: $newTag)
                    .textFieldStyle(.roundedBorder)
                Button("Қосу") {
                    let t = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !t.isEmpty else { return }
                    tags.append(t)
                    newTag = ""
                }
            }
            FlowLayout(tags: tags, id: \.self) { tag in
                HStack(spacing:6) {
                    Text(tag)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(Color.blue.opacity(0.12))
                        .cornerRadius(16)
                    Button(action: {
                        if let i = tags.firstIndex(of: tag) { tags.remove(at: i) }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }.padding(.trailing, 4)
            }
        }
    }
}

// Simple flow layout for tags
struct FlowLayout<Data: RandomAccessCollection, Content: View, ID: Hashable>: View where Data.Element: Hashable {
    var tags: Data
    var id: KeyPath<Data.Element, ID>
    var content: (Data.Element) -> Content

    init(tags: Data, id: KeyPath<Data.Element, ID>, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.tags = tags
        self.id = id
        self.content = content
    }

    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
            .frame(minHeight: 10)
        }
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(Array(tags), id: id) { item in
                content(item)
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading) { d in
                        if (abs(width - d.width) > g.size.width) {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if item == tags.first { width = 0 } else { width -= d.width }
                        return result
                    }
                    .alignmentGuide(.top) { _ in
                        let r = height
                        if item == tags.first { height = 0 }
                        return r
                    }
            }
        }
    }
}

