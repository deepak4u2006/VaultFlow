import SwiftUI
import LocalAuthentication

struct OnboardingView: View {
    @State private var state = OnboardingState()
    private let keychain: KeychainStoring

    init(keychain: KeychainStoring = KeychainStore.shared) {
        self.keychain = keychain
    }

    var body: some View {
        ZStack {
            FintechTheme.background.ignoresSafeArea()
            VStack(spacing: 24) {
                Text("VaultFlow").font(.largeTitle.bold()).foregroundStyle(FintechTheme.textPrimary)
                Text("Step: \(state.step.rawValue.capitalized)").foregroundStyle(FintechTheme.accent)
                content
                Button(state.step == .done ? "Restart" : "Continue") { advance() }
                    .buttonStyle(.borderedProminent)
                    .tint(FintechTheme.accent)
                    .disabled(state.step == .pin && state.pin.count < 4)
            }.padding()
        }.preferredColorScheme(.dark)
    }

    @ViewBuilder private var content: some View {
        switch state.step {
        case .welcome:
            Text("Flow-engine style onboarding (Revolut Flow-inspired).")
                .foregroundStyle(FintechTheme.textSecondary)
        case .profile:
            TextField("Full name", text: $state.name).textFieldStyle(.roundedBorder)
        case .verify:
            Label("Identity verified (mock)", systemImage: "checkmark.shield.fill")
                .foregroundStyle(FintechTheme.accent)
        case .pin:
            VStack(spacing: 12) {
                SecureField("4-digit PIN", text: $state.pin)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: state.pin) { _, new in
                        state.pin = String(new.filter(\.isNumber).prefix(4))
                    }
                if let pinError = state.pinError {
                    Text(pinError).font(.caption).foregroundStyle(FintechTheme.danger)
                }
                Button("Save PIN to Keychain") { savePIN() }
                    .buttonStyle(.bordered)
                    .tint(FintechTheme.accent)
                Button("Enable Face ID") { authenticate() }
                    .foregroundStyle(FintechTheme.textPrimary)
            }
        case .done:
            Label("Card ready", systemImage: "creditcard.fill")
                .font(.title).foregroundStyle(FintechTheme.accent)
        }
    }

    private func savePIN() {
        guard state.pin.count == 4 else {
            state.pinError = "Enter a 4-digit PIN"
            return
        }
        do {
            try keychain.save(key: KeychainStore.pinAccountKey, value: state.pin)
            state.pinSet = true
            state.pinError = nil
        } catch {
            state.pinError = "Could not store PIN securely"
        }
    }

    private func advance() {
        if state.step == .done { state = OnboardingState(); return }
        switch state.step {
        case .welcome: state.step = .profile
        case .profile: state.step = .verify
        case .verify: state.verified = true; state.step = .pin
        case .pin:
            if !state.pinSet { savePIN() }
            guard state.pinSet else { return }
            state.step = .done
        case .done: break
        }
    }

    private func authenticate() {
        let ctx = LAContext()
        ctx.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock VaultFlow") { ok, _ in
            if ok { Task { @MainActor in
                if !state.pinSet { savePIN() }
                if state.pinSet { state.step = .done }
            }}
        }
    }
}
