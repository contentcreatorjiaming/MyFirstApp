//
//  ContentView.swift
//  myFirstApp
//
//  Created by Jiaming Lou on 7/12/26.
//

import SwiftUI
import AVKit

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.green
                .ignoresSafeArea()
            
            VStack {
                Text("get hooked")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .multilineTextAlignment(.center)
                
                
            }

        }
        
    }
}

#Preview {
    ContentView()
}
