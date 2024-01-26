//
//  FirebaseThoughtsService.swift
//  Ohana
//
//  Created by Charles Romeo on 1/25/24.
//

import Foundation
import RealmSwift
import FirebaseDatabase

class FirebaseThoughtsService : ObservableObject {
    @Published var reference: DatabaseReference = Database
        .database()
        .reference()
        .child("thoughts")
    @Published var observerHandle: DatabaseHandle?
    @Published var isObserving = false

    func startObserving(realm: Realm?=newRealm(), completion: @escaping (DataSnapshot) -> Void = { _ in }) {
        guard !isObserving else { return }
        
        observerHandle = self.reference.observe(.value, with: { snapshot in
            let _ = snapshot.toLudiObjects(Thought.self, realm: realm)
            completion(snapshot)
        })
        isObserving = true
    }

    func stopObserving() {
        guard isObserving, let handle = observerHandle else { return }
        reference.removeObserver(withHandle: handle)
        isObserving = false
        observerHandle = nil
    }
}
