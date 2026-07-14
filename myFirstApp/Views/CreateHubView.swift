//
//  CreateHubView.swift
//  myFirstApp
//
//  Post-sign-in hub: Add Existing vs Test New.
//

import SwiftUI

struct CreateHubView: View {
    var body: some View {
        ZStack {
            HPGradientBackground()

            VStack(spacing: 36) {
                Text("hook\nplayground")
                    .font(HPFont.screenTitle)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)

                VStack(spacing: 14) {
                    NavigationLink {
                        AddExistingHookView()
                    } label: {
                        Text("ADD EXISTING")
                    }
                    .buttonStyle(HPButtonStyle(color: HPColor.sky, fullWidth: true))

                    NavigationLink {
                        TestNewHookView()
                    } label: {
                        Text("TEST NEW")
                    }
                    .buttonStyle(HPButtonStyle(color: HPColor.coral, fullWidth: true))
                }
                .padding(.horizontal, 40)
            }
        }
    }
}

#Preview {
    NavigationStack {
        CreateHubView()
    }
}
