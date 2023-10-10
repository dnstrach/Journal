//
//  JournalViewController.swift
//  Journal
//
//  Created by Dominique Strachan on 2/28/23.
//

import UIKit

class JournalEntryViewController: UIViewController, UITextViewDelegate {

    //MARK: - Properties
    //landing pad from navigation segue
    var journalEntries: Journal?
    let seenWarningModalKey = "seenWarningModal"
    
    let viewContext = CoreDataStack.journalContext
    
    //computed property to track wether or not the user has seen warning alert by saving bool value into user defaults
    var userHasSeenModal: Bool {
        set {
            UserDefaults.standard.set(true, forKey: seenWarningModalKey)
        } get {
            UserDefaults.standard.bool(forKey: seenWarningModalKey)
        }
    }
    
    //MARK: - Outlets
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var entryTextView: UITextView!
//    @IBOutlet weak var dailyDescriptionTextView: UITextView!
//    @IBOutlet weak var affirmationTextView: UITextView!
//    @IBOutlet weak var treeImage: UIImageView!
    
    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // self.tabBarController?.tabBar.isHidden = true
        
        self.entryTextView.delegate = self
        
        //if else condition to set title for adding entry view controller and updating entry view controller
        if let journalEntry = journalEntries,
           let journalEntryDate = journalEntry.journalEntryDate {
            //updating journal entry but have already created entry details saved in date picker and text views
            datePicker.date = journalEntryDate
            entryTextView.text = journalEntry.entryText

        } 
        
        textViewShadow()
        presentAlert()
        //customizeDatePicker()
        
    }
    
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        entryTextView.text = nil
//    }
//    
//    func customizeDatePicker() {
//        datePicker.backgroundColor = .clear
//    }
//    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.view.endEditing(true)
//        super.touchesBegan(touches, with: event)
//    }
    

    //MARK: - Actions
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        guard let entryText = entryTextView.text else { return }
        
        
        //not included in guard because journalEntryDate has a default value
        let journalEntryDate = datePicker.date
          
        //saving button will either update or create journal entry
        if let journalEntry = journalEntries {
            JournalManager.shared.updateJournalEntry(journalEntry: journalEntry, journalEntryDate: journalEntryDate, entryText: entryText)
        } else {
            JournalManager.shared.createJournalEntry(journalEntryDate: journalEntryDate, entryText: entryText)
        }
        
        //dismiss nav controller after tapping save
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: - Helper Methods
    
    func textViewShadow() {
        
        entryTextView.layer.shadowColor = UIColor(named: "DarkGrayPurple")?.cgColor
        entryTextView.layer.shadowOffset = CGSize(width: -4.0, height: 4.0)
        entryTextView.layer.shadowRadius = 3.0
        entryTextView.layer.shadowOpacity = 1.0
        entryTextView.layer.masksToBounds = false
        entryTextView.layer.cornerRadius = 20
    }
    
    func presentAlert() {
        
        //do not present alert...return out of function
        if userHasSeenModal {
            return
        }
        
        let alert = UIAlertController(title: "Warning", message: "Once app is deleted, journal entries will not be saved", preferredStyle: .actionSheet)
        
        let okayAction = UIAlertAction(title: "Okay", style: .default)
        
        alert.addAction(okayAction)
        
        //once alert is presented set userSeenModal to true so that alert will not be shown again
        present(alert, animated: true) {
            self.userHasSeenModal = true
        }

    }

}
