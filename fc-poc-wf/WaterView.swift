//
//  WaterView.swift
//  fc-poc-wf
//
//  Created by Christian Leovido on 19/08/2024.
//

import Foundation
import SwiftUI

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
