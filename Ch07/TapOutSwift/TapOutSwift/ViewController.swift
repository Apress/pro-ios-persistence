//
//  ViewController.swift
//  TapOutSwift
//
//  Created by Michael Privat on 10/7/14.
//  Copyright (c) 2014 Pro iOS Persistence. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "viewWasTapped:")
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }

    func viewWasTapped(sender: UIGestureRecognizer) {
        if sender.state == .Ended {
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            let point = sender.locationInView(sender.view)
            appDelegate.persistence?.addTap(point)
            self.view.setNeedsDisplay()
        }
    }
}
