# [Journal](https://apps.apple.com/us/app/conscious-journal/id6446703762)
Conscious Journal is a mobile journaling app designed for users to practice gratitude and connect with their inner consciousness. Key features include search functionality, date filtering, and daily motivational quotes. Check out my [portfolio](https://dominiquestrachan.squarespace.com) to see features.

# MVC
## Journal

### Model
The Journal entity class is made from the Core Data Model editor with entryText, journalDateString, journalEntryDate, monthSection, and monthYearString as String and Date data types. 

### Model Controller
**JournalManagerr**<br>
The JournalManager is a singleton class containing CRUD methods for when a user creates, reads, updates, and deletes a journal entry. The class initializes a journal fetch request of type NSFetchRequest to access sorting features inside the table view.  Its extension contains Date type conversion methods to strings to be read for table view sections and searches. Sections are determined by the month and year date components. Dates can be searched by short dateStyle and month year dateFormat. 

### View Controller
**HomeTableViewController**<br>
The HomeTableViewController class is a subclass of UITableViewController containing a UITableView and a UISearchBar. Journal entries are fetched by NSFetchedResultsController, managed by NSManagedObjectContext, and sorted in descending order by NSSortDescriptor. When the user scrolls, the navigation bar’s tintColor will change. The sections are grouped by month and year and are displayed with a custom UIFont and tintColor. Each cell contains a title (short DateStyle) and subtitle (day of the week) with custom UIfonts and UIcolors. To delete a cell, the user swipes left with UISwipeActionsConfiguration. The UIContextualAction determines when the cell is deleted, and the delete button has a custom UIColor with the backgroundColor property.

There’s an extension conforming to NSFetchedResultsControllerDelegate to reload and make changes to the table view when cells are inserted, deleted, and updated with a fade animation. The UISearchBar filters journal entries by NSPredicates formatted by short DateStyle and month-year DateFormat. When tapping the search bar, a cancel button will appear to delete the search text and reload the table view. When the user starts typing, an x button will show and apply the same action. Lastly, each table view row contains a segue that identifies the cell's index path to show the journal object inside the JournalEntryDetailView.
<br>
**JournalEntryViewController**<br>
The JournalEntryViewController class is a subclass of UIViewController containing a UIDatePicker, UITextView, UILabel, and UIButton. The lifecycle methods customize the UITextView’s cornerRadius and tintColor when the view loads. In addition, the UILabel is hidden when the text view is empty and assigned to a placeholder value. The view’s original content’s inset and offset will be determined by the UITextView’s contentInset and contentOffset properties. When the view appears and disappears, the NotificationCenter will notify and subscribe keyboard observers. ContentInset and verticalScrollIndicatorInsets are adjusted based on the keyboard. The action method will create and/or update the journal entry when the user taps the save button. 

The helper methods present an initial alert and enable UITapGestureRecognizer. The tap gesture recognizer will determine when the user is done typing and dismiss the keyboard. 

The extension conforms to UITextViewDelegate and hides the placeholder label once the user begins typing inside the text view. When the keyboard shows, padding will be added to the bottom of UITextView's contentInset and verticalScrollIndicatorInsets to avoid text from being typed behind the keyboard based on the height of the keyboard. When the keyboard hides, the UITextView will scroll up to its original position based on contentInset and contentOffset properties.

## Quote

### Model
The Quote entity class is defined with quote and author properties as String data types and coding keys to be decoded from the [Zen Quotes API](https://zenquotes.io/).

### Model Controller
**QuoteManager**<br>
The QuoteManager struct constructs the API’s URL and fetches a quote. The struct contains properties including a singleton, baseURL, which converts the URL string to locate the API’s resource, and a todayComponent to be appended to the resource’s path. The fetchQuote helper method is a network call containing a callback closure parameter that will return Void. The closure asynchronously delivers a Result of type Quote or NetworkError. NetworkError is defined by an enum that conforms to the Error protocol with 5 cases and a computed property. The computed property returns an optional error message for each case. The invalidData case requires a String input that will access the localized error description. 
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
The HTTP GET request is loaded with URLRequest. Data from the request is retrieved with URLSession’s dataTask completion handler. The .resume() method is attached to the completion handler to start the network call. The dataTask(with:completionHandler:) accesses data, response, and error. If the response status code is 200, then the nested Quote JSON object will be decoded with a do try catch statement. 

### View Controller
**QuoteViewController**<br>
The QuoteViewController is a subclass of UIViewController containing a UILabel, UIButton, and a fetchQuote() helper method. In storyboard, the view controller is presented modally with a segue attached to a button inside the HomeTableViewController’s navigation bar. The UILabel is assigned to the quote property, and the UIButton dismisses the modal view. The helper method calls the fetchQuote method from QuoteManager and handles the Result with a switch statement. If the Result is a success case, then the quote label will be assigned to a String interpolated with the quote and author properties. If the result is a failure case, then there will be an error print statement.

# UIKit
### HomeTableViewController
**UIButton**<br> 
The left navigation bar button is labeled with a system image that contains a segue in storyboard to present the QuoteViewController. 

**UIButton**<br>
The right navigation bar button is labeled with a system image that contains a segue in storyboard to present the JournalEntryViewController.  

**UISearchBar**<br>
The search bar is located below the navigation bar. HomeTableViewController conforms to UISearchBarDelegate to implement searches based on journal entry date predicates. Date types are converted to String types to format NSPredicates. 

**UITableView**<br>
Table view cells contain a short dateStyle title and “EEEE” dateFormat subtitle. Each cell contains a segue coded programatically to identify the Journal object’s indexPath and pass the object to the JournalEntryViewController.<br><br>

### JournalEntryViewController
**UIDatePicker**<br>
The date picker is located below the navigation bar and assigns the Date to journalEntryDate and monthSection properties. 

**UITextView**<br>
The text view is located below the date picker and assigns a String to the entryText property. Its cornerRadius and tintColor are coded programmatically, and the font is assigned in storyboard. 

**UILabel**<br>
The label is located inside the text view and is a placeholder label. The label will be hidden when the user begins typing. 

**UITapGestureRecognizer**<br>
A tap gesture recognizer is added to this view to dismiss the keyboard when the user taps outside the text view. 

**UIEdgeInsets**<br>
The text view’s edge insets contain bottom padding to avoid text being typed behind the keyboard. 

**UIButton**<br>
The right navigation bar button is labeled with a system image that is coded programmatically with an @IBAction attribute. The button triggers a save action for the Journal object to be either saved or updated.<br><br> 

### QuoteViewController
**UIButton**<br>
The button is located towards the top leading corner of the view and labeled with a system image. Its action is coded programmatically with an @IBAction attribute to dismiss the modal view. 

**UILabel**<br>
The quote label is assigned after the network call to show the quote of the day and its author. 

**UIImage**<br>
The image is from assets and shown for design purposes. 

# User Defaults
User Defaults is used to store a Boolean value to show a one-time alert inside the JournalEntryViewController. The presentAlert() method initializes the UIAlertController class to create a warning message saying, “Once app is deleted, journal entries will not be saved” and sets the key to be true.

# Core Data
### Model
The Journal entity is structured from Core Data’s Data Model template. 

![data model](https://github.com/user-attachments/assets/a8416cf8-6f2a-4a6c-9b5e-d1c224bfa613)

### CoreDataStack
The CoreDataStack and save logic is coded with an enum rather than the AppDelegate for separation of concerns, cleaner code, and reusability. Using an enum with static properties instead of a class creates a lightweight singleton. 

```
enum CoreDataStack {
    static let journalContainer: NSPersistentContainer = {
        let journalContainer = NSPersistentContainer(name: "Journal")

        journalContainer.loadPersistentStores { storeDescription, error in
            if let error = error {
                fatalError("Error loading persistent stores \(error)")
            }
        }
        return journalContainer
    }()

    static var journalContext: NSManagedObjectContext { journalContainer.viewContext }

    static func saveJournalContext() {
        if journalContext.hasChanges {
            do {
                try journalContext.save()
            } catch {
                NSLog("Error saving context \(error)")
            }
        }
    }
}

// referencing instance
CoreDataStack.journalContainer
CoreDataStack.journalContext

// versus

class CoreDataStack { static let shared = CoreDataStack() }

// referencing instance
let stack = CoreDataStack.shared
stack.journalContainer
stack.journalContext

```

### Journal initializer 
The journal entity is initialized inside an extension with a convenience initializer for customization to avoid repetitive boilerplate code when creating a new Journal. The initializer contains a context property of type NSManagedObjectContext to centralize access to the container when saving changes.

### JournalManager
The JournalManager class contains CRUD methods. Rather than fetching Journal objects with a source of truth array, journal entries are fetched with NSFetchRequest. When creating and updating Journal, the CoreDataStack.saveJournalContext() method is called to identify changes in the NSManagedObjectContext and store persistent data into the NSPersistentContainer. To delete a Journal, the NSManagedObjectContext calls its delete method.

### HomeTableViewController
The HomeTableViewController class manages the fetched journal entries with NSFetchedResultsController. To initialize NSFetchedResultsController, the class requires the NSFetchRequest, NSManagedObjectContext, an optional String for sectionNameKeyPath, and an optional String for cacheName. The fetched data is sorted using NSSortDescriptor based on the journalEntryDate and monthSection properties. Since the fetch request is of type NSFetchRequest, the data can then be read and modified with the .sortDescriptor computed property to sort cells with the given descriptor. In addition, the table view class must conform to NSFetchedResultsControllerDelegate to update the table view when data changes.

# Restful API
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

# Improvements
