//
//  OhanaApp.swift
//  Ohana
//
//  Created by Charles Romeo on 12/7/23.
//

import SwiftUI
import RealmSwift
import Firebase

@main
struct OhanaApp: SwiftUI.App {
    
    init() {
        let realmConfiguration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
        Realm.Configuration.defaultConfiguration = realmConfiguration
        FirebaseApp.configure()
        
        newRealm().safeWrite { r in
            r.deleteAll()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
