//
//  Issue-CoreDataHelpers.swift
//  UltimateApp
//
//  Created by Rafael Peralta on 17/03/26.
//

import Foundation
internal import CoreData

extension Issue {
    var issueTitle: String {
        get {title ?? "" }
        set {title = newValue }
    }
    
    var issueContent: String {
        get { content ?? "" }
        set { content = newValue}
    }
    
    var issueCreationDate: Date {
        creationDate ?? .now
    }
    
    var issueModificationDate: Date {
        modificationDate ?? .now
    }
    
    static var example: Issue {
        let controller = DataController(inMemory: true)
        let viewContenxt = controller.container.viewContext
        
        let issue = Issue(context: viewContenxt)
        issue.title = "Example Issue"
        issue.content = "This is an example issue"
        issue.priority = 2
        issue.creationDate = .now
        return issue
    }
}
