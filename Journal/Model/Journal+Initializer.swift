//
//  Journal+Initializer.swift
//  Journal
//
//  Created by Dominique Strachan on 2/28/23.
//

import CoreData

extension Journal {
    
    
    convenience init(context: NSManagedObjectContext = CoreDataStack.journalContext, journalEntryDate: Date, gratitude: String, dailyDescription: String, affirmation: String) {
        self.init(context: context)
        self.journalEntryDate = journalEntryDate
        self.gratitude = gratitude
        self.dailyDescription = dailyDescription
        self.affirmation = affirmation
    }
    
}
