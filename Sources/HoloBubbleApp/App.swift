import SwiftUI
import Combine

@main
struct HoloBubbleApp: App {
    @StateObject private var bubbleController = BubbleController()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bubbleController)
        }
        .windowStyle(.hiddenTitleBar)
    }
}

final class BubbleController: ObservableObject {
    @Published var message: String = "" {
        didSet { showBubble() }
    }
    @Published var bubbleColor: Color = .init(red: 0.98, green: 0.62, blue: 0.9) // Unicorn pink
    @Published var isBubbleVisible: Bool = false
    @Published var backendURLString: String = "https://your-server.example.com/analyze" {
        didSet { backendClient.backendURL = URL(string: backendURLString) }
    }

    private var cancellables = Set<AnyCancellable>()
    private let screenCaptureService = ScreenCaptureService()
    private var backendClient = BackendClient()

    init() {
        backendClient.backendURL = URL(string: backendURLString)
        setupTimer()
    }

    func setupTimer() {
        Timer.publish(every: 20, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.captureAndSend()
            }
            .store(in: &cancellables)
    }

    func captureAndSend() {
        Task {
            guard let imageData = await screenCaptureService.capture() else { return }
            do {
                let response = try await backendClient.send(imageData: imageData)
                await MainActor.run {
                    self.message = response
                }
            } catch {
                await MainActor.run {
                    self.message = "Error: \(error.localizedDescription)"
                }
            }
        }
    }

    private func showBubble() {
        withAnimation(.spring()) {
            isBubbleVisible = !message.isEmpty
        }
    }
}

struct ContentView: View {
    @EnvironmentObject private var bubbleController: BubbleController

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Holographic Bubble")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
            Text("Captures your screen every 20s, sends it to your backend, and floats the response in a holographic bubble that never shows up in screen recordings.")
                .foregroundStyle(.secondary)
            TextField("Backend URL", text: $bubbleController.backendURLString)
                .textFieldStyle(.roundedBorder)
            ColorPicker("Bubble Color", selection: $bubbleController.bubbleColor)
                .padding(.top, 4)
            Button(action: triggerOnce) {
                Label("Send Sample Capture Now", systemImage: "sparkles")
            }
            .buttonStyle(.borderedProminent)
            .tint(bubbleController.bubbleColor)
            Spacer()
        }
        .padding(24)
        .background(Color(nsColor: .windowBackgroundColor))
        .background(
            BubbleWindowBridge(text: bubbleController.message,
                                color: bubbleController.bubbleColor,
                                isVisible: bubbleController.isBubbleVisible)
        )
        .frame(minWidth: 420, minHeight: 320)
    }

    private func triggerOnce() {
        bubbleController.captureAndSend()
    }
}
