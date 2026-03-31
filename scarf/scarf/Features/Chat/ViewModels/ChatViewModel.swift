import Foundation
import AppKit
import SwiftTerm

@Observable
final class ChatViewModel {
    private let dataService = HermesDataService()

    var recentSessions: [HermesSession] = []
    var terminalView: LocalProcessTerminalView?
    var hasActiveProcess = false
    private var coordinator: Coordinator?

    var hermesBinaryExists: Bool {
        FileManager.default.fileExists(atPath: HermesPaths.hermesBinary)
    }

    func startNewSession() {
        launchTerminal(arguments: ["chat"])
    }

    func resumeSession(_ sessionId: String) {
        launchTerminal(arguments: ["chat", "--resume", sessionId])
    }

    func continueLastSession() {
        launchTerminal(arguments: ["chat", "--continue"])
    }

    func loadRecentSessions() async {
        let opened = await dataService.open()
        guard opened else { return }
        recentSessions = await dataService.fetchSessions(limit: 10)
        await dataService.close()
    }

    private func launchTerminal(arguments: [String]) {
        if let existing = terminalView {
            existing.terminate()
            existing.removeFromSuperview()
        }

        let terminal = LocalProcessTerminalView(frame: .zero)
        terminal.font = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        terminal.nativeBackgroundColor = NSColor(red: 0.11, green: 0.12, blue: 0.14, alpha: 1.0)
        terminal.nativeForegroundColor = NSColor(red: 0.85, green: 0.87, blue: 0.91, alpha: 1.0)

        let coord = Coordinator(onTerminated: { [weak self] in
            self?.hasActiveProcess = false
        })
        terminal.processDelegate = coord
        self.coordinator = coord

        var env = ProcessInfo.processInfo.environment
        env["TERM"] = "xterm-256color"
        env["COLORTERM"] = "truecolor"
        let envArray = env.map { "\($0.key)=\($0.value)" }

        terminal.startProcess(
            executable: HermesPaths.hermesBinary,
            args: arguments,
            environment: envArray,
            execName: nil
        )

        self.terminalView = terminal
        self.hasActiveProcess = true
    }

    final class Coordinator: NSObject, LocalProcessTerminalViewDelegate {
        let onTerminated: () -> Void

        init(onTerminated: @escaping () -> Void) {
            self.onTerminated = onTerminated
        }

        func sizeChanged(source: LocalProcessTerminalView, newCols: Int, newRows: Int) {}
        func setTerminalTitle(source: LocalProcessTerminalView, title: String) {}
        func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?) {}

        func processTerminated(source: TerminalView, exitCode: Int32?) {
            let terminal = source.getTerminal()
            terminal.feed(text: "\r\n[Process exited with code \(exitCode ?? -1). Use the toolbar to start or resume a session.]\r\n")
            DispatchQueue.main.async { self.onTerminated() }
        }
    }
}
