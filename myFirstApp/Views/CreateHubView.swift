//
//  CreateHubView.swift
//  myFirstApp
//
//  Post-sign-in hub: Add Existing vs Test New, side by side.
//

import SwiftUI

struct CreateHubView: View {
    var body: some View {
        ZStack {
            HPGradientBackground()

            VStack(spacing: 36) {
                VStack(spacing: 0) {
                    Text("hook")
                        .font(HPFont.screenTitle)
                    Text("playground")
                        .font(HPFont.screenTitle)
                }
                .foregroundColor(.white)

                HStack(spacing: 14) {
                    NavigationLink {
                        AddExistingHookView()
                    } label: {
                        Text("ADD\nEXISTING")
                            .multilineTextAlignment(.center)
                    }
                    .buttonStyle(HPButtonStyle(color: HPColor.pastelPink, fullWidth: true))

                    NavigationLink {
                        TestNewHookView()
                    } label: {
                        Text("TEST\nNEW")
                            .multilineTextAlignment(.center)
                    }
                    .buttonStyle(HPButtonStyle(color: HPColor.pastelBlue, fullWidth: true))
                }
                .padding(.horizontal, 32)
            }
        }
    }
}

#Preview {
    NavigationStack {
        CreateHubView()
    }
}
