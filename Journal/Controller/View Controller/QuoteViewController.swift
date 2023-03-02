//
//  QuoteViewController.swift
//  Journal
//
//  Created by Dominique Strachan on 2/28/23.
//

import UIKit

class QuoteViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var riverImage: UIImageView!
    @IBOutlet weak var quoteLabel: UILabel!
    
    //MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchQuote()
    }
    
    //MARK: - Actions
    //dismiss modal
    @IBAction func xButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    @IBAction func quoteButton(_ sender: Any) {
        riverFlowsOffScreen(image: riverImage)
    }
    
    //MARK: - Helper Methods
    //fetching quote with fetchQuote completion handler
    private func fetchQuote() {
        QuoteManager.shared.fetchQuote { result in
            switch result {
            case .success(let quote):
                //main thread so quote shows for view controller
                DispatchQueue.main.async {
                    self.quoteLabel.text = "\(quote.quote)\n\n- \(quote.author)"
                }
                QuoteManager().saveQuote(quote: quote)
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    func riverFlowsOffScreen(image: UIImageView) {
        let center = image.center
        UIImageView.animateKeyframes(withDuration: 1.0, delay: 0.0) {
            UIImageView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.25, animations: {
                image.center.x += 10.0
                image.center.y -= 10.0
            })
            
            UIImageView.addKeyframe(withRelativeStartTime: 0.55, relativeDuration: 0.55) {
                image.center = center
                image.alpha = 1.0
            }
        }
    }

}
