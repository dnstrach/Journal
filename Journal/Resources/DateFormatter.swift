//
//  DateFormatter.swift
//  Journal
//
//  Created by Dominique Strachan on 2/28/23.
//

import Foundation

//formats date --> month/date/year
extension DateFormatter {
    static let journalEntryDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
        
    }()
}
