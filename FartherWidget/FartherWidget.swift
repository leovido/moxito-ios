import WidgetKit
import SwiftUI
import TipDependencies

enum FartherTheme {
	static let backgroundColor = Color(red: 0.118, green: 0.227, blue: 0.541) // #1e3a8a
	static let foregroundColor = Color(red: 1, green: 0.843, blue: 0) // #ffd700
}

struct Provider: AppIntentTimelineProvider {
	let client: TipClient = .init()
	
	func placeholder(in context: Context) -> SimpleEntry {
		SimpleEntry(date: Date(), 
								model: TipModel.placeholder,
								configuration: ConfigurationAppIntent())
	}
	
	func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
		SimpleEntry(date: Date(), 
								model: TipModel.placeholder,
								configuration: configuration)
	}
	
	func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
		var entries: [SimpleEntry] = []
		
		let result = try! await client.fetchFartherTips()
		
		// Generate a timeline consisting of five entries an hour apart, starting from the current date.
		let currentDate = Date()
		for hourOffset in 0 ..< 5 {
			let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
			let entry = SimpleEntry(date: Date(), model: result, configuration: configuration)
			entries.append(entry)
		}
		
		return Timeline(entries: entries, policy: .atEnd)
	}
}

struct SimpleEntry: TimelineEntry {
	var date: Date
	
	let model: TipModel
	let configuration: ConfigurationAppIntent
}

struct FartherWidgetEntryView : View {
	@Environment(\.widgetFamily) private var family

	var entry: Provider.Entry
	
	var body: some View {
		switch family {
			case .systemSmall:
				ZStack {
					FartherTheme.backgroundColor
					VStack(alignment: .leading) {
						HStack {
							VStack(alignment: .leading) {
								Text("✨Balance")
									.font(.custom("Avenir-Black", size: 12))
								Text("\(entry.model.balance)")
									.foregroundStyle(.white)
									.fontDesign(.rounded)
									.font(.system(size: 16))
									.bold()
							}
							.font(.system(size: 13))
							
							Spacer()
							
							VStack(alignment: .leading) {
								Text("Min✨")
									.font(.custom("Avenir-Black", size: 12))
								Text("\(entry.model.tipMin)")
									.foregroundStyle(.white)
									.fontDesign(.rounded)
									.font(.system(size: 16))
									.bold()
							}
							.font(.system(size: 13))
						}
						.padding([.vertical], 4)
						.padding([.top], 4)
						
						VStack(alignment: .leading) {
							Text("Daily✨")
								.font(.custom("Avenir-Black", size: 12))
								.bold()
							Text("\(entry.model.given)/\(entry.model.allowance)")
								.foregroundStyle(.white)
								.fontDesign(.rounded)
								.fontWeight(.bold)
								.scaledToFill()
								.minimumScaleFactor(0.5)
								.font(.system(size: 20))
						}
						.font(.system(size: 13))
						.padding(.bottom, 4)
						
						VStack(alignment: .leading) {
							Text("Received✨")
								.font(.custom("Avenir-Black", size: 12))
								.bold()
							Text("\(entry.model.received)")
								.foregroundStyle(.white)
								.fontDesign(.rounded)
								.fontWeight(.semibold)
								.font(.system(size: 20))
						}
						.font(.system(size: 13))
						
						Spacer()
						
					}
					.foregroundColor(FartherTheme.foregroundColor)
				}
			default:
				Text("unimplemented")
		}
	}
}

struct FartherWidget: Widget {
	let client = TipClient()
	let kind: String = "FartherWidget"
	
	var body: some WidgetConfiguration {
		AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
			FartherWidgetEntryView(entry: entry)
				.containerBackground(FartherTheme.backgroundColor, for: .widget)
		}
		.supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
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

struct WaterView: View {
	
	@State private var percent = 50.0
	
	var body: some View {
		VStack {
			CircleWaveView(percent: Int(self.percent))
			Slider(value: self.$percent, in: 0...100)
		}
		.padding(.all)
	}
}

struct Wave: Shape {
	
	var offset: Angle
	var percent: Double
	
	var animatableData: Double {
		get { offset.degrees }
		set { offset = Angle(degrees: newValue) }
	}
	
