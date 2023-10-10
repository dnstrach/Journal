//
//  JournalController.swift
//  Journal
//
//  Created by Dominique Strachan on 2/28/23.
//

import CoreData

//test

class JournalManager {
    
    //MARK: - Properties
    //Shared Instance
    static let shared = JournalManager()
    
    //Source of Truth
    var journalEntries: [Journal] = []
    
    //Fetch request of type Journal from CoreData with computed property which returns all Journal entries saved in Journal entity
    //Predicate is not necessary because fetching all journal entries in database
    var journalFetchRequest: NSFetchRequest<Journal> = {
        let request = NSFetchRequest<Journal>(entityName: "Journal")
        return request
    }()
    
    
    //MARK: - CRUD
    //create
    func createJournalEntry(journalEntryDate: Date, entryText: String) {
        //storing journal entry's datatype and value into journalEntry variable
        let journalEntry = Journal(journalEntryDate: journalEntryDate, entryText: entryText)
        
        //adding created entry to source of truth
        journalEntries.append(journalEntry)
        
        //dates sorted in descending order to be displayed in cells
        //journalEntries.sort(by: { $0.journalEntryDate ?? Date() > $1.journalEntryDate ?? Date() })
        
        //saving created entry to CoreData
        CoreDataStack.saveJournalContext()
        
    }
    
    //retrieve/fetch
    func fetchJournalEntries() {
        //storing journal entries already created, updated or deleted to be fetched from CoreData into journalEntries variable
        //fetch function throws an error therefore using try option with nil coalescing empty array to be displayed in case of fetch error
        let journalEntries = (try? CoreDataStack.journalContext.fetch(self.journalFetchRequest)) ?? []
        
        //dates sorted in descending order
        //Note: array must be sorted in create, retrieve and update methods for cells to be arranged in descending order
        //journalEntries.sort(by: { $0.journalEntryDate ?? Date() > $1.journalEntryDate ?? Date() })
        
        //source of truth = fetched and sorted array
        self.journalEntries = journalEntries
        
    }
    
    //update
    func updateJournalEntry(journalEntry: Journal, journalEntryDate: Date, entryText: String) {
        journalEntry.journalEntryDate = journalEntryDate
        journalEntry.entryText = entryText
        
        //dates sorted in descending order
        //journalEntries.sort(by: { $0.journalEntryDate ?? Date() > $1.journalEntryDate ?? Date() })
        
        //saving updated entry to CoreData
        CoreDataStack.saveJournalContext()
    }
    
    //delete
    func deleteJournalEntry(journalEntry: Journal) {
        
        //deleting journal entry built in delete function with CoreData
        CoreDataStack.journalContext.delete(journalEntry)
        //saving deletion to CoreData
        CoreDataStack.saveJournalContext()
    }
    
}
