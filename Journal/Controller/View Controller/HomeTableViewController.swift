//
//  TableViewController.swift
//  Journal
//
//  Created by Dominique Strachan on 2/28/23.
//

import UIKit

class HomeTableViewController: UITableViewController {

    //MARK: - Outlets
    @IBOutlet var journalTableView: UITableView!
    
    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //navigation bar title font
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Kohinoor Bangla", size: 22)!]
        
        //fetching journal entries when homeTVC loads
        JournalManager.shared.fetchJournalEntries()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //need to reload table each time home view appears or else added entries will only show when re-running the app
        journalTableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    //sections - month and year --- medication day 2
    //    override func numberOfSections(in tableView: UITableView) -> Int {
    //        // #warning Incomplete implementation, return the number of sections
    //        return 1
    //    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //number of cell rows = total number of journal entries
        return JournalManager.shared.journalEntries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "journalCell", for: indexPath)
        
        //each journal entry based on count placed in cell by section/row.row
        let journalEntry = JournalManager.shared.journalEntries[indexPath.row]
        
        //look into how to use UI configuration
        var newContent = cell.defaultContentConfiguration()
        
        //cell text = journal entry date
        newContent.text = DateFormatter.journalEntryDate.string(from: journalEntry.journalEntryDate ?? Date())
        
        cell.contentConfiguration = newContent
        
        return cell
    }
    
    //deleting journal entry
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            //removing journal entry from cell
            let journalEntry = JournalManager.shared.journalEntries.remove(at: indexPath.row)
            //deleting journal entry from CoreData
            JournalManager.shared.deleteJournalEntry(journalEntry: journalEntry)
            //deleting journal entry by sliding right on cell
            journalTableView.deleteRows(at: [indexPath], with: .automatic)
            
        }
    }
    
    // MARK: - Navigation
    //IIDOO
    //individual journal entry being passed over to view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toJournalEntryDetails",
           let indexPath = journalTableView.indexPathForSelectedRow,
           let destination = segue.destination as? JournalEntryViewController {
            let journalEntry = JournalManager.shared.journalEntries[indexPath.row]
            destination.journalEntries = journalEntry
            
        }
    }
}
