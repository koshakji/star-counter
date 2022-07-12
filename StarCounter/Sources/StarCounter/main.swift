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
let settings = Settings()
let starredMessages = MemoryStarredMessageStorage()

let bot = Swiftcord(
    token: settings.token,
    eventLoopGroup: eventLoop
)

let listener = StarCounter(bot: bot, settings: settings, starredMessages: starredMessages)

let activity = Activities(name: "for stars", type: .watching)
bot.editStatus(status: .online, activity: activity)

// Set intents which are required
bot.setIntents(intents: .guildMessages)
bot.setIntents(intents: .guildMessageReactions)

bot.addListeners(listener)
bot.connect()
