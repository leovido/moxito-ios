//
//  WaterView.swift
//  fc-poc-wf
//
//  Created by Christian Leovido on 19/08/2024.
//

import Foundation
import SwiftUI
import TipLibs

struct WaterView: View {
	@State private var percent = "50"
	
	var body: some View {
		VStack {
			CircleWaveView(percent: percent, color: Color.red)
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
	let percent: String
	let color: Color
	
	var body: some View {
		GeometryReader { geo in
			ZStack {
				Text("\(self.percent)")
					.foregroundColor(color)
					.font(Font.system(size: 0.20 * min(geo.size.width, geo.size.height) ))
				Circle()
					.stroke(color.opacity(0.2), lineWidth: 0.025 * min(geo.size.width, geo.size.height))
					.overlay(
						Wave(offset: Angle(degrees: self.waveOffset.degrees),
								 percent: (Double(percent.dropLast()) ?? 0) / 100)
							.fill(color.opacity(0.3))
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
		.frame(alignment: .center)
	}
}

struct WaterView_Previews: PreviewProvider {
	static var previews: some View {
		CircleWaveView(percent: "40", color: .blue)
	}
}
