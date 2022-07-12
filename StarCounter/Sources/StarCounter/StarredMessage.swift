//
//  StarredMessage.swift
//  
//
//  Created by Majd Koshakji on 12/7/22.
//


public struct StarredMessage: Codable {
    let originalMessageID: UInt64
    let originalChannelID: UInt64
    let starboardMessageID: UInt64
}
