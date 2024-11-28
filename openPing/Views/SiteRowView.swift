//
//  SiteRowView.swift
//  openPing
//
//  Created by Mark Miranda on 11/27/24.
//

import SwiftUI

struct SiteRowView: View {
  let site: Site
  var onEdit: () -> Void
  var onDelete: () -> Void
  
  var body: some View {
    HStack {
        RoundedRectangle(cornerRadius: 4)
            .fill(site.isSuccess ? Color.green : Color.red)
            .frame(width: 20) // Fixed width
            .frame(maxHeight: .infinity) // Fill row height
            .padding(.trailing, 8)
        
        VStack(alignment: .leading, spacing: 4) {
          Text(site.url)
            .font(.headline)
          Text("Frequency: \(site.frequency) seconds")
            .font(.subheadline)
            .foregroundColor(.secondary)
          if let lastPingedAt = site.lastPingedAt {
            Text("Last Pinged: \(lastPingedAt, formatter: DateFormatter.shortDateTime)")
              .font(.caption)
              .foregroundColor(.gray)
          }
        }
    }
    .padding(.vertical, 8)
    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
        // Delete button
        Button(role: .destructive) {
            onDelete()
        } label: {
            Label("Delete", systemImage: "trash")
        }
        
        // Edit button
        Button(role: .none) {
            onEdit()
        } label: {
            Label("Edit", systemImage: "pencil")
        }
        .tint(.blue)
    }
  }
}


struct SiteRowView_Previews: PreviewProvider {
    static var previews: some View {
        SiteRowView(
            site: Site(url: "https://example.com", frequency: 30, isSuccess: true),
            onEdit: {},
            onDelete: {}
        )
        .previewLayout(.sizeThatFits)
    }
}
