//
//  ViewController.swift
//  ABCircularTimerDemo
//
//  Created by Alexander Buss on 09.02.15.
//  Copyright (c) 2015 Alexander Buss. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ABCircularTimerDelegate {

	@IBOutlet weak var duration: UITextField!
	@IBOutlet weak var percentage: UITextField!
	@IBOutlet weak var circularTimer: ABCircularTimer!
	
	@IBOutlet weak var finish: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		circularTimer.delegate = self
		circularTimer.frameWidth = 1
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func didUpdate(circularTimer: ABCircularTimer, percentage: CGFloat) {
		let p = Float(percentage*100)
		let s = NSString(format: "%.2f", p)
		self.percentage.text = s
	}
	
	func didFinish(circularTimer: ABCircularTimer, percentage: CGFloat) {
		finish.text = "done"
	}
	
	@IBAction func startAction(sender: AnyObject) {
		let sec = duration.text.toInt()!
		circularTimer.startTimer(sec)
		finish.text = "in progress"
	}
	
	@IBAction func stopAction(sender: AnyObject) {
		circularTimer.stopTimer()
	}
}

