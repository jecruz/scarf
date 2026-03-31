import Foundation

@Observable
final class ToolsViewModel {
    var selectedPlatform: HermesToolPlatform = KnownPlatforms.all[0]
    var toolsets: [HermesToolset] = []
    var mcpStatus: String = ""
    var isLoading = false
    var availablePlatforms: [HermesToolPlatform] = []

    func load() {
        loadPlatforms()
        loadTools(for: selectedPlatform)
        loadMCPStatus()
    }

    func switchPlatform(_ platform: HermesToolPlatform) {
        selectedPlatform = platform
        loadTools(for: platform)
    }

    func toggleTool(_ tool: HermesToolset) {
        let action = tool.enabled ? "disable" : "enable"
        let result = runHermes(["tools", action, tool.name, "--platform", selectedPlatform.name])
        if result.exitCode == 0 {
            if let idx = toolsets.firstIndex(where: { $0.name == tool.name }) {
                toolsets[idx].enabled.toggle()
            }
        }
    }

    private func loadPlatforms() {
        let config = (try? String(contentsOfFile: HermesPaths.configYAML, encoding: .utf8)) ?? ""
        var platforms: [HermesToolPlatform] = []
        var inSection = false
        for line in config.components(separatedBy: "\n") {
            if line.hasPrefix("platform_toolsets:") {
                inSection = true
                continue
            }
            if inSection {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if trimmed.isEmpty || (!line.hasPrefix(" ") && !line.hasPrefix("\t")) {
                    if !trimmed.isEmpty { break }
                    continue
                }
                if trimmed.hasSuffix(":") && !trimmed.hasPrefix("-") {
                    let name = String(trimmed.dropLast()).trimmingCharacters(in: .whitespaces)
                    if let known = KnownPlatforms.all.first(where: { $0.name == name }) {
                        platforms.append(known)
                    } else {
                        platforms.append(HermesToolPlatform(name: name, displayName: name.capitalized, icon: "bubble.left"))
                    }
                }
            }
        }
        availablePlatforms = platforms.isEmpty ? [KnownPlatforms.all[0]] : platforms
        if !availablePlatforms.contains(where: { $0.name == selectedPlatform.name }) {
            selectedPlatform = availablePlatforms[0]
        }
    }

    private func loadTools(for platform: HermesToolPlatform) {
        isLoading = true
        let result = runHermes(["tools", "list", "--platform", platform.name])
        toolsets = parseToolsList(result.output)
        isLoading = false
    }

    private func loadMCPStatus() {
        let result = runHermes(["mcp", "list"])
        mcpStatus = result.output.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func parseToolsList(_ output: String) -> [HermesToolset] {
        var tools: [HermesToolset] = []
        for line in output.components(separatedBy: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            let isEnabled: Bool
            if trimmed.hasPrefix("✓ enabled") {
                isEnabled = true
            } else if trimmed.hasPrefix("✗ disabled") {
                isEnabled = false
            } else {
                continue
            }
            let rest = trimmed
                .replacingOccurrences(of: "✓ enabled", with: "")
                .replacingOccurrences(of: "✗ disabled", with: "")
                .trimmingCharacters(in: .whitespaces)

            let parts = rest.split(separator: " ", maxSplits: 1)
            guard let namePart = parts.first else { continue }
            let name = String(namePart)
            let rawDesc = parts.count > 1 ? String(parts[1]) : name

            let icon = extractEmoji(from: rawDesc)
            let description = rawDesc
                .unicodeScalars.filter { !$0.properties.isEmoji || $0.isASCII }
                .map { String($0) }.joined()
                .trimmingCharacters(in: .whitespaces)

            tools.append(HermesToolset(name: name, description: description, icon: icon, enabled: isEnabled))
        }
        return tools
    }

    private func extractEmoji(from text: String) -> String {
        for scalar in text.unicodeScalars {
            if scalar.properties.isEmoji && !scalar.isASCII {
                return String(scalar)
            }
        }
        return "🔧"
    }

    private func runHermes(_ arguments: [String]) -> (output: String, exitCode: Int32) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: HermesPaths.hermesBinary)
        process.arguments = arguments
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()
        do {
            try process.run()
            process.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            return (output, process.terminationStatus)
        } catch {
            return ("", -1)
        }
    }
}
