//
//  TopicSelectGrid.swift
//  myFirstApp
//
//  Multi-select grid of the canonical hook topics. Selected chips fill white
//  with green text (matches the Explore detail styling); unselected chips are
//  translucent. Reused at sign-up (interests) and when testing a hook (tags).
//

import SwiftUI

struct TopicSelectGrid: View {
    @Binding var selected: Set<String>

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
            ForEach(HookTopics.all, id: \.self) { topic in
                let isOn = selected.contains(topic)
                Button {
                    if isOn { selected.remove(topic) } else { selected.insert(topic) }
                } label: {
                    Text(topic)
                        .font(HPFont.caption)
                        .foregroundColor(isOn ? HPColor.backgroundDark : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(isOn ? Color.white : Color.white.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
        }
    }
}