	func path(in rect: CGRect) -> Path {
		var p = Path()
		
		// empirically determined values for wave to be seen
		// at 0 and 100 percent
		let lowfudge = 0.02
		let highfudge = 0.98
		
		let newpercent = lowfudge + (highfudge - lowfudge) * percent
		let waveHeight = 0.015 * rect.height
		let yoffset = CGFloat(1 - newpercent) * (rect.height - 4 * waveHeight) + 2 * waveHeight
		let startAngle = offset
		let endAngle = offset + Angle(degrees: 360)
		
		p.move(to: CGPoint(x: 0, y: yoffset + waveHeight * CGFloat(sin(offset.radians))))
		
		for angle in stride(from: startAngle.degrees, through: endAngle.degrees, by: 5) {
			let x = CGFloat((angle - startAngle.degrees) / 360) * rect.width
			p.addLine(to: CGPoint(x: x, y: yoffset + waveHeight * CGFloat(sin(Angle(degrees: angle).radians))))
		}
		
		p.addLine(to: CGPoint(x: rect.width, y: rect.height))
		p.addLine(to: CGPoint(x: 0, y: rect.height))
		p.closeSubpath()
		
		return p
	}
}

struct CircleWaveView: View {
	
	@State private var waveOffset = Angle(degrees: 0)
	let percent: Int
	
	var body: some View {
		
		GeometryReader { geo in
			ZStack {
				Text("\(self.percent)%")
					.foregroundColor(.black)
					.font(Font.system(size: 0.25 * min(geo.size.width, geo.size.height) ))
				Circle()
					.stroke(Color.blue, lineWidth: 0.025 * min(geo.size.width, geo.size.height))
					.overlay(
						Wave(offset: Angle(degrees: self.waveOffset.degrees), percent: Double(percent)/100)
							.fill(Color(red: 0, green: 0.5, blue: 0.75, opacity: 0.5))
							.clipShape(Circle().scale(0.92))
					)
			}
		}
		.aspectRatio(1, contentMode: .fit)
		.onAppear {
			withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
				self.waveOffset = Angle(degrees: 360)
			}
		}
	}
}

struct MeatOnBone: Shape {
	func path(in rect: CGRect) -> Path {
		var path = Path()
		
		// Define the bone part
		let boneWidth = rect.width * 0.2
		let boneHeight = rect.height * 0.4
		let boneCornerRadius = boneWidth * 0.5
		
		path.addRoundedRect(in: CGRect(x: rect.midX - boneWidth / 2, y: rect.minY, width: boneWidth, height: boneHeight), cornerSize: CGSize(width: boneCornerRadius, height: boneCornerRadius))
		
		// Define the meat part
		let meatWidth = rect.width * 0.6
		let meatHeight = rect.height * 0.6
		let meatCornerRadius = meatWidth * 0.5
		
		path.addRoundedRect(in: CGRect(x: rect.midX - meatWidth / 2, y: rect.midY - meatHeight / 2, width: meatWidth, height: meatHeight), cornerSize: CGSize(width: meatCornerRadius, height: meatCornerRadius))
		
		// Add small circles at the ends of the bone
		let smallCircleRadius = boneWidth * 0.6
		
		path.addEllipse(in: CGRect(x: rect.midX - smallCircleRadius / 2, y: rect.minY - smallCircleRadius / 2, width: smallCircleRadius, height: smallCircleRadius))
		path.addEllipse(in: CGRect(x: rect.midX - smallCircleRadius / 2, y: rect.minY + boneHeight - smallCircleRadius / 2, width: smallCircleRadius, height: smallCircleRadius))
		
		return path
	}
}


struct WaterView_Previews: PreviewProvider {
	static var previews: some View {
		CircleWaveView(percent: 40)
	}
}


#Preview(as: .systemSmall) {
	FartherWidget()
} timeline: {
	SimpleEntry(date: .now,
							model: .init(id: UUID(), 
													 allowance: Int.random(in: 100...200),
													 given: 1000,
													 received: Int.random(in: 1000...5000),
													 balance: String(Int.random(in: 1000...4000)),
													 tipMin: Int.random(in: 1000...50_000),
													 rank: 342),
							configuration: .smiley)
	SimpleEntry(date: .now,
							model: .init(id: UUID(),
													 allowance: Int.random(in: 100...200),
													 given: 1000,
													 received: Int.random(in: 1000...5000),
													 balance: String(Int.random(in: 1000...4000)),
													 tipMin: Int.random(in: 1000...50_000),
													 rank: 342),
							configuration: .starEyes)
}
