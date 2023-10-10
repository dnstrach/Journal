//
//  TableViewController.swift
//  Journal
//
//  Created by Dominique Strachan on 2/28/23.
//

import UIKit
import CoreData

class HomeTableViewController: UITableViewController {
    
    //CORE DATA + SECTION STRUCT
    var sections = [MonthSection]()
    
    //MARK: - Outlets
    @IBOutlet var journalTableView: UITableView!
    
    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBarSetup()
        
        //CORE DATA + SECTION STRUCT
        self.sections = MonthSection.group(journalEntries: JournalManager.shared.journalEntries)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //CORE DATA + SECTION STRUCT
        JournalManager.shared.fetchJournalEntries()
        self.sections = MonthSection.group(journalEntries: JournalManager.shared.journalEntries)
        
        
        //need to reload table each time home view appears or else added entries will only show when re-running the app
        journalTableView.reloadData()
        
    }
    
    func navBarSetup() {
        //journalTableView.backgroundColor = UIColor(red: 164/255, green: 161/255, blue: 168/255, alpha: 1.0)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Kohinoor Bangla", size: 20)!]
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        if offset > 1 { // Or choose any desired offset
            self.navigationController?.navigationBar.barTintColor = UIColor(named: "DarkGrayPurple")
        }else if offset == 0 {
            self.navigationController?.navigationBar.barTintColor = UIColor(named: "GrayPurple")
        }
    }
    
    
    // MARK: - Table view data source
    //CORE DATA + SECTION STRUCT
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.sections.count
        
    }
    
    //CORE DATA + SECTION STRUCT
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let monthSection = self.sections[section]
        let sectionDate = monthSection.month
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: sectionDate)
        
        //        if self.tableView(tableView, numberOfRowsInSection: section) > 0 {
        //            return dateFormatter.string(from: sectionDate)
        //        } else {
        //            return nil
        //        }
        
    }
    
    //CORE DATA + SECTION STRUCT
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        //view.tintColor = UIColor(named: "GrayPurple")
        //view.tintColor = UIColor(named: "QuoteText")
        view.tintColor = UIColor(named: "Header")
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor(named: "Default")
        //header.textLabel?.textColor = UIColor(named: "LightGrayPurple")
        //header.textLabel?.textColor = UIColor(named: "GrayPurple")
        
        
        header.textLabel?.font =  UIFont(name: "Kohinoor Bangla", size: 18)
        //header.textLabel?.font =  UIFont(name: "Avenir Next Condensed", size: 20)
        //header.textLabel?.font =  UIFont(name: "DIN Alternate", size: 20)
        
        //expand header frame
        header.frame.size.width = 600
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //CORE DATA + SECTION STRUCT
        let monthSection = self.sections[section]
        return monthSection.journalEntries.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "journalCell", for: indexPath)
        
        //CORE DATA + SECTION STRUCT
        let monthSection = self.sections[indexPath.section]
        let journalEntry = monthSection.journalEntries[indexPath.row]
        
        //look into how to use UI configuration
        var newContent = cell.defaultContentConfiguration()
        
        //cell text = journal entry date
        newContent.text = DateFormatter.journalEntryDate.string(from: journalEntry.journalEntryDate ?? Date())
        newContent.textProperties.font = UIFont(name: "Avenir Next Regular", size: 20)!
        
        cell.contentConfiguration = newContent
        
        return cell
    }
    
    //deleting journal entry
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive,
                                              title: "Delete") { [weak self] _, _, complete in
            
            //CORE DATA + SECTION STRUCT
            let monthSection = self!.sections[indexPath.section]
            let journalEntry = monthSection.journalEntries[indexPath.row]
            JournalManager.shared.deleteJournalEntry(journalEntry: journalEntry)
            
            
            //CORE DATA + SECTION STRUCT
            //deleting journal entry from section
            self?.sections[indexPath.section].journalEntries.remove(at: indexPath.row)
            
            //CORE DATA
            //CORE DATA + SECTION STRUCT
            //deleting journal entry from table view
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            //CORE DATA + SECTION STRUCT
            if self!.sections[indexPath.section].journalEntries.isEmpty {
                self!.sections.remove(at: indexPath.section)
                tableView.deleteSections(.init(integer: indexPath.section), with: .fade)
            }
            
            complete(true)
        }
        
        deleteAction.backgroundColor = UIColor(named: "DarkGrayPurple")
        
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    // MARK: - Navigation
    //IIDOO
    //individual journal entry being passed over to view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toJournalEntryDetails",
           let indexPath = journalTableView.indexPathForSelectedRow,
           let destination = segue.destination as? JournalEntryViewController {
            
            //CORE DATA + SECTION STRUCT
            let monthSection = self.sections[indexPath.section]
            let journalEntry = monthSection.journalEntries[indexPath.row]
            
            
            destination.journalEntries = journalEntry
        }
    }
}

//CORE DATA + SECTION STRUCT
extension HomeTableViewController {
    struct MonthSection: Comparable {
        var month: Date
        var journalEntries: [Journal]
        
        static func firstDayOfMonth(date: Date) -> Date {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month], from: date)
            //force wrap??
            return calendar.date(from: components)!
        }
        
        static func < (lhs: HomeTableViewController.MonthSection, rhs: HomeTableViewController.MonthSection) -> Bool {
            return lhs.month > rhs.month
        }
        
        //        static func == (lhs: HomeTableViewController.MonthSection, rhs: HomeTableViewController.MonthSection) -> Bool {
        //            return lhs.month == rhs.month
        //        }
        
        static func group(journalEntries: [Journal]) -> [MonthSection] {
            let groups = Dictionary(grouping: JournalManager.shared.journalEntries) { (journalEntry) -> Date in
                //force unwrap??
                //return firstDayOfMonth(date: journalEntry.journalEntryDate!)
                return firstDayOfMonth(date: journalEntry.journalEntryDate ?? Date())
            }
            
            //????? - init(month:journalEntries:)
            return groups.map(MonthSection.init(month:journalEntries:)).sorted()
        }
    }
}

