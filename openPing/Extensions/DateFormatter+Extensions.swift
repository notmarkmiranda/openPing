//
//  DateFormatter+Extensions.swift
//  openPing
//
//  Created by Mark Miranda on 11/27/24.
//

import Foundation

extension DateFormatter {
  static var shortDateTime: DateFormatter {
    let formatter = DateFormatter()
    
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    
    return formatter
  }
}
