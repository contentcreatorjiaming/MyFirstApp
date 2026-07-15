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

            VStack {
                Spacer()

                HookPlaygroundTitle(size: 40, twoLines: true)

                Spacer().frame(height: 36)

                HStack(spacing: 14) {
                    NavigationLink {
                        AddExistingHookView()
                    } label: {
                        Text("ADD")
                    }
                    .buttonStyle(HPButtonStyle(color: HPColor.pastelPink, fullWidth: true))

                    NavigationLink {
                        TestNewHookView()
                    } label: {
                        Text("TEST")
                    }
                    .buttonStyle(HPButtonStyle(color: HPColor.pastelBlue, fullWidth: true))
                }
                .padding(.horizontal, 32)

                Spacer()
            }
        }
    }
}
