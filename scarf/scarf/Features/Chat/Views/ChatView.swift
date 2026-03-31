import SwiftUI

struct ChatView: View {
    @Environment(ChatViewModel.self) private var viewModel

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            Divider()
            terminalArea
        }
        .navigationTitle("Chat")
        .task { await viewModel.loadRecentSessions() }
    }

    private var toolbar: some View {
        HStack(spacing: 12) {
            Image(systemName: "terminal")
                .foregroundStyle(.secondary)

            if viewModel.hasActiveProcess {
                Circle()
                    .fill(.green)
                    .frame(width: 6, height: 6)
                Text("Active")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Circle()
                    .fill(.secondary)
                    .frame(width: 6, height: 6)
                Text("No active session")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if !viewModel.hermesBinaryExists {
                Label("Hermes binary not found", systemImage: "exclamationmark.triangle")
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Menu {
                Button("New Session") {
                    viewModel.startNewSession()
                }
                Button("Continue Last Session") {
                    viewModel.continueLastSession()
                }
                if !viewModel.recentSessions.isEmpty {
                    Divider()
                    Text("Resume Session")
                    ForEach(viewModel.recentSessions) { session in
                        Button {
                            viewModel.resumeSession(session.id)
                        } label: {
                            Text("\(session.displayTitle) — \(session.id.prefix(16))")
                        }
                    }
                }
            } label: {
                Label("Session", systemImage: "play.circle")
                    .font(.caption)
            }
            .menuStyle(.borderlessButton)
            .fixedSize()
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
    }

    @ViewBuilder
    private var terminalArea: some View {
        if let terminal = viewModel.terminalView {
            PersistentTerminalView(terminalView: terminal)
        } else if viewModel.hermesBinaryExists {
            ContentUnavailableView(
                "No Active Session",
                systemImage: "terminal",
                description: Text("Start a new session or resume an existing one from the Session menu above.")
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ContentUnavailableView(
                "Hermes Not Found",
                systemImage: "terminal",
                description: Text("Expected at \(HermesPaths.hermesBinary)")
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
