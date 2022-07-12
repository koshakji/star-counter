//
//  Embed.swift
//  
//
//  Created by Majd Koshakji on 12/7/22.
//

import Swiftcord

struct Embed: Codable {
    /// Author dictionary from embed
    var author: Author?
    
    /// Title of the embed
    var title: String?
    
    /// Description of the embed
    var description: String?

    /// Fields for the embed
    var fields: [Field] = []

    /// Footer dictionary from embed
    var footer: Footer?

    /// Type of embed | Discord says this should be considered deprecated. As such we set as rich
    let type: String = "rich"

    /// URL of the embed
    var url: String?
    
    /// Image data from embed
    var image: File?

    /// Thumbnail data from embed
    var thumbnail: File?

    /// Video data from embed
    var video: File?
}

extension Embed {
    public struct Author: Codable {
        public var name: String
        public var url: String? = nil
        public var iconUrl: String? = nil
        
        func dictionary() -> [String: Any] {
            let dict: [String: Any] = [
                "name": name,
                "url": url,
                "icon_url": iconUrl,
            ]

            return dict
        }
        
    }

    public struct Field: Codable {
        public var name: String
        public var value: String
        public var isInline: Bool = false
        
        func dictionary() -> [String: Any] {
            let dict: [String: Any] = [
                "name": name,
                "value": value,
                "inline": isInline,
            ]
            
            return dict
        }
    }

    public struct Footer: Codable {
        public var text: String
        public var iconUrl: String? = nil
        
        func dictionary() -> [String: Any] {
            let dict: [String: Any] = [
                "text": text,
                "icon_url": iconUrl,
            ]
            
            return dict
        }
    }

    public struct File: Codable {
        public var url: String
        public var height: Int?
        public var width: Int?
        
        func dictionary() -> [String: Any] {
            let dict: [String: Any] = [
                "url": url,
                "height": height,
                "width": width,
            ]
            
            return dict
        }
    }
}

extension Embed {
    func builder() -> EmbedBuilder {
        let builder = EmbedBuilder()
        if let author {
            _ = builder.setAuthor(name: author.name, url: author.url, iconUrl: author.iconUrl)
        }
        
        if let title {
            _ = builder.setTitle(title: title)
        }
        
        if let description {
            _ = builder.setDescription(description: description)
        }
        
        fields.forEach { field in
            _ = builder.addField(field.name, value: field.value)
        }
        
        if let footer {
            _ = builder.setFooter(text: footer.text, url: footer.iconUrl)
        }
        
        if let image {
            _ = builder.setImage(url: image.url, height: image.height, width: image.width)
        }
        
        if let video {
            _ = builder.setVideo(url: video.url, height: video.height, width: video.width)
        }
        
        if let thumbnail {
            _ = builder.setThumbnail(url: thumbnail.url, height: thumbnail.height, width: thumbnail.width)
        }
        
        return builder
    }
    
    func dictionary() -> [String: Any] {
        let dict: [String: Any] = [
            "author": author?.dictionary(),
            "title": title,
            "description": description,
            "fields": fields.map { $0.dictionary() },
            "footer": footer?.dictionary(),
            "image": image?.dictionary(),
            "video": video?.dictionary(),
            "thumbnail": thumbnail?.dictionary()
        ]
        
        return dict
    }
}
