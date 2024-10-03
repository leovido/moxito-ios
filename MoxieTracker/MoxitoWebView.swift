import UIKit
import SwiftUI
import SafariServices

struct SFSafariView: UIViewControllerRepresentable {
	let url: URL

	func makeUIViewController(context: UIViewControllerRepresentableContext<Self>) -> SFSafariViewController {
		return SFSafariViewController(url: url)
	}

	func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SFSafariView>) {

	}
}
