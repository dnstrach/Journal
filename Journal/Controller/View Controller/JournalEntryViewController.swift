//
//  JournalViewController.swift
//  Journal
//
//  Created by Dominique Strachan on 2/28/23.
//

import UIKit

class JournalEntryViewController: UIViewController {

    //MARK: - Properties
    //landing pad from navigation segue
    var journalEntries: Journal?
    let seenWarningModalKey = "seenWarningModal"
    
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
    @IBOutlet weak var gratitudeTextView: UITextView!
    @IBOutlet weak var dailyDescriptionTextView: UITextView!
    @IBOutlet weak var affirmationTextView: UITextView!
    @IBOutlet weak var treeImage: UIImageView!
    
    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //if else condition to set title for adding entry view controller and updating entry view controller
        if let journalEntry = journalEntries,
           let journalEntryDate = journalEntry.journalEntryDate {
            title = "Journal Entry"
            //updating journal entry but have already created entry details saved in date picker and text views
            datePicker.date = journalEntryDate
            gratitudeTextView.text = journalEntry.gratitude
            dailyDescriptionTextView.text = journalEntry.dailyDescription
            affirmationTextView.text = journalEntry.affirmation
        } else {
            title = "Add Journal Entry"
        }
        
        textViewShadow()
        presentAlert()
        
    }
    

    //MARK: - Actions
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        guard let gratitude = gratitudeTextView.text,
              let dailyDescription = dailyDescriptionTextView.text,
              let affirmation = affirmationTextView.text else { return }
        
        //not included in guard because journalEntryDate has a default value
        let journalEntryDate = datePicker.date
          
        //saving button will either update or create journal entry
        if let journalEntry = journalEntries {
            JournalManager.shared.updateJournalEntry(journalEntry: journalEntry, journalEntryDate: journalEntryDate, gratitude: gratitude, dailyDescription: dailyDescription, affirmation: affirmation)
        } else {
            JournalManager.shared.createJournalEntry(journalEntryDate: journalEntryDate, gratitude: gratitude, dailyDescription: dailyDescription, affirmation: affirmation)
        }
        
        //dismiss nav controller after tapping save
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    @IBAction func datePickerTapped(_ sender: Any) {
        treeImage.shake()
    }
    
    //MARK: - Helper Methods
    
    func textViewShadow() {
        
        gratitudeTextView.layer.shadowColor = UIColor(red: 0.00, green: 0.00, blue: 0.00, alpha: 1.0).cgColor
        gratitudeTextView.layer.shadowOpacity = 0.25
        gratitudeTextView.layer.shadowOffset = CGSize(width: 8, height: 8)
        gratitudeTextView.layer.shadowRadius = 0
        
        dailyDescriptionTextView.layer.shadowColor = UIColor(red: 0.00, green: 0.00, blue: 0.00, alpha: 1.0).cgColor
        dailyDescriptionTextView.layer.shadowOpacity = 0.25
        
        dailyDescriptionTextView.layer.shadowOffset = CGSize(width: 8, height: 8)
        dailyDescriptionTextView.layer.shadowRadius = 0
        
        affirmationTextView.layer.shadowColor = UIColor(red: 0.00, green: 0.00, blue: 0.00, alpha: 1.0).cgColor
        affirmationTextView.layer.shadowOpacity = 0.25
        
        affirmationTextView.layer.shadowOffset = CGSize(width: 8, height: 8)
        affirmationTextView.layer.shadowRadius = 0
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
