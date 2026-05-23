import Foundation

protocol FlowStep: Hashable, Sendable {}
protocol FlowState: Sendable {}

final class FlowEngine<Step: FlowStep, State: FlowState>: @unchecked Sendable {
    private(set) var state: State
    private let transitions: [Step: (inout State) -> Void]

    init(initial: State, transitions: [Step: (inout State) -> Void]) {
        self.state = initial
        self.transitions = transitions
    }

    func perform(_ step: Step) {
        transitions[step]?(&state)
    }
}
