import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public struct AppStoreUpdateAlertModifier: ViewModifier {
    @Binding public var isPresented: Bool
    public let updateInfo: UpdateInfo?
    public let title: String
    public let updateButtonTitle: String
    public let dismissButtonTitle: String

    public init(
        isPresented: Binding<Bool>,
        updateInfo: UpdateInfo?,
        title: String = "Update Available",
        updateButtonTitle: String = "Update Now",
        dismissButtonTitle: String = "Later"
    ) {
        self._isPresented = isPresented
        self.updateInfo = updateInfo
        self.title = title
        self.updateButtonTitle = updateButtonTitle
        self.dismissButtonTitle = dismissButtonTitle
    }

    public var messageText: String {
        guard let info = updateInfo else { return "" }
        var msg = "Version \(info.storeVersion) is now available on the App Store (you have \(info.currentVersion))."
        if let notes = info.releaseNotes, !notes.isEmpty {
            msg += "\n\nWhat's New:\n\(notes)"
        }
        return msg
    }

    public func body(content: Content) -> some View {
        content
            .alert(
                title,
                isPresented: $isPresented,
                presenting: updateInfo
            ) { info in
                if let url = info.trackViewURL {
                    Button(updateButtonTitle) {
                        #if canImport(UIKit)
                        UIApplication.shared.open(url)
                        #elseif canImport(AppKit)
                        NSWorkspace.shared.open(url)
                        #endif
                    }
                }
                Button(dismissButtonTitle, role: .cancel) {}
            } message: { _ in
                Text(messageText)
            }
    }
}

public extension View {
    /// Presents a standard update alert when an App Store update is detected.
    func appStoreUpdateAlert(
        isPresented: Binding<Bool>,
        updateInfo: UpdateInfo?,
        title: String = "Update Available",
        updateButtonTitle: String = "Update Now",
        dismissButtonTitle: String = "Later"
    ) -> some View {
        self.modifier(
            AppStoreUpdateAlertModifier(
                isPresented: isPresented,
                updateInfo: updateInfo,
                title: title,
                updateButtonTitle: updateButtonTitle,
                dismissButtonTitle: dismissButtonTitle
            )
        )
    }
}
