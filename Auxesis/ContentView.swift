import SwiftUI

struct ContentView: View {
    var body: some View {
        AuxesisRootHost()
            .ignoresSafeArea()
    }
}

private struct AuxesisRootHost: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> LaunchViewController {
        LaunchViewController()
    }

    func updateUIViewController(_ uiViewController: LaunchViewController, context: Context) {}
}
