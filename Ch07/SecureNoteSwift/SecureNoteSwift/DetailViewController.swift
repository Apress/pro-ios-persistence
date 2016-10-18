//
//  DetailViewController.swift
//  SecureNoteSwift
//
//  Created by Michael Privat on 10/8/14.
//  Copyright (c) 2014 Pro iOS Persistence. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var noteTitle: UITextField!
    @IBOutlet weak var noteBody: UITextView!
    
    var note: Note? {
        didSet {
            self.configureView()
        }
    }

    func configureView() {
        if self.noteTitle != nil {
            if let note = self.note {
                self.noteTitle.text = note.title
                self.noteBody.text = note.body
            }
            else {
                self.noteTitle.text = ""
                self.noteBody.text = ""
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
    }

    override func viewWillDisappear(animated: Bool) {
        self.note?.title = self.noteTitle.text
        self.note?.body = self.noteBody.text
      
        if let managedObjectContext = self.note?.managedObjectContext {
            var error: NSError? = nil
            if !managedObjectContext.save(&error) {
              NSLog("Error saving note \(self.noteTitle.text) -- \(error) \(error!.userInfo)")
            }
        }
    }
    
    func setNote(note: Note) {
        if(self.note != note) {
            self.note = note
            self.configureView()
        }
    }
}
