import UIKit
import Combine

import WalletConnectSign

final class NewPairingPresenter: ObservableObject {
    @Published var qrCodeImageData: Data?
    
    private let interactor: NewPairingInteractor

    var walletConnectUri: WalletConnectURI
    
    private var subscriptions = Set<AnyCancellable>()

    init(
        interactor: NewPairingInteractor,
        walletConnectUri: WalletConnectURI
    ) {
        self.interactor = interactor
        self.walletConnectUri = walletConnectUri
    }
    
    func onAppear() {
        generateQR()
    }
    
    func connectWallet() {
        let url = URL(string: "walletapp://wc?uri=\(walletConnectUri.deeplinkUri.removingPercentEncoding!)")!
        DispatchQueue.main.async {
            UIApplication.shared.open(url)
        }
    }
    
    func copyUri() {
        UIPasteboard.general.string = walletConnectUri.absoluteString
    }
}

// MARK: - Private functions
extension NewPairingPresenter {
    private func generateQR() {
        Task { @MainActor in
            let qrCodeImage = QRCodeGenerator.generateQRCode(from: walletConnectUri.absoluteString)
            qrCodeImageData = qrCodeImage.pngData()
        }
    }
}

// MARK: - SceneViewModel
extension NewPairingPresenter: SceneViewModel {}
