//
//  TableViewController.swift
//  Journal
//
//  Created by Dominique Strachan on 2/28/23.
//

import UIKit
import CoreData

class HomeTableViewController: UITableViewController, UISearchBarDelegate {

    // MARK: - Properties

    // Stores all journal entries grouped by month.
    // This is the full, unfiltered data source.
    var sections = [MonthSection]()

    // Stores the filtered journal entries when the user searches.
    // The table view will display this array.
    var filteredSections = [MonthSection]()

    // MARK: - Outlets
    @IBOutlet var journalTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - Keyboard

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self

        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )

        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        navBarSetup()
        
        // Change search bar cursor color
        searchBar.tintColor = UIColor(named: "DarkGrayPurple")

        JournalManager.shared.fetchJournalEntries()

        sections = MonthSection.group(
            journalEntries: JournalManager.shared.journalEntries
        )

        filteredSections = sections
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Refresh journal entries every time the home screen appears.
        JournalManager.shared.fetchJournalEntries()

        // Regroup all journal entries.
        sections = MonthSection.group(
            journalEntries: JournalManager.shared.journalEntries
        )

        if let searchText = searchBar.text,
           !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {

            filterJournalEntries(for: searchText)

        } else {

            filteredSections = sections
        }

        // Reload table so new, deleted, or filtered entries appear.
        journalTableView.reloadData()
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }

    // MARK: - Setup Methods

    func navBarSetup() {
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont(name: "Kohinoor Bangla", size: 20)!
        ]
    }

    // MARK: - Scroll View Methods

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y

        if offset > 1 {
            self.navigationController?.navigationBar.barTintColor = UIColor(named: "DarkGrayPurple")
        } else if offset == 0 {
            self.navigationController?.navigationBar.barTintColor = UIColor(named: "GrayPurple")
        }
    }

    // MARK: - Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // Display filtered sections instead of original sections.
        return filteredSections.count
    }

    override func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {

        let monthSection = filteredSections[section]
        let sectionDate = monthSection.month

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"

        return dateFormatter.string(from: sectionDate)
    }

    override func tableView(
        _ tableView: UITableView,
        willDisplayHeaderView view: UIView,
        forSection section: Int
    ) {
        view.tintColor = UIColor(named: "Header")

        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor(named: "Default")
        header.textLabel?.font = UIFont(name: "Kohinoor Bangla", size: 18)

        // Expands header frame.
        header.frame.size.width = 600
    }

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {

        let monthSection = filteredSections[section]
        return monthSection.journalEntries.count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "journalCell",
            for: indexPath
        )

        let monthSection = filteredSections[indexPath.section]
        let journalEntry = monthSection.journalEntries[indexPath.row]

        var newContent = cell.defaultContentConfiguration()

        // Cell text displays journal entry date.
        newContent.text = DateFormatter.journalEntryDate.string(
            from: journalEntry.journalEntryDate ?? Date()
        )

        newContent.textProperties.font = UIFont(
            name: "Avenir Next Regular",
            size: 20
        )!

        cell.contentConfiguration = newContent

        return cell
    }

    // MARK: - Delete Journal Entry

    override func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {

        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Delete"
        ) { [weak self] _, _, complete in

            guard let self = self else { return }

            // Get selected journal entry from filteredSections.
            let monthSection = self.filteredSections[indexPath.section]
            let journalEntry = monthSection.journalEntries[indexPath.row]

            // Delete from Core Data through JournalManager.
            JournalManager.shared.deleteJournalEntry(
                journalEntry: journalEntry
            )

            // Refresh original sections after deletion.
            JournalManager.shared.fetchJournalEntries()

            self.sections = MonthSection.group(
                journalEntries: JournalManager.shared.journalEntries
            )

            // Re-apply search if user is searching.
            if let searchText = self.searchBar.text,
               !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {

                self.filterJournalEntries(for: searchText)

            } else {

                self.filteredSections = self.sections
            }

            tableView.reloadData()

            complete(true)
        }

        deleteAction.backgroundColor = UIColor(named: "DarkGrayPurple")

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    // MARK: - Search Helper Method

    private func filterJournalEntries(for searchText: String) {
        let trimmedSearchText = searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        // If search text is empty, show all entries.
        guard !trimmedSearchText.isEmpty else {
            filteredSections = sections
            return
        }

        let lowercasedSearchText = trimmedSearchText.lowercased()

        // Flatten all sections into one array of journal entries.
        let allEntries = sections.flatMap { $0.journalEntries }

        // Filter journal entries by date string.
        let filteredEntries = allEntries.filter { journalEntry in
            let journalDate = journalEntry.journalEntryDate ?? Date()

            // Full month format
            let fullDateString = DateFormatter.journalEntryDate.string(
                from: journalDate
            )

            // Numeric format
            let numericDateString = DateFormatter.searchDate.string(
                from: journalDate
            )

            // Month-year section format
            let monthYearString = DateFormatter.monthYear.string(
                from: journalDate
            )

            return fullDateString.lowercased().contains(lowercasedSearchText)
                || numericDateString.lowercased().contains(lowercasedSearchText)
                || monthYearString.lowercased().contains(lowercasedSearchText)
        }

        // Regroup filtered results by month.
        filteredSections = MonthSection.group(
            journalEntries: filteredEntries
        )
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "toJournalEntryDetails",
           let indexPath = journalTableView.indexPathForSelectedRow,
           let destination = segue.destination as? JournalEntryViewController {

            let monthSection = filteredSections[indexPath.section]
            let journalEntry = monthSection.journalEntries[indexPath.row]

            destination.journalEntries = journalEntry
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterJournalEntries(for: searchText)
        journalTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - Month Section

extension HomeTableViewController {

    struct MonthSection: Comparable {
        var month: Date
        var journalEntries: [Journal]

        static func firstDayOfMonth(date: Date) -> Date {
            let calendar = Calendar.current
            let components = calendar.dateComponents(
                [.year, .month],
                from: date
            )

            return calendar.date(from: components)!
        }

        static func < (
            lhs: HomeTableViewController.MonthSection,
            rhs: HomeTableViewController.MonthSection
        ) -> Bool {
            return lhs.month > rhs.month
        }

        static func group(journalEntries: [Journal]) -> [MonthSection] {

            // Important:
            // Use the journalEntries parameter here.
            // Do NOT use JournalManager.shared.journalEntries directly,
            // or search filtering will not work.
            let groups = Dictionary(grouping: journalEntries) { journalEntry -> Date in
                return firstDayOfMonth(
                    date: journalEntry.journalEntryDate ?? Date()
                )
            }

            return groups.map(
                MonthSection.init(month: journalEntries:)
            ).sorted()
        }
    }
}

