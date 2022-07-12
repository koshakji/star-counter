import Foundation
import Swiftcord


public class StarCounter<Storage: StarredMessageStorage>: ListenerAdapter {
    private weak var bot: Swiftcord?
    private var settings: Settings
    private var starredMessages: Storage
    
    private var boardChannel: Snowflake {
        return Snowflake(self.settings.channelID)
    }
    
    init(
        bot: Swiftcord,
        settings: Settings,
        starredMessages: Storage
    ) {
        self.bot = bot
        self.settings = settings
        self.starredMessages = starredMessages
    }
    
    public override func onMessageReactionAdd(channel: Channel, messageId: Snowflake, userId: Snowflake, emoji: Emoji) async {
        guard emoji.tag == self.settings.emoji else {
            return
        }
        
        let originalMessageID: Snowflake
        let channelID: Snowflake
        let boardMessageID: Snowflake?
        
        if let existing = try? await self.starredMessages.fetch(whereStarboardMessageID: messageId.rawValue) {
            originalMessageID = Snowflake(existing.originalMessageID)
            channelID = Snowflake(existing.originalChannelID)
            boardMessageID = Snowflake(existing.starboardMessageID)
        } else {
            originalMessageID = messageId
            channelID = channel.id
            boardMessageID = nil
        }
        
        guard let originalMessage = try? await bot!.getMessage(originalMessageID, from: channelID) else {
            NSLog("Unable to fetch message details")
            return
        }
        
        guard originalMessage.author?.id != userId else { return }
        
        guard var reactingUsers = try? await originalMessage.getReaction(emoji.name) else {
            NSLog("Unable to fetch message reactions")
            return
        }
        
        if let boardMessageID,
           let boardMessage = try? await bot!.getMessage(boardMessageID, from: self.boardChannel),
            let boardReactingUsers = try? await boardMessage.getReaction(emoji.name) {
            
            reactingUsers += boardReactingUsers
        }
        
        let userIDs = Set(reactingUsers.map(\.id).filter { $0 != originalMessage.author?.id })
        
        if userIDs.count >= self.settings.count {
            await self.sendOrUpdate(message: originalMessage, reactionCount: userIDs.count, boardMessageID: boardMessageID)
        }
    }
    
    func sendOrUpdate(message: Message, reactionCount count: Int, boardMessageID: Snowflake? = nil) async {
        let embed = await self.buildEmbed(for: message, withCount: count)
        let channel = self.boardChannel

        if let boardMessageID {
            do {
                try await self.bot!.editMessage(boardMessageID, with: ["embeds": [embed]], in: channel)
                NSLog("Message edited successfully")
            } catch {
                NSLog("Failed to update message \(boardMessageID) in \(channel)")
            }
        } else {
            do {
                let boardMessage = try await self.bot!.send(embed, to: channel)
                NSLog("Message Sent Succssfully")
                
                let stored = StarredMessage(originalMessageID: message.id.rawValue, originalChannelID: message.channel.id.rawValue, starboardMessageID: boardMessage.id.rawValue)
                
                try await self.starredMessages.add(message: stored)
            } catch is StorageError {
                NSLog("Couldn't store message")
            } catch {
                NSLog("Failed to send message")
            }
        }
    }
    
    private func buildEmbed(for message: Message, withCount count: Int) async -> EmbedBuilder {
        let embed = EmbedBuilder()
        
        if let user = message.author,
           let username = user.username,
            let discriminator = user.discriminator {
            _ = embed.setAuthor(
                name: "\(username)#\(discriminator)",
                iconUrl: user.imageUrl()?.absoluteString
            )
        }
        
        _ = embed.addField("Channel:", value: "<#\(message.channel.id)>")
        _ = embed.addField("Content:", value: message.content)
        _ = embed.addField("Count:", value: "\(count)")
        
        if let attachment = message.attachments.last {
            _ = embed.setImage(url: attachment.url)
        }
        
        if let referenced = message.refrencedMessage {
            _ = embed.addField("Replying to:", value: referenced)
        }
        
        if let messageURL = message.messageURL {
            _ = embed.addField("Original Message:", value: messageURL.absoluteString)
        }
        return embed
    }
}
