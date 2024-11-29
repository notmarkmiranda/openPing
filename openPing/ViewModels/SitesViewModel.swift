//
//  SitesViewModel.swift
//  openPing
//
//  Created by Mark Miranda on 11/28/24.
//

import Foundation
import Combine
import BackgroundTasks

@MainActor // Ensures all properties and methods run on the main thread
class SitesViewModel: ObservableObject {
  static let shared = SitesViewModel()
  // Published property to notify views of data changes
  @Published var sites: [Site] = []
  
  private var cancellables = Set<AnyCancellable>()
  private let dataManager = SiteDataManager.shared

  init() {
    loadSites()

    // Observechanges to `sites` and save them automatically
    $sites
      .debounce(for: 0.5, scheduler: DispatchQueue.main) // Prevent excessive saves
      .sink { [weak self] updatedSites in
        self?.dataManager.saveSites(updatedSites)
      }
      .store(in: &cancellables)
  }

  // MARK: - Data Management

  /// Loads sites from local storage
  func loadSites() {
    sites = dataManager.loadSites()
    print("Loaded sites: \(sites)")
  }

  /// Adds a new site and performs an initial ping
  func addSite(_ site: Site) {
    sites.append(site)
    print("Added site: \(site)")
    performPing(for: site)
  }

  /// Updates an existing site and peforms a ping
  func updateSite(_ site: Site) {
    if let index = sites.firstIndex(where: { $0.id == site.id }) {
      sites[index] = site
      print("Updated site: \(site.url)")
      performPing(for: site)
    }
  }

  /// Deletes a site
  func deleteSite(_ site: Site) {
    if let index = sites.firstIndex(where: { $0.id == site.id }) {
      sites.remove(at: index)
      print("Deleted site: \(site.url)")
    }
  }

  // Toggles the isActive property for a site
  func toggleSiteActive(_ site: Site) {
    if let index = sites.firstIndex(where: { $0.id == site.id }) {
      var updatedSite = site
      updatedSite.isActive.toggle()
      sites[index] = updatedSite

      if updatedSite.isActive {
        performPing(for: updatedSite)
      }

      print("Toggled site active status: \(site.url) - isActive: \(updatedSite.isActive)")
    }
  }

  // MARK: - Ping Operations

  /// Performs an asynchronous ping for a given site
  private func performPing(for site: Site) {
    Task { [weak self] in
      guard let self = self else { return }
      if let index = sites.firstIndex(where: { $0.id == site.id }) {
        let updatedSite = await self.sites[index].ping()
        self.sites[index] = updatedSite
        print("Performed ping for \(updatedSite.url)")
      }
    }
  }
}

