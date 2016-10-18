//
//  Tap.swift
//  TapOutSwift
//
//  Created by Rob Warner on 10/13/14.
//  Copyright (c) 2014 Pro iOS Persistence. All rights reserved.
//

import Foundation
import CoreData
import UIKit

@objc(Tap)
class Tap: NSManagedObject {

    @NSManaged var color: UIColor
    @NSManaged var x: Float
    @NSManaged var y: Float

}
