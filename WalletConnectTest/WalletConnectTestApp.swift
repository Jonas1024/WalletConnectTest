//
//  WalletConnectTestApp.swift
//  WalletConnectTest
//
//  Created by Jianrong Fan on 2024/8/19.
//

import SwiftUI

@main
struct WalletConnectTestApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            OHNavigationView {
                ContentView()
            }.navigationViewStyle(.stack)
        }
    }
}
