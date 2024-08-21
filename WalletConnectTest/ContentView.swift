//
//  ContentView.swift
//  WalletConnectTest
//
//  Created by Jianrong Fan on 2024/8/19.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        SignView()
            .environmentObject(SignPresenter())
            .modifier(HideNavigationBar())
    }
}

#Preview {
    ContentView()
}
