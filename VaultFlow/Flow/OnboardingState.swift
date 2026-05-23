import Foundation

enum OnboardingStep: String, FlowStep, CaseIterable {
    case welcome, profile, verify, pin, done
}

struct OnboardingState: FlowState {
    var step: OnboardingStep = .welcome
    var name = ""
    var verified = false
    var pin = ""
    var pinSet = false
    var pinError: String?
}
