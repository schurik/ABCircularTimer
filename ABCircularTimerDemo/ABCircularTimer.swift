//
//  ABProgressTimer.swift
//  ABProgressTimerDemo
//
//  Created by Alexander Buss on 08.02.15.
//  Copyright (c) 2015 Alexander Buss. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
	
	convenience init(rgba: String) {
		var red: CGFloat   = 0.0
		var green: CGFloat = 0.0
		var blue: CGFloat  = 0.0
		var alpha: CGFloat = 1.0
		
		if rgba.hasPrefix("#") {
			let index = advance(rgba.startIndex, 1)
			let hex = rgba.substringFromIndex(index)
			let scanner = NSScanner(string: hex)
			var hexValue: CUnsignedLongLong = 0
			if scanner.scanHexLongLong(&hexValue) {
				if countElements(hex) == 6 {
					red   = CGFloat((hexValue & 0xFF0000) >> 16) / 255.0
					green = CGFloat((hexValue & 0x00FF00) >> 8)  / 255.0
					blue  = CGFloat(hexValue & 0x0000FF) / 255.0
				} else if countElements(hex) == 8 {
					red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
					green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
					blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
					alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
				} else {
					print("invalid rgb string, length should be 7 or 9")
				}
			} else {
				println("scan hex error")
			}
		} else {
			print("invalid rgb string, missing '#' as prefix")
		}
		self.init(red:red, green:green, blue:blue, alpha:alpha)
	}
}

typealias ABProgressBlock = () -> (CGFloat)

@objc protocol ABCircularTimerDelegate: NSObjectProtocol {
	
	optional func willUpdate(circularTimer: ABCircularTimer, percentage: CGFloat)
	
	optional func didUpdate(circularTimer: ABCircularTimer, percentage: CGFloat)
	
	optional func didFinish(circularTimer: ABCircularTimer, percentage: CGFloat)
}

@IBDesignable
class ABCircularTimer: UIView {
	
	private var progress: CGFloat!
	private var timer: NSTimer!
	private var block: ABProgressBlock!
	
	var delegate: ABCircularTimerDelegate?
	var frameWidth: CGFloat!
	
	var progressColor: UIColor!
	var progressBackgroundColor: UIColor!
	var circleBackgroundColor: UIColor!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		setupDefault()
	}

	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	
		setupDefault()
	}

	override func setValue(value: AnyObject?, forKey key: String) {
		if key == "progressBackgroundColor" {
			progressBackgroundColor = value as? UIColor
		} else if key == "frameWidth" {
			frameWidth = value as? CGFloat
		} else if key == "progressColor" {
			progressColor = value as? UIColor
		} else if key == "circleBackgroundColor" {
			circleBackgroundColor = value as? UIColor
		} else {
			super.setValue(value, forKey: key)
		}
		
	}
	
	private func setupDefault() {
		frameWidth = 5
		progress = 0.3
		backgroundColor = UIColor.clearColor()
		progressColor = UIColor(rgba: "#00688b")
		progressBackgroundColor = UIColor(rgba: "#87ceff")
		circleBackgroundColor = UIColor.whiteColor()
	}
	
	private func makeIncrementer(seconds:Int) -> () -> CGFloat {
		var i:CGFloat = 0
		let sec = seconds*100
		func incrementor() -> CGFloat {

			return i++ / CGFloat(sec)
		}
		return incrementor
	}
	
	func startTimer(seconds: Int) {
		progress = 0
		block = makeIncrementer(seconds)
		if timer == nil || !timer.valid {
			timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(1.0/100), target: self, selector: Selector("updateProgress"), userInfo: nil, repeats: true)
			timer.fire()
		}
	}
	
	func startWithProgressBlock(progressBlock:ABProgressBlock) {
		block = progressBlock
		if timer == nil || !timer.valid {
			timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(1.0/10), target: self, selector: Selector("updateProgress"), userInfo: nil, repeats: true)
			timer.fire()
		}
	}
	
	func updateProgress() {
		delegate?.willUpdate?(self, percentage: progress)
		progress = block()
		setNeedsDisplay()
		delegate?.didUpdate?(self, percentage: progress)
		
		if progress >= 1.0 {
			stopTimer()
		}
	}
	
	func stopTimer() {
		timer.invalidate()
		delegate?.didFinish?(self, percentage: progress)
		//progress = 0
		//setNeedsDisplay()
	}
	
	override func drawRect(rect: CGRect) {
		drawFillPie(rect, margin: 0, color: circleBackgroundColor, percentage: 1)
		drawFramePie(rect)
		drawFillPie(rect, margin: frameWidth, color: progressBackgroundColor, percentage: 1)
		drawFillPie(rect, margin: frameWidth, color: progressColor, percentage: progress)
	}
	
	func drawFramePie(frame: CGRect) {
		let radius = min(CGRectGetHeight(frame), CGRectGetWidth(frame)) * 0.5;
		let centerX = CGRectGetWidth(frame) * 0.5;
		let centerY = CGRectGetHeight(frame) * 0.5;
		
		UIColor.grayColor().set()
		let fw = self.frameWidth + 2;
		let frameRect = CGRectMake(
			centerX - radius + fw,
			centerY - radius + fw,
			(radius - fw) * 2,
			(radius - fw) * 2);
		let insideFrame = UIBezierPath(ovalInRect: frameRect)
		insideFrame.lineWidth = 5;
		insideFrame.stroke();
	}
	
	func drawFillPie(frame: CGRect, margin: CGFloat, color: UIColor, percentage: CGFloat) {
		
		let radius: CGFloat = min(CGRectGetHeight(frame), CGRectGetWidth(frame)) * 0.5 - margin;
		let centerX: CGFloat = CGRectGetWidth(frame) * 0.5;
		let centerY: CGFloat = CGRectGetHeight(frame) * 0.5;
		
		let cgContext = UIGraphicsGetCurrentContext();
		CGContextSetFillColorWithColor(cgContext, color.CGColor);
		CGContextMoveToPoint(cgContext, centerX, centerY);
		let end = CGFloat(-M_PI_2) + CGFloat(M_PI * 2) * CGFloat(percentage)
		CGContextAddArc(cgContext, centerX, centerY, radius, CGFloat(-M_PI_2), end, 0);
		CGContextClosePath(cgContext);
		CGContextFillPath(cgContext);
	}
}