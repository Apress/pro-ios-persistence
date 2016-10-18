//
//  Project.swift
//  CoreDumpSwift
//
//  Created by Rob Warner on 9/28/14.
//  Copyright (c) 2014 Michael Privat and Rob Warner. All rights reserved.
//

import Foundation
import CoreData

@objc(Project)
class Project: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var url: String
    @NSManaged var host: String
    @NSManaged var bugs: NSSet

}
