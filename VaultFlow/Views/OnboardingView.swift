import SwiftUI
import LocalAuthentication

struct OnboardingView: View {
    @State private var state = OnboardingState()

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
            }.padding()
        }.preferredColorScheme(.dark)
    }

    @ViewBuilder private var content: some View {
        switch state.step {
        case .welcome: Text("Flow-engine style onboarding (Revolut Flow-inspired).").foregroundStyle(FintechTheme.textSecondary)
        case .profile: TextField("Full name", text: $state.name).textFieldStyle(.roundedBorder)
        case .verify: Label("Identity verified (mock)", systemImage: "checkmark.shield.fill").foregroundStyle(FintechTheme.accent)
        case .pin: Button("Enable Face ID") { authenticate() }.foregroundStyle(FintechTheme.textPrimary)
        case .done: Label("Card ready", systemImage: "creditcard.fill").font(.title).foregroundStyle(FintechTheme.accent)
        }
    }

    private func advance() {
        if state.step == .done { state = OnboardingState(); return }
        switch state.step {
        case .welcome: state.step = .profile
        case .profile: state.step = .verify
        case .verify: state.verified = true; state.step = .pin
        case .pin: state.pinSet = true; state.step = .done
        case .done: break
        }
    }

    private func authenticate() {
        let ctx = LAContext()
        ctx.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock VaultFlow") { ok, _ in
            if ok { Task { @MainActor in advance() } }
        }
    }
}
