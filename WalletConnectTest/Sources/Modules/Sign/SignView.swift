import SwiftUI

struct SignView: View {
    @EnvironmentObject var presenter: SignPresenter
    @Environment(\.oh_navigator.wrappedValue) var navigator

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 25/255, green: 26/255, blue: 26/255)
                    .ignoresSafeArea()

                secollContent()

                if !presenter.accountsDetails.isEmpty {
                    VStack {
                        Spacer()

                        Button {
                            presenter.disconnect()
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.white.opacity(0.02))

                                HStack {
                                    ZStack {
                                        Circle()
                                            .fill(.white.opacity(0.05))
                                            .frame(width: 32, height: 32)

                                        Circle()
                                            .fill(.white.opacity(0.1))
                                            .frame(width: 30, height: 30)

                                        Image("exit")
                                            .resizable()
                                            .frame(width: 14, height: 14)
                                    }

                                    Text("Disconnect")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Color(red: 0.58, green: 0.62, blue: 0.62))

                                    Spacer()
                                }
                                .padding(.horizontal, 12)
                            }
                            .frame(height: 56)

                        }
                        .padding(20)
                    }
                }
            }
            .navigationTitle(presenter.accountsDetails.isEmpty ? "Available Chains" : "Session Accounts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(
                Color(red: 25/255, green: 26/255, blue: 26/255),
                for: .navigationBar
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        navigator.pushView {
                            ConfigView()
                        }
                    }) {
                        Image(systemName: "gearshape")
                            .foregroundColor(.white)
                    }
                }
            }
            .alert(presenter.errorMessage, isPresented: $presenter.showError) {
                Button("OK", role: .cancel) {}
            }
        }
    }
    
    func secollContent() -> some View {
        ScrollView {
            if presenter.accountsDetails.isEmpty {
                VStack {
                    ForEach(presenter.chains, id: \.name) { chain in
                        networkItem(title: chain.name, icon: chain.name.lowercased(), id: chain.id)
                    }

                    Spacer()

                    VStack(spacing: 10) {
                        Button {
                            presenter.connectWalletWithWCM()
                        } label: {
                            Text("Connect with WalletConnectModal")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color(red: 95/255, green: 159/255, blue: 248/255))
                                .cornerRadius(16)
                        }
                    }
                    .padding(.top, 10)
                }
                .padding(12)
            } else {
                VStack {
                    ForEach(presenter.accountsDetails, id: \.chain) { account in
                        Button {
                            if let session = presenter.session {
                                navigator.pushView {
                                    SessionAccountView(sessionAccount: account, session: session)
                                }
                            }
                        } label: {
                            networkItem(title: account.account, icon: String(account.chain.split(separator: ":").first ?? ""), id: account.chain)
                        }
                        .accessibilityIdentifier(account.account)
                    }
                }
                .padding(12)
            }
        }
        .padding(.bottom, presenter.accountsDetails.isEmpty ? 0 : 76)
        .onAppear {
            presenter.onAppear()
        }
    }

    private func networkItem(title: String, icon: String, id: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 30/255, green: 31/255, blue: 31/255))

            HStack(spacing: 10) {
                Image(icon == "eip155" ? "ethereum" : icon)
                    .resizable()
                    .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(title)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(red: 228/255, green: 231/255, blue: 231/255))

                        Spacer()
                    }

                    HStack {
                        Text(id)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(Color(red: 0.58, green: 0.62, blue: 0.62))

                        Spacer()
                    }
                }

                Spacer()

                if !presenter.accountsDetails.isEmpty {
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color(red: 0.58, green: 0.62, blue: 0.62))
                        .padding(.trailing, 16)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
        }
    }
}

struct SignView_Previews: PreviewProvider {
    static var previews: some View {
        SignView()
    }
}
