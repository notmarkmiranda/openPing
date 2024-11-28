//
//  BottomSheetView.swift
//  openPing
//
//  Created by Mark Miranda on 11/27/24.
//

import SwiftUI

struct BottomSheetView: View {
  var siteToEdit: Site?
  var onSave: (Site) -> Void
  
  @FocusState private var isFocused: Bool
  @State private var url: String = ""
  @State private var selectedFrequency: Int? = nil
  @Environment(\.dismiss) private var dismiss
  
  let frequencies = [30, 60, 90, 120]
  
  @State private var showAlert = false
  @State private var alertTitle = ""
  @State private var alertMessage = ""
  
  private func createAndSaveSite(validatedURL: URL, frequency: Int) {
    let newSite = Site(
      id: siteToEdit?.id ?? UUID(),
      url: validatedURL.absoluteString,
      frequency: frequency,
      isSuccess: siteToEdit?.isSuccess ?? false,
      lastPingedAt: siteToEdit?.lastPingedAt
    )
    
    onSave(newSite)
  }
  
  var body: some View {
    VStack(spacing: 20) {
      // Title changes based on mode
      Text(siteToEdit == nil ? "Add New Site" : "Edit Site")
        .font(.headline)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
      
      // URL TextField with appropriate modifiers
      TextField("Enter URL", text: $url)
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .keyboardType(.URL)                      // URL-optimized keyboard
        .autocapitalization(.none)               // Disable autocapitalization
        .disableAutocorrection(true)             // Disable autocorrection
        .focused($isFocused)
        .onAppear {
          isFocused = true
          // Pre-populate fields if editing
          if let site = siteToEdit {
            url = site.url
            selectedFrequency = site.frequency
          }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
      
      // Frequency Picker
      VStack(alignment: .leading, spacing: 8) {
        Text("Frequency")
          .font(.subheadline)
          .foregroundColor(.secondary)
        
        Picker("Frequency", selection: $selectedFrequency) {
          Text("Select Frequency").tag(Int?.none)
          ForEach(frequencies, id: \.self) { frequency in
            Text("\(frequency) seconds").tag(Int?(frequency))
          }
        }
        .pickerStyle(MenuPickerStyle())
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(8)
      }
      .padding(.horizontal)
      
      // Button stack: Add and Cancel
      HStack(spacing: 16) {
        // Cancel Button
        Button(action: {
          dismiss()
        }) {
          Text("Cancel")
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.2))
            .foregroundColor(.blue)
            .cornerRadius(8)
        }
        .accessibilityLabel("Cancel")
        .accessibilityHint("Dismisses the form without adding or editing a site")
        
        // Add/Save Button
        Button(action: {
          // Validate input          
          guard let frequency = selectedFrequency, !url.trimmingCharacters(in: .whitespaces).isEmpty else {
            alertTitle = "Invalid Input"
            alertMessage = "Please enter a valid URL & select a frequency."
            showAlert = true
            return
          }
          
          let trimmedURL = url.trimmingCharacters(in: .whitespaces)
          
          // Attempting to parse the URL
          guard let initialURL = URL(string: trimmedURL) else {
            alertTitle = "Invalid URL"
            alertMessage = "Please enter a secure URL."
            showAlert = true
            return
          }
          
          if let scheme = initialURL.scheme?.lowercased() {
            if scheme == "https" {
              // Accept the URL as it is already HTTPS
              createAndSaveSite(validatedURL: initialURL, frequency: frequency)
            } else {
              // Reject unsupported schemes
              alertTitle = "Unsupported schemes"
              alertMessage = "Only HTTPS URLS are allowed."
              showAlert = true
              return
            }
          } else {
            // No scheme provided, prepend https://
            let httpsURLString = "https://\(trimmedURL)"
            guard let httpsURL = URL(string: httpsURLString) else {
              alertTitle = "Invalid URL"
              alertMessage = "Please enter a secure URL"
              showAlert = true
              return
            }
            createAndSaveSite(validatedURL: httpsURL, frequency: frequency)
          }
          
          // Dismiss the bottom sheet
          dismiss()
        }) {
          Text(siteToEdit == nil ? "Add" : "Save")
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .accessibilityLabel(siteToEdit == nil ? "Add new site" : "Save site")
        .accessibilityHint(siteToEdit == nil ? "Adds the new site with the entered URL and selected frequency." : "Saves the changes to the site with the entered URL and selected frequency.")
      }
      .padding(.horizontal)
      Spacer()
    }
    .padding()
    .alert(isPresented: $showAlert) {
      Alert(
        title: Text(alertTitle),
        message: Text(alertMessage),
        dismissButton: .default(Text("OK"))
      ) //Alert
    } // .alert
    .presentationDetents([.large])
  }
  
  struct BottomSheetView_Previews: PreviewProvider {
    static var previews: some View {
      BottomSheetView(siteToEdit: nil) { site in
        // Handle save action
      }
    }
  }
}
