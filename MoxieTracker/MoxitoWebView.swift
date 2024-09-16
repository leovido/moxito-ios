import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
		var neynarLoginUrl: String
		var clientId: String
		var redirectUri: String?
		var successCallback: (([String: Any]) -> Void)?

		class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
				var parent: WebView
				var authWindow: WKWebView?
				
				init(parent: WebView) {
						self.parent = parent
						super.init()
						
						// Observe when the app comes back to foreground
						NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
				}

				// Called when the app returns to the foreground
				@objc func appDidBecomeActive() {
						// Re-inject JavaScript when the app returns to the foreground
						if let webView = authWindow {
								injectJavaScript(webView)
						}
				}

				deinit {
						NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
				}
				
				func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
						// Save the reference to the web view
//						self.authWindow = webView
//						
//						// Inject JavaScript to listen for post messages
//						injectJavaScript(webView)
				}

				func injectJavaScript(_ webView: WKWebView) {
//						let scriptString = """
//						window.addEventListener('message', function(event) {
//								if (event.data.is_authenticated) {
//										window.webkit.messageHandlers.authHandler.postMessage(event.data);
//								}
//						}, false);
//						"""
//						
//						webView.evaluateJavaScript(scriptString) { (result, error) in
//								if let error = error {
//										print("JavaScript injection error: \(error)")
//								}
//						}
				}

				func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//						if message.name == "authHandler",
//							 let data = message.body as? [String: Any],
//							 let isAuthenticated = data["is_authenticated"] as? Bool,
//							 isAuthenticated {
//								parent.successCallback?(data) // Call the Swift success callback
//								
//								// Close the web view
//								if let webView = authWindow {
//										webView.stopLoading()
//										webView.removeFromSuperview()
//								}
//						}
				}
		}

		func makeCoordinator() -> Coordinator {
				Coordinator(parent: self)
		}

		func makeUIView(context: Context) -> WKWebView {
				let webView = WKWebView()
				webView.navigationDelegate = context.coordinator
			webView.isInspectable = true
//				let contentController = webView.configuration.userContentController
//				contentController.add(context.coordinator, name: "authHandler")

				let url = URL(string: neynarLoginUrl)!
				var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
				components.queryItems = [URLQueryItem(name: "client_id", value: clientId)]
				if let redirectUri = redirectUri {
						components.queryItems?.append(URLQueryItem(name: "redirect_uri", value: redirectUri))
				}

				webView.load(URLRequest(url: components.url!))
				return webView
		}

		func updateUIView(_ webView: WKWebView, context: Context) {
				// Re-inject JavaScript every time the view is updated to ensure it listens for messages again
				context.coordinator.injectJavaScript(webView)
		}
}
