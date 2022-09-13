//
//  DatabaseManager.swift
//  Chenjie_Xiong_Final
//
//  Created by Chenjie Xiong on 7/26/22.
//

import FirebaseFirestoreSwift
import FirebaseFirestore

class DatabaseManager {
    private let db = Firestore.firestore()
    private lazy var tasksCollection = db.collection("tasks")
    private var listener: ListenerRegistration?
    func addTask(_ task: Task, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            _ = try tasksCollection.addDocument(from: task, completion: { (error) in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(Void()))
                }
            })
            
        } catch (let error) {
            completion(.failure(error))
        }
    }
    func deleteTask(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        tasksCollection.document(id).delete { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    func editTask(id: String, title: String, deadline: Date?, completion: @escaping (Result<Void, Error>) -> Void) {
        let data: [String : Any] = ["title" : title, "deadline": deadline as Any]
        tasksCollection.document(id).updateData(data) { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    func addTasksListener(forDoneTask isDone: Bool, uid: String,  completion: @escaping (Result<[Task], Error>) -> Void) {
        listener = tasksCollection.whereField("isDone", isEqualTo: isDone).whereField("uid", isEqualTo: uid).order(by: "createAt", descending: true).addSnapshotListener( {(snapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                var tasks:[Task] = []
                snapshot?.documents.forEach({ (document) in
                    do {
                        let task = try document.data(as: Task.self)
                        tasks.append(task)
                        
                    } catch(let error) {
                        completion(.failure(error))
                    }
                   
                })
                completion(.success(tasks))
            }
        })
    }
   
    func updateTaskStatus(id: String, isDone: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        var fields:[String : Any] = [:]
        if isDone {
            fields = ["isDone": true, "doneAt": Date()]
        } else {
            fields = ["isDone": false, "doneAt": FieldValue.delete()]
        }
        tasksCollection.document(id).updateData(fields) { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}

