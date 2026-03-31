import SwiftUI

struct ToolsView: View {
    @State private var viewModel = ToolsViewModel()

    var body: some View {
        VStack(spacing: 0) {
            platformPicker
            Divider()
            toolsList
            if !viewModel.mcpStatus.isEmpty {
                Divider()
                mcpSection
            }
        }
        .navigationTitle("Tools")
        .onAppear { viewModel.load() }
    }

    private var platformPicker: some View {
        HStack(spacing: 16) {
            ForEach(viewModel.availablePlatforms) { platform in
                Button {
                    viewModel.switchPlatform(platform)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: platform.icon)
                        Text(platform.displayName)
                            .font(.caption)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(viewModel.selectedPlatform.name == platform.name ? Color.accentColor.opacity(0.2) : Color.secondary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
            }
            Spacer()
            Text("\(viewModel.toolsets.filter(\.enabled).count) of \(viewModel.toolsets.count) enabled")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private var toolsList: some View {
        ScrollView {
            LazyVStack(spacing: 1) {
                ForEach(viewModel.toolsets) { tool in
                    ToolRow(tool: tool) {
                        viewModel.toggleTool(tool)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    private var mcpSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("MCP Servers")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            if viewModel.mcpStatus.contains("No MCP servers") {
                Label("No MCP servers configured", systemImage: "server.rack")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text(viewModel.mcpStatus)
                    .font(.system(.caption, design: .monospaced))
                    .textSelection(.enabled)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ToolRow: View {
    let tool: HermesToolset
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text(tool.icon)
                .font(.title3)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(tool.name)
                    .font(.system(.body, design: .monospaced, weight: .medium))
                Text(tool.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Toggle("", isOn: Binding(
                get: { tool.enabled },
                set: { _ in onToggle() }
            ))
            .toggleStyle(.switch)
            .labelsHidden()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.quaternary.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
