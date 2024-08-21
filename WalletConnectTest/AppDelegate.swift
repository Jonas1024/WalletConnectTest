//
//  AppDelegate.swift
//  WalletConnectTest
//
//  Created by Jianrong Fan on 2024/8/19.
//

import Foundation
import UIKit
import WalletConnectSign
import WalletConnectModal
import WalletConnectRelay
import WalletConnectNetworking
import Combine

class AppDelegate: NSObject, UIApplicationDelegate {
    
    var clientsConfigured = false
    private var publishers = Set<AnyCancellable>()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        configureClientsIfNeeded()
        setUpProfilingIfNeeded()
        
        return true
    }
    
    private func setUpProfilingIfNeeded() {
        if let clientId = try? Networking.interactor.getClientId() {
            print("clientId: \(clientId)")
        }
    }
    
    private func configureClientsIfNeeded() {
        if clientsConfigured {return}
        else {clientsConfigured = true}
        Networking.configure(
            groupIdentifier: Constants.groupIdentifier,
            projectId: InputConfig.projectId,
            socketFactory: DefaultSocketFactory()
        )

        let metadata = AppMetadata(
            name: "Swift Dapp",
            description: "WalletConnect DApp sample",
            url: "https://lab.web3modal.com/dapp",
            icons: ["https://avatars.githubusercontent.com/u/37784886"],
            redirect: try! AppMetadata.Redirect(native: "wcdapp://", universal: "https://lab.web3modal.com/dapp", linkMode: true)
        )

        WalletConnectModal.configure(
            projectId: InputConfig.projectId,
            metadata: metadata
        )
        
        Sign.configure(crypto: DefaultCryptoProvider())

        Sign.instance.logger.setLogging(level: .debug)
        Networking.instance.setLogging(level: .debug)

        Sign.instance.logsPublisher.sink { log in
            switch log {
            case .error(let logMessage):
                print("error: \(logMessage.message)")
            default: return
            }
        }.store(in: &publishers)

        Sign.instance.socketConnectionStatusPublisher.sink { status in
            switch status {
            case .connected:
                print("Your web socket has connected")
            case .disconnected:
                print("Your web socket is disconnected")
            }
        }.store(in: &publishers)
    }
}
