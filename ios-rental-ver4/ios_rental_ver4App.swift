//
//  ios_rental_ver4App.swift
//  ios-rental-ver4
//
//  Created by user211681 on 5/20/22.
//

import SwiftUI

@main
struct ios_rental_ver4App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
