//
//  ContentView.swift
//  my-first-demo-app Watch App
//
//  Created by 小山沙耶香 on 2025/05/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "applewatch")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundStyle(.green)
            
            Text("こんにちは、Apple Watch！")
                .font(.headline)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
