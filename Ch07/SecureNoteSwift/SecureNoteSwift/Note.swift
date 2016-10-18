//
//  Note.swift
//  SecureNoteSwift
//
//  Created by Michael Privat on 10/8/14.
//  Copyright (c) 2014 Pro iOS Persistence. All rights reserved.
//

import Foundation
import CoreData

@objc(Note)
class Note: NSManagedObject {

    @NSManaged var timeStamp: NSDate
    @NSManaged var title: String
    @NSManaged var body: String

}
