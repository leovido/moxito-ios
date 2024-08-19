//
//  ContentView.swift
//  fc-poc-wf
//
//  Created by Christian Ray Leovido on 15/08/2024.
//

import SwiftUI
//import OpenGraph

struct ContentView: View {
	@State private var ogImage: String = ""
	
	var body: some View {
		VStack {
			Image(systemName: "globe")
				.imageScale(.large)
				.foregroundStyle(.tint)
			Text("Hello, world!")
			if !ogImage.isEmpty {
				AsyncImage(url: URL.init(string: ogImage)!)

			}
		}
		.padding()
		.onAppear() {
//			Task {
//				let result = try await OpenGraph.fetch(url: URL(string: "https://toth-frame.vercel.app/toth")!)
//				
//				self.ogImage = result.source[.image]!
//				
//				dump(ogImage)
//			}
		}
	}
}

#Preview {
	ContentView()
}
