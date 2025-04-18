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

##Quote

### Model
The Quote entity class is defined with quote and author properties as String data types and coding keys to be decoded from from the [Zen Quotes API](https://zenquotes.io/).

### Controller
The QuoteManager struct constructs the API’s url and fetches a quote. The struct contains properties including a singleton, baseURL which converts the URL string to locate the API’s resource, and a todayComponent to be appended to the resource’s path.  The fetchQuote helper method is a network call that uses a completion closure that will return a result of type Quote or NetworkError. NetworkError is defined by an enum that conforms to the Error protocol with 5 cases and a computed property. The computed property returns an optional error message for each case. The invalidData case requires a String input that will access the localized error description. 
```
enum NetworkError: Error {
    
    case baseURLError
    case builtURLError
    case invalidData(String)
    case noData
    case statusCode
    case unableToDecode
    
    var errorDescription: String? {
        switch self {
        case .baseURLError:
            return "Unable to reach the server due to invalid URL"
        case .builtURLError:
           return "Unable to reach the server due to invalid built URL"
        case .invalidData:
            return "Data error from API call"
        case .noData:
            return "The server responded with no data"
        case .statusCode:
           return "Status code error"
        case .unableToDecode:
            return "Unable to decode data"
        }
        
    }
    
}
```
The HTTP GET request is loaded with URLRequest. Data from the request is retrieved with URLSession’s dataTask completion handler which accesses the data, response, and error. If the response status code is 200 then the nested JSON object will be decoded with a do try catch statement. 
```
https://zenquotes.io/api/today

[
    {
        "q": "Still your waters.",
        "a": "Josh Waitzkin",
        "h": "<blockquote>&ldquo;Still your waters.&rdquo; &mdash; <footer>Josh Waitzkin</footer></blockquote>"
    }
]

```

# UIKit

# User Defaults

# Core Data
CRUD

# NSFetchedResultsController 
Search

# Restful API

# Improvements
