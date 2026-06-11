//
//  JournalViewController.swift
//  Journal
//
//  Created by Dominique Strachan on 2/28/23.
//


import UIKit

class JournalEntryViewController: UIViewController, UITextViewDelegate {

    // MARK: - Properties

    // Landing pad from navigation segue.
    // If this has a value, the user is editing an existing journal entry.
    // If nil, the user is creating a new journal entry.
    var journalEntries: Journal?

    // UserDefaults key used to track whether the user has already seen the warning modal.
    let seenWarningModalKey = "seenWarningModal"

    // Core Data context.
    let viewContext = CoreDataStack.journalContext

    // Tracks whether the warning modal has already been shown.
    // Saves the value into UserDefaults so the alert only appears once.
    var userHasSeenModal: Bool {
        set {
            UserDefaults.standard.set(true, forKey: seenWarningModalKey)
        } get {
            UserDefaults.standard.bool(forKey: seenWarningModalKey)
        }
    }

    // MARK: - Outlets

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var entryTextView: UITextView!

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCustomNavButtons()
        configureTextView()

        // Receive UITextView delegate callbacks
        entryTextView.delegate = self

        // Enable scrolling for long journal entries
        entryTextView.isScrollEnabled = true

        // Allows keyboard to dismiss naturally while dragging
        entryTextView.keyboardDismissMode = .interactive

        // Listen for keyboard appearance/disappearance
        setupKeyboardObservers()

        // Dismiss keyboard when tapping outside text view
        setupTapGesture()

        if let journalEntry = journalEntries,
           let journalEntryDate = journalEntry.journalEntryDate {

            datePicker.date = journalEntryDate
            entryTextView.text = journalEntry.entryText
        }
        
        // Change cursor color
        entryTextView.tintColor = UIColor(named: "DarkGrayPurple")

        textViewShadow()
        presentAlert()
    }

    deinit {
        // Removes keyboard observers when this view controller is removed from memory.
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Actions

    @IBAction func saveButtonTapped(_ sender: Any) {

        // Get text from text view.
        guard let entryText = entryTextView.text else { return }

        // Date picker already has a default date, so it does not need to be optional.
        let journalEntryDate = datePicker.date

        // If journalEntries exists, update the existing entry.
        // Otherwise, create a new journal entry.
        if let journalEntry = journalEntries {
            JournalManager.shared.updateJournalEntry(
                journalEntry: journalEntry,
                journalEntryDate: journalEntryDate,
                entryText: entryText
            )
        } else {
            JournalManager.shared.createJournalEntry(
                journalEntryDate: journalEntryDate,
                entryText: entryText
            )
        }

        // Return to previous screen after saving.
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Keyboard Handling

    /// Registers this view controller to listen for keyboard show/hide events.
    private func setupKeyboardObservers() {

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    /// Called automatically when the keyboard is about to appear.
    @objc private func keyboardWillShow(_ notification: Notification) {

        // Get keyboard frame from notification.
        guard let keyboardFrame = notification.userInfo?[
            UIResponder.keyboardFrameEndUserInfoKey
        ] as? CGRect else { return }

        let keyboardHeight = keyboardFrame.height

        entryTextView.contentInset.bottom = keyboardHeight
        entryTextView.verticalScrollIndicatorInsets.bottom = keyboardHeight
    }

    /// Called automatically when the keyboard is about to hide.
    @objc private func keyboardWillHide(_ notification: Notification) {
        entryTextView.contentInset.bottom = 0
        entryTextView.verticalScrollIndicatorInsets.bottom = 0
    }

    // MARK: - Dismiss Keyboard

    /// Adds a tap gesture so tapping outside the text view dismisses the keyboard.
    private func setupTapGesture() {

        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )

        // Keeps buttons, date picker, and other controls tappable.
        tapGesture.cancelsTouchesInView = false

        view.addGestureRecognizer(tapGesture)
    }

    /// Dismisses the keyboard.
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    /// Dismisses the keyboard when the user starts scrolling.
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }

    // MARK: - Helper Methods

    /// Adds shadow and rounded corners to the text view.
    func textViewShadow() {
        entryTextView.layer.cornerRadius = 24
        entryTextView.clipsToBounds = true
        entryTextView.layer.masksToBounds = true
    }

    /// Shows warning alert only once.
    func presentAlert() {

        // If user has already seen this alert, exit the method.
        if userHasSeenModal {
            return
        }

        let alert = UIAlertController(
            title: "Warning",
            message: "Once app is deleted, journal entries will not be saved",
            preferredStyle: .actionSheet
        )

        let okayAction = UIAlertAction(
            title: "Okay",
            style: .default
        )

        alert.addAction(okayAction)

        // After presenting alert, save that the user has seen it.
        present(alert, animated: true) {
            self.userHasSeenModal = true
        }
    }
    
    // MARK: - Navigation Buttons

    private func configureCustomNavButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            customView: makeNavButton(
                title: "Back",
                systemImageName: "chevron.left",
                action: #selector(backButtonTapped)
            )
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            customView: makeNavButton(
                title: "Save",
                systemImageName: nil,
                action: #selector(saveButtonTapped(_:))
            )
        )
    }

    private func makeNavButton(
        title: String,
        systemImageName: String?,
        action: Selector
    ) -> UIButton {

        let button = UIButton(type: .system)

        var configuration = UIButton.Configuration.filled()
        configuration.title = title
        configuration.baseForegroundColor = UIColor.label
        configuration.baseBackgroundColor = .clear
        configuration.cornerStyle = .capsule
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 8,
            leading: 14,
            bottom: 8,
            trailing: 14
        )

        if let systemImageName {
            configuration.image = UIImage(systemName: systemImageName)
            configuration.imagePadding = 4
        }

        button.configuration = configuration
        button.addTarget(self, action: action, for: .touchUpInside)

        return button
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func configureTextView() {
        // Adds space inside the text view so text does not touch the edges
        entryTextView.textContainerInset = UIEdgeInsets(
            top: 20,
            left: 20,
            bottom: 20,
            right: 20
        )

        // Long journal entries scroll inside the text view
        entryTextView.isScrollEnabled = true

        // Keyboard dismisses smoothly when dragging
        entryTextView.keyboardDismissMode = .interactive

        // Better background color than pure white/black
        entryTextView.backgroundColor = UIColor.secondarySystemBackground
    }
}
