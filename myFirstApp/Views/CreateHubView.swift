//
//  CreateHubView.swift
//  myFirstApp
//
//  Post-sign-in hub: Add (link+metrics) vs Test (text/video hook).
//

import SwiftUI

struct CreateHubView: View {
    var body: some View {
        ZStack {
            HPGradientBackground()
            PlaygroundAnimation()

            // Mirrors the main menu (LandingView) layout: title above
            // the button row, weighted toward the upper half.
            VStack(spacing: 36) {
                Spacer()

                HookPlaygroundTitle(size: 52, twoLines: true)

                HStack(spacing: 16) {
                    NavigationLink {
                        AddExistingHookView()
                    } label: {
                        Text("ADD")
                    }
                    .buttonStyle(HPButtonStyle(color: HPColor.pastelPink))

                    NavigationLink {
                        TestNewHookView()
                    } label: {
                        Text("TEST")
                    }
                    .buttonStyle(HPButtonStyle(color: HPColor.pastelBlue))
                }
                .padding(.horizontal, 32)

                Spacer()
                Spacer()
            }
        }
    }
}
