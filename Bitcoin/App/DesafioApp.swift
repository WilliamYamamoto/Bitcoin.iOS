import SwiftUI

@main
struct DesafioApp: App {
    private let container = AppContainer.makeDefault()

    var body: some Scene {
        WindowGroup {
            AppRootView(container: container)
        }
    }
}
