//
//  ContentView.swift
//  openPing
//
//  Created by Mark Miranda on 11/24/24.
//

import SwiftUI

struct ContentView: View {
  @State private var isSheetPresented = false
  @StateObject private var viewModel = SitesViewModel.shared
  @State private var showDeleteConfirmation = false
  @State private var siteToEdit: Site? = nil
  @State private var siteToDelete: Site? = nil
  
  var body: some View {
    NavigationView {
      VStack {
        if viewModel.sites.isEmpty {
          EmptyStateView()
        } else {
          List {
            ForEach(viewModel.sites) { site in
              SiteRowView(
                site: site,
                onEdit: {
                  siteToEdit = site
                  isSheetPresented = true
                },
                onDelete: {
                  siteToDelete = site
                  showDeleteConfirmation = true
                }
              )
            }
          }
          .listStyle(PlainListStyle())
        }
      }
      .navigationTitle("Open Ping")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {
            siteToEdit = nil
            isSheetPresented = true
          }) {
            Image(systemName: "plus")
          }
        }
      }
      .sheet(isPresented: $isSheetPresented) {
        BottomSheetView(siteToEdit: siteToEdit) { site in
          if siteToEdit == nil {
            viewModel.addSite(site)
          } else {
            viewModel.updateSite(site)
          }
        }
      }
      .alert(isPresented: $showDeleteConfirmation) {
        Alert(
          title: Text("Are you sure?"),
          message: Text("Do you really want to delete this site?"),
          primaryButton: .destructive(Text("Delete")) {
            if let site = siteToDelete {
              viewModel.deleteSite(site)
              siteToDelete = nil
            }
          },
          secondaryButton: .cancel {
            siteToDelete = nil
          }
        )
      }
    }
    .onAppear {
      viewModel.loadSites()
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      ContentView()
        .preferredColorScheme(.light) // Light Mode Preview
      
      ContentView()
        .preferredColorScheme(.dark)  // Dark Mode Preview
    }
  }
}
