//
//  QuoteViewController.swift
//  Journal
//
//  Created by Dominique Strachan on 2/28/23.
//

import UIKit

class QuoteViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        configureSheet()
        configureQuoteLabel()

        if QuoteManager.shared.hasQuoteForToday(),
           let savedQuote = QuoteManager.shared.fetchSavedQuote() {
            showQuote(savedQuote)
        } else {
            startLoading()
            fetchQuoteFromAPI()
        }
    }

    // MARK: - Actions

    @IBAction func xButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }

    // MARK: - Helper Methods

    private func fetchQuoteFromAPI() {
        QuoteManager.shared.fetchQuote { result in
            DispatchQueue.main.async {
                switch result {

                case .success(let quote):
                    QuoteManager.shared.saveQuote(quote: quote)
                    self.showQuote(quote)

                case .failure(let error):
                    print("Error: \(error)")
                    self.showErrorMessage()
                }
            }
        }
    }

    /// Shows loading spinner while quote is loading
    private func startLoading() {
        quoteLabel.isHidden = true

        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }

    /// Displays quote and hides spinner
    private func showQuote(_ quote: Quote) {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true

        quoteLabel.isHidden = false

        // Full text shown in the label
        let quoteText = """
        “\(quote.quote)”

        — \(quote.author)
        """

        // Controls spacing between lines
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 10

        // Style the entire quote label
        let attributedText = NSMutableAttributedString(
            string: quoteText,
            attributes: [
                .font: UIFont(name: "Avenir Next Regular", size: 28) ?? UIFont.systemFont(ofSize: 28, weight: .regular),
                .foregroundColor: UIColor.label,
                .paragraphStyle: paragraphStyle
            ]
        )

        // Style the author differently from the quote
        let authorText = "— \(quote.author)"
        let authorRange = (quoteText as NSString).range(of: authorText)

        attributedText.addAttributes(
            [
                .font: UIFont(name: "Avenir Next Medium", size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .medium),
                .foregroundColor: UIColor.secondaryLabel
            ],
            range: authorRange
        )

        quoteLabel.attributedText = attributedText
    }

    /// Shows a simple error message if the API request fails
    private func showErrorMessage() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true

        quoteLabel.isHidden = false
        quoteLabel.textAlignment = .center
        quoteLabel.text = "Unable to load quote."
    }

    /// Configures modal sheet height
    private func configureSheet() {
        if let sheet = sheetPresentationController {
            // Opens smaller, but user can drag larger for long quotes
            sheet.detents = [.medium(), .large()]

            // Shows grabber at the top of the sheet
            sheet.prefersGrabberVisible = true

            // Starts at medium size
            sheet.selectedDetentIdentifier = .medium
        }
    }

    /// Configures label for long quotes
    private func configureQuoteLabel() {
        // Allows quote to wrap onto multiple lines
        quoteLabel.numberOfLines = 0
        quoteLabel.lineBreakMode = .byWordWrapping

        // Centers quote text
        quoteLabel.textAlignment = .center

        // Prevents text from shrinking too small
        quoteLabel.adjustsFontSizeToFitWidth = false
    }
}
