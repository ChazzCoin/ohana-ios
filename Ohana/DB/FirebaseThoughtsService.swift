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
    @Published var realmInstance: Realm = newRealm()
    @Published var reference: DatabaseReference = Database
        .database()
        .reference()
        .child("thoughts")
    @Published var observerHandle: DatabaseHandle?
    @Published var observerChildAdded: DatabaseHandle?
    @Published var observerChildDeleted: DatabaseHandle?
    @Published var observerChildChanged: DatabaseHandle?
    @Published var isObserving = false
    @Published var isDeleted: Bool = false
    
    @Published var thoughts: [Thought] = []

    func startObserving(realm: Realm?=newRealm(), completion: @escaping (DataSnapshot) -> Void = { _ in }) {
        guard !isObserving else { return }
        
        observerHandle = self.reference.observe(.value, with: { snapshot in
            if let temp = snapshot.toLudiObjects(Thought.self, realm: realm) {
                self.thoughts.removeAll()
                self.thoughts = Array(temp)
                print("All thoughts: \(self.thoughts)")
            }
            completion(snapshot)
        })
        
        observerChildDeleted = self.reference.observe(.childRemoved, with: { snapshot in

            if snapshot.exists() {
                snapshot.parseSingleObject { obj in
                    if let objId = obj["id"] as? String {
                        
                        var temp = self.thoughts
                        for it in 0...temp.count {
                            if temp[it].id == objId {
                                temp.remove(at: it)
                            }
                        }
                        
                        if let obj = self.realmInstance.findByField(Thought.self, value: objId) {
                            if !obj.isValid() {return}
                            self.realmInstance.safeWrite { r in
                                r.delete(obj)
                            }
                        }
                        
                        self.thoughts = temp
                    }
                }
            }
        })
        
        isObserving = true
    }
    
    func startObserving(id: String, realm: Realm?=newRealm(), completion: @escaping (Thought) -> Void = { _ in }) {
        guard !isObserving else { return }
        // On Changed
        observerChildChanged = self.reference.child(id).observe(.value, with: { snapshot in
            if let results = snapshot.toLudiObject(Thought.self, realm: realm) {
                if results.id == id { completion(results) }
            }
        })
        
        // On Delete
        observerChildDeleted = self.reference.observe(.childRemoved, with: { snapshot in
            if snapshot.exists() {
                if let obj = self.realmInstance.findByField(Thought.self, value: id) {
                    self.isDeleted = true
                    if obj.isInvalidated {return}
                    self.realmInstance.safeWrite { r in
                        r.delete(obj)
                    }
                }
            }
        })
        isObserving = true
    }

    func stopObserving() {
        guard isObserving, let handle = observerHandle, let handle2 = observerChildDeleted, let handle3 = observerChildChanged else { return }
        reference.removeObserver(withHandle: handle)
        reference.removeObserver(withHandle: handle2)
        reference.removeObserver(withHandle: handle3)
        isObserving = false
        observerHandle = nil
    }
}

