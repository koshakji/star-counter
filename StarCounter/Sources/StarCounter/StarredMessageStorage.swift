//
//  StarredMessageRepository.swift
//  
//
//  Created by Majd Koshakji on 12/7/22.
//


enum StorageError: Error {
    case alreadyExists
    case notFound
}

public protocol StarredMessageStorage {
    @discardableResult
    func add(message: StarredMessage) async throws -> StarredMessage
    func fetch(whereOriginalMessageID: UInt64) async throws -> StarredMessage
    func fetch(whereStarboardMessageID: UInt64) async throws -> StarredMessage
}


class MemoryStarredMessageStorage: StarredMessageStorage {
    private var store: [StarredMessage] = []
    
    func add(message: StarredMessage) async throws -> StarredMessage {
        let original = try? await self.fetch(whereOriginalMessageID: message.originalMessageID)
        guard original == nil else { throw StorageError.alreadyExists }
        
        
        let starboard = try? await self.fetch(whereStarboardMessageID: message.starboardMessageID)
        guard starboard == nil else { throw StorageError.alreadyExists }
        
        
        self.store.append(message)
        return message
    }
    
    func fetch(whereOriginalMessageID originalMessageID: UInt64) async throws -> StarredMessage {
        let message = self.store.first(where: { $0.originalMessageID == originalMessageID })
        guard let message = message else { throw StorageError.notFound }
        return message
    }
    
    func fetch(whereStarboardMessageID starboardMessageID: UInt64) async throws -> StarredMessage {
        let message = self.store.first(where: { $0.starboardMessageID == starboardMessageID })
        guard let message = message else { throw StorageError.notFound }
        return message
    }
}
