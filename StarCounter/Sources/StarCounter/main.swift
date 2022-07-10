//
//  main.swift
//  
//
//  Created by Majd Koshakji on 10/7/22.
//

import Foundation
import Swiftcord
import NIO

let eventLoop = MultiThreadedEventLoopGroup(numberOfThreads: 4)

let bot = Swiftcord(
    token: "",
    eventLoopGroup: eventLoop
)

let activity = Activities(name: "for stars", type: .watching)
bot.editStatus(status: .online, activity: activity)

// Set intents which are required
bot.setIntents(intents: .guildMessages)
bot.setIntents(intents: .guildMessageReactions)

bot.addListeners(StarCounter(bot: bot))
bot.connect()
