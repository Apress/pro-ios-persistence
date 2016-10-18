//
//  Bug.swift
//  CoreDumpSwift
//
//  Created by Rob Warner on 9/28/14.
//  Copyright (c) 2014 Michael Privat and Rob Warner. All rights reserved.
//

import Foundation
import CoreData

@objc(Bug)
class Bug: NSManagedObject {

    @NSManaged var title: String
    @NSManaged var details: String
    @NSManaged var screenshot: NSData
    @NSManaged var project: Project

}
