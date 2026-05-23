# VaultFlow

![iOS CI](https://github.com/deepak4u2006/VaultFlow/actions/workflows/ios.yml/badge.svg)

Step-driven onboarding with a small **Flow** state machine, **Keychain** PIN storage, and **LocalAuthentication** biometrics.

## Flow navigation

| Step | Purpose |
|------|---------|
| `welcome` | Intro |
| `profile` | Collect display name |
| `verify` | Mock KYC checkpoint |
| `pin` | 4-digit PIN → Keychain (`kSecAttrAccessibleWhenUnlockedThisDeviceOnly`) |
| `done` | Card-ready state |

State advances via `OnboardingState` + `OnboardingStep`; the PIN step persists to `KeychainStore` before biometrics or completion.

## Security

- **Keychain** — `Security/KeychainStore.swift` for mock PIN (device-only, unlocked access)
- **Biometrics** — Face ID / Touch ID gate on the PIN step (`NSFaceIDUsageDescription` in project settings)

## Run

Open `VaultFlow.xcodeproj` → iPhone simulator → ⌘R. Tests: ⌘U (includes Keychain round-trip).

## Revolut-relevant signals

- Flow/state-machine onboarding (Revolut Flow–inspired)
- Secrets not stored in `UserDefaults`
- Biometric unlock path

*Fintech-inspired — not affiliated with Revolut Ltd.*
