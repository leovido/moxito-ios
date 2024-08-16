//
//  FCWidgets.swift
//  FCWidgets
//
//  Created by Christian Ray Leovido on 15/08/2024.
//

import WidgetKit
import SwiftUI
import OpenGraph
import Combine

struct Provider: AppIntentTimelineProvider {
	func placeholder(in context: Context) -> SimpleEntry {
		SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
	}
	
	func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
		SimpleEntry(date: Date(), configuration: configuration)
	}
	
	func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
		var entries: [SimpleEntry] = []
		
		// Generate a timeline consisting of five entries an hour apart, starting from the current date.
		let currentDate = Date()
		for hourOffset in 0 ..< 5 {
			let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
			let entry = SimpleEntry(date: entryDate, configuration: configuration)
			entries.append(entry)
		}
		
		return Timeline(entries: entries, policy: .atEnd)
	}
}

struct SimpleEntry: TimelineEntry {
	let date: Date
	let configuration: ConfigurationAppIntent
}

struct FCWidgetsEntryView : View {
	var entry: Provider.Entry
	
	@Environment(\.widgetFamily) var family

	@State private var ogImage: String = ""
	
	var body: some View {
		switch family {
		case .systemExtraLarge, .systemLarge:
			VStack {
				if !ogImage.isEmpty {
					if let url = URL(string: ogImage), let imageData = try? Data(contentsOf: url), let uiImage = UIImage(data: imageData) {
						Image(uiImage: uiImage)
							.resizable()
							.aspectRatio(contentMode: .fit)
					} else {
						Color.blue
					}
					
					HStack {
						Button(intent: SuperCharge()) {
							Image(systemName: "person.fill")
						}
						Button(action: {}, label: {
							Text("Button")
						})
						Button(action: {}, label: {
							Text("Button")
						})
						Button(action: {}, label: {
							Text("Button")
						})
					}
				} else {
					Text("Nada")
				}
			}
			.onAppear() {
				Task {
					let result = try await OpenGraph.fetch(url: URL(string: "https://toth-frame.vercel.app/toth")!)
					
					self.ogImage = result.source[.image]!
				}
			}
		case .systemSmall:
			Text("Small")
		default:
			Text("Unimplemented")
		}
	}
}

struct FCWidgets: Widget {
	let kind: String = "FCWidgets"
	
	var body: some WidgetConfiguration {
		AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
			FCWidgetsEntryView(entry: entry)
				.containerBackground(.fill.tertiary, for: .widget)
		}
	}
}

struct RemoteImageView<Placeholder: View, ConfiguredImage: View>: View {
	var url: URL
	private let placeholder: () -> Placeholder
	private let image: (Image) -> ConfiguredImage
	
	@ObservedObject var imageLoader: ImageLoaderService
	@State var imageData: UIImage?
	
	init(
		url: URL,
		@ViewBuilder placeholder: @escaping () -> Placeholder,
		@ViewBuilder image: @escaping (Image) -> ConfiguredImage
	) {
		self.url = url
		self.placeholder = placeholder
		self.image = image
		self.imageLoader = ImageLoaderService(url: url)
	}
	
	@ViewBuilder private var imageContent: some View {
		if let data = imageData {
			image(Image(uiImage: data))
		} else {
			placeholder()
		}
	}
	
	var body: some View {
		imageContent
			.onReceive(imageLoader.$image) { imageData in
				self.imageData = imageData
			}
	}
}

class ImageLoaderService: ObservableObject {
	@Published var image = UIImage()
	
	convenience init(url: URL) {
		self.init()
		loadImage(for: url)
	}
	
	func loadImage(for url: URL) {
		let task = URLSession.shared.dataTask(with: url) { data, _, _ in
			guard let data = data else { return }
			DispatchQueue.main.async {
				self.image = UIImage(data: data) ?? UIImage()
			}
		}
		task.resume()
	}
}

extension ConfigurationAppIntent {
	fileprivate static var smiley: ConfigurationAppIntent {
		let intent = ConfigurationAppIntent()
		intent.favoriteEmoji = "😀"
		return intent
	}
	
	fileprivate static var starEyes: ConfigurationAppIntent {
		let intent = ConfigurationAppIntent()
		intent.favoriteEmoji = "🤩"
		return intent
	}
}

#Preview(as: .systemExtraLarge) {
	FCWidgets()
} timeline: {
	SimpleEntry(date: .now, configuration: .smiley)
	SimpleEntry(date: .now, configuration: .starEyes)
}
