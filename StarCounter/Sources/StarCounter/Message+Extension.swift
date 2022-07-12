//
//  File.swift
//  
//
//  Created by Majd Koshakji on 10/7/22.
//

import Foundation
import Swiftcord

extension Message {
    var messageURL: URL? {
        guard let guild = self.guild else { return nil }
        let string = "https://discord.com/channels/\(guild.id)/\(channel.id)/\(self.id)"
        return URL(string: string)
    }
}
