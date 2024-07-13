//
//  File.swift
//  
//
//  Created by VoroninDE on 06.07.2024.
//

import Foundation
import Alamofire

struct Message: Encodable {
    let id: UUID
    let role: SenderRole
    let content: String
    let createAt: Date
}

class OpenAIService {
    
    private var endPointUrl = "https://api.openai.com/v1/chat/completions"
    @available(macOS 10.15.0, *)
    func sendMessage(messages: [Message]) async -> OpenAIChatResponse? {
        let openAIChatMessages = messages.map {
            OpenAIChatMessage(role: $0.role,
                              content: $0.content)
        }
        
        let body = OpenAIChatBody(model: "gpt-4o", messages: openAIChatMessages)
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(aiToken)"
        ]
        print(headers)
        print(body)
        return try? await AF.request(
            endPointUrl,
            method: .post,
            parameters: body,
            encoder: .json,
            headers: headers)
        .serializingDecodable(OpenAIChatResponse.self)
        .value
    }
}

struct OpenAIChatBody: Encodable {
    let model: String
    let messages: [OpenAIChatMessage]
}

struct OpenAIChatMessage: Codable {
    let role: SenderRole
    let content: String
}

enum SenderRole: String, Codable {
    case system
    case user
    case assistant
}

struct OpenAIChatResponse: Decodable {
    let choices: [OpenAIChatChoice]
}

struct OpenAIChatChoice: Decodable {
    let message: OpenAIChatMessage
}


