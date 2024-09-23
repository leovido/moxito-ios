import SwiftUI
import WebKit

struct WebViewWrapper: UIViewRepresentable {
		
		class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
				var parent: WebViewWrapper
				
				init(parent: WebViewWrapper) {
						self.parent = parent
				}
				
				// Handle messages from JavaScript to Swift
				func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
						if message.name == "onSignInSuccess", let authData = message.body as? [String: Any] {
							// Call the onSignInSuccess handler with the auth data
							parent.onSignInSuccess(authData)
						}
				}
			
			// Called when the web content starts loading
			func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
				print("WebView didStartProvisionalNavigation: \(webView.url?.absoluteString ?? "Unknown URL")")
			}
			
			// Called when the web content has finished loading
			func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
				print("WebView didFinish: \(webView.url?.absoluteString ?? "Unknown URL")")
			}
			
			// Called when the web content failed to load
			func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
				print("WebView didFail: \(error.localizedDescription)")
			}
		}
	
	var url: URL
	var onSignInSuccess: (Dictionary<String, Any>) -> Void
	
	// Make WKWebView instance and configure it
		func makeUIView(context: Context) -> WKWebView {
				let contentController = WKUserContentController()
				contentController.add(context.coordinator, name: "onSignInSuccess")
				
				let config = WKWebViewConfiguration()
				config.userContentController = contentController
				
				let webView = WKWebView(frame: .zero, configuration: config)
				webView.navigationDelegate = context.coordinator
				
				// Inject your custom JavaScript for Neynar authentication
				injectJavaScript(into: webView)
				
				return webView
		}
		
		// Update the WKWebView when necessary
		func updateUIView(_ webView: WKWebView, context: Context) {
				let request = URLRequest(url: url)
				webView.load(request)
		}
		
		// Create the Coordinator for handling events between Swift and JavaScript
		func makeCoordinator() -> Coordinator {
				return Coordinator(parent: self)
		}
		
		// Inject the JavaScript that handles Neynar authentication
		private func injectJavaScript(into webView: WKWebView) {
				let injectedJavaScript = """
				(function () {
					var authWindow;

					async function getLogo(logoUrl, button, text) {
						try {
							const response = await fetch(logoUrl);
							if (!response.ok) throw new Error("Failed to load the logo.");
							const svgData = await response.text();
							button.innerHTML = svgData + `<span>${text}</span>`;
						} catch (error) {
							console.error("Error loading logo:", error);
						}
					}

					function handleMessage(event, authOrigin, successCallback) {
						if (event.origin === authOrigin && event.data.is_authenticated) {
							if (typeof window[successCallback] === "function") {
								window[successCallback](event.data);
							}
							if (authWindow) authWindow.close();
							window.removeEventListener("message", handleMessage);
						}
					}

					function handleSignIn(neynarLoginUrl, clientId, redirectUri, successCallback) {
						var authUrl = new URL(neynarLoginUrl);
						authUrl.searchParams.append("client_id", clientId);
						if (redirectUri) {
							authUrl.searchParams.append("redirect_uri", redirectUri);
						}
						var authOrigin = new URL(neynarLoginUrl).origin;
						var isDesktop = window.matchMedia("(min-width: 800px)").matches;
						var width = 600, height = 700;
						var left = window.screen.width / 2 - width / 2;
						var top = window.screen.height / 2 - height / 2;
						var windowFeatures = `width=${width},height=${height},top=${top},left=${left}`;
						var windowOptions = isDesktop ? windowFeatures : "fullscreen=yes";
						authWindow = window.open(authUrl.toString(), "_blank", windowOptions);
						window.addEventListener(
							"message",
							function (event) {
								handleMessage(event, authOrigin, successCallback);
							},
							false
						);
					}

					function createSignInButton(element) {
						var clientId = element.getAttribute("data-client_id");
						var neynarLoginUrl = element.getAttribute("data-neynar_login_url") ?? "https://app.neynar.com/login";
						var redirectUri = element.getAttribute("data-redirect_uri");
						var successCallback = element.getAttribute("data-success_callback") ?? element.getAttribute("data-success-callback");

						var button = document.createElement("button");
						button.innerHTML = "<span>Sign in with Neynar</span>";
						button.onclick = function () {
							handleSignIn(neynarLoginUrl, clientId, redirectUri, successCallback);
						};
						element.appendChild(button);
					}

					function init() {
						var signinElements = document.querySelectorAll(".neynar_signin");
						signinElements.forEach(createSignInButton);
					}

					if (document.readyState === "loading") {
						document.addEventListener("DOMContentLoaded", init);
					} else {
						init();
					}
				})();
				"""
				
				let script = WKUserScript(source: injectedJavaScript, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
				webView.configuration.userContentController.addUserScript(script)
		}
}
