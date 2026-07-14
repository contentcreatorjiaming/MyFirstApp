//
//  CreateHubView.swift
//  myFirstApp
//
//  Post-sign-in hub matching the wireframe: choose between adding an
//  existing hook (with real performance data) or testing a brand-new,
//  unposted idea.
//

import SwiftUI

struct CreateHubView: View {
    var body: some View {
        ZStack {
            Color.green.ignoresSafeArea()

            VStack(spacing: 32) {
                Text("hook\nplayground")
                    .font(.custom("Snell Roundhand", size: 32))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)

                VStack(spacing: 16) {
                    NavigationLink {
                        AddExistingHookView()
                    } label: {
                        Text("ADD EXISTING")
                    }
                    .buttonStyle(HookButtonStyle(color: .blue))

                    NavigationLink {
                        TestNewHookView()
                    } label: {
                        Text("TEST NEW")
                    }
                    .buttonStyle(HookButtonStyle(color: .pink))
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        CreateHubView()
    }
}
