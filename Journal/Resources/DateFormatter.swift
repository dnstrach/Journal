//
//  DateFormatter.swift
//  Journal
//
//  Created by Dominique Strachan on 2/28/23.
//

import Foundation

// MARK: - DateFormatter Helpers

extension DateFormatter {

    // Formats the journal entry date shown in each table cell.
    static let journalEntryDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter
    }()

    // Formats section/search text like "June 2026".
    static let monthYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    static let searchDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }()
}
