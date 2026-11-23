import Foundation

public struct AgentLimits: Sendable {
    public let maxSteps: Int
    public let maxToolCalls: Int
    public let allowMutations: Bool
    public init(maxSteps: Int = 8, maxToolCalls: Int = 16, allowMutations: Bool = false) {
        self.maxSteps = max(1, maxSteps)
        self.maxToolCalls = max(1, maxToolCalls)
        self.allowMutations = allowMutations
    }
}

public struct AgentCheckpoint: Codable, Sendable {
    public let protocolVersion: String
    public let sourceSha256: String
    public let stepsCompleted: Int
    public let toolCallsCompleted: Int
}

public final class AgentSession {
    public static let sourceSha256 = "e3fd4c744ae8933c0e0bd0c21a692897795a14657e577fb82108500d39f2ac8d"
    public static let registeredOperationsCount = 56
    public let limits: AgentLimits
    public let allowedOperations: Set<String>
    private var stepsCompleted = 0
    private var toolCallsCompleted = 0
    public init(limits: AgentLimits = AgentLimits(), allowedOperations: Set<String> = []) {
        self.limits = limits
        self.allowedOperations = allowedOperations
    }
    public func canInvoke(operationId: String, isMutation: Bool) -> Bool {
        guard stepsCompleted < limits.maxSteps, toolCallsCompleted < limits.maxToolCalls else { return false }
        if isMutation && !limits.allowMutations { return false }
        return allowedOperations.isEmpty || allowedOperations.contains(operationId)
    }
    public func recordStep(toolCalls: Int = 1) {
        stepsCompleted += 1
        toolCallsCompleted += max(0, toolCalls)
    }
    public func checkpoint() -> AgentCheckpoint {
        AgentCheckpoint(protocolVersion: "omniwrap.agent-session/v1", sourceSha256: Self.sourceSha256, stepsCompleted: stepsCompleted, toolCallsCompleted: toolCallsCompleted)
    }
}
