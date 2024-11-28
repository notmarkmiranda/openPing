//
//  EmptyStateView.swift
//  openPing
//
//  Created by Mark Miranda on 11/27/24.
//

import SwiftUI

struct EmptyStateView: View {
  var body: some View {
    VStack(spacing: 16) {
      Image(systemName: "tray")
        .resizable()
        .scaledToFit()
        .frame(width: 100, height: 100)
        .foregroundColor(.gray)
      
      Text("No Sites Added")
        .font(.title2)
        .foregroundColor(.gray)
      
      Text("Tap the plus button to add a new site to monitor its status.")
        .font(.subheadline)
        .multilineTextAlignment(.center)
        .foregroundColor(.gray)
        .padding(.horizontal, 40)
    }
    .padding()
  }
}

struct EmptyStateView_Previews: PreviewProvider {
  static var previews: some View {
    EmptyStateView()
      .previewLayout(.sizeThatFits)
  }
}
