# [Journal](https://apps.apple.com/us/app/conscious-journal/id6446703762)
Conscious Journal is a mobile journaling app designed for users to practice gratitude and connect with their inner consciousness. Key features include search functionality, date filtering, and daily motivational quotes. Check out my [portfolio](https://dominiquestrachan.squarespace.com) to see features.

# MVC
## Journal

### Model
The Journal entity is made from the Core Data Model editor with entryText, journalDateString, journalEntryDate, monthSection, and monthYearString as String and Date types. 

### Model Controller
The JournalManager is a singleton class containing CRUD methods when a user creates, reads, updates, and deletes a journal entry. The class initializes a journal fetch request of type NSFetchRequest to access sorting features inside table view.  Its extention contains Date type conversion methods to strings to be read for table view sections and searches. Sections are determined by month and year date components. Dates can be searched by short date style and month year date format. 

### View Controller
**HomeTableViewController**<br>
The HomeTableViewController class is a subclass of UITableViewController containing a UITableView and UISearchBar bar. The helper methods construct table view sections and cells, design, and search filters. Journal entries are fetched by NSFetchedResultsController, managed by NSManagedObjectContext, and sorted in descending order by NSSortDescriptor. The navigation bar contains a custom UIFont for the app title. When the user scrolls, the navigation bar’s tintColor will change. The sections are grouped by month and year and are displayed with a custom UIFont and tintColor. Each cell also contains a title (short DateStyle) and subtitle (day of the week) with custom UIfonts and UIcolors. To delete a cell, the user swipes left with UISwipeActionsConfiguration. The UIContextualAction determines when the cell is deleted, and the delete button has a custom UIColor with the backgroundColor property.

There’s an extension that conforms to NSFetchedResultsControllerDelegate to reload and make changes to the table view when cells are inserted, deleted, and updated with a fade animation. The UISearchBar filters journal entries by NSPredicates formatted by short DateStyle and month-year DateFormat. When tapping the search bar, a cancel button will appear to delete the search text and reload the table view. When the user starts typing, a x button will show and apply the same action. Lastly, each cell contains a segue to the journal entry detail view.

**JournalEntryViewController**<br>
The JournalEntryViewController class is a subclass of UIViewController containing a UIDatePicker, UITextView, and UILabel. The lifecycle methods customize the UITextView’s cornerRadius and tintColor when the view loads. In addition, the UILabel is hidden if its text is not empty and assigned to a placeholder value. The view’s original content’s inset and offset will be determined by the UITextView’s contentInset and contentOffset properties. When the view appears and disappears, the NotificationCenter will notify and subscribe keyboard observers. Lastly, the action method will create and update the journal entry when the user taps on the save UIButton. 

The helper methods present an initial alert and enable UITapGestureRecognizer to determine when the user is done typing and to dismiss the keyboard. 

The extension conforms to UITextViewDelegate and hides the placeholder text once the user begins typing on the keyboard. When the keyboard shows, the UITextView will scroll up to avoid text from being typed behind the keyboard based on contentInset and verticalScrollIndicatorInsets properties. The keyboard will hide once the user taps outside the UITextView which enables it to scroll back to its original offset based on contentInset, verticalScrollIndicatorInsets, and contentOffset properties.

# UIKit

# User Defaults

# Core Data
CRUD

# NSFetchedResultsController 
Search

# Restful API

# Improvements
