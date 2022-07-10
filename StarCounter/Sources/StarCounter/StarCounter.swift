import Foundation
import Swiftcord


public class StarCounter: ListenerAdapter {
    private weak var bot: Swiftcord?
    private var settings: Settings
    
    init(bot: Swiftcord) {
        self.bot = bot
        self.settings = Settings()
    }
    
    public override func onMessageReactionAdd(channel: Channel, messageId: Snowflake, userId: Snowflake, emoji: Emoji) async {
        guard emoji.tag == self.settings.emoji else {
            return
        }
        
        guard let message = try? await bot!.getMessage(messageId, from: channel.id) else {
            NSLog("Unable to resolve message \(messageId)")
            return
        }
        
        guard let reactors = try? await message.getReaction(emoji.name) else {
            NSLog("Unable to get reactions")
            return
        }
        
        let filtered = reactors.filter { user in
            user.id != message.author?.id
        }
        if filtered.count >= self.settings.count {
            await self.send(message: message, count: filtered.count)
        }
    }
    
    private func send(message: Message, count: Int) async {
        let channel = Snowflake(self.settings.channelID)
        let embed = await self.buildEmbed(for: message)
        
        do {
            _ = try await self.bot!.send(embed, to: channel)
            
        } catch {
            NSLog("Failed to send embed")
        }
    }
    
    private func buildEmbed(for message: Message) async -> EmbedBuilder {
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
