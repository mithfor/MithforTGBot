// The Swift Programming Language
// https://docs.swift.org/swift-book


import Foundation
import TelegramBotSDK

enum CommonCommands: CaseIterable {
    case greet
    case name
    case start
    case help
    case chatGPT
    
    var description: String {
        switch self {
        case .greet:
            return "greet"
        case .name:
            return "name"
        case .start:
            return "start"
        case .help:
            return "help"
        case .chatGPT:
            return "chatGPT"
        }
    }
    
    var comment: String {
        switch self {
        case .chatGPT:
             return " (deprecated). Use simple question instead"
        default:
            return ""
        }
    }
}

// MARK: - Constants
let tgToken = readToken(from: "TG_TOKEN")
let aiToken = readToken(from: "AI_TOKEN")
let botName = "MithforTelegramBot"

// MARK: - Services Initialization
let bot = TelegramBot(token: tgToken)
let router = Router(bot: bot)
router.partialMatch = nil
let aiService = OpenAIService()
var isChatGptConversationStarted = false

// MARK: - Helper Functions

@available(macOS 10.15.0, *)
func asyncTaskForAIService(promptText: String, context: Context, role: SenderRole = .user) async throws {
    let aiMessage = Message(
        id: UUID(),
        role: role,
        content: promptText,
        createAt: Date()
    )
    let responseText = await aiService.sendMessage(
        messages: [aiMessage]
    )
    
    context.respondAsync(responseText?.choices.first?.message.content ?? noResponseFromChatGPT)
}

// MARK: - Response handlers

let noResponseFromChatGPT = "\(botName): No response from chatGPT... \n Developer! Check VPN-connection or token!"
let responseFromChatGPT = "\(botName): ChatGPT activated."

// MARK: - Command Handlers

func greetHandler(context: Context) -> Bool {
    guard let from = context.message?.from else { return false }
    context.respondAsync("Hello \(from.firstName)")
    return true
}

func newChatMembers(context: Context) -> Bool {
    guard let users = context.message?.newChatMembers else { return false }
    for user in users {
        guard user.id != bot.user.id else { continue }
        context.respondAsync("Welcome, \(user.firstName)!")
    }
    return true
}

func nameHandler(context: Context) -> Bool {
    let text = "My name is MithforTelegramBot"
    context.respondAsync(text)
    return true
}

func startHandler(context: Context) -> Bool {
    if #available(macOS 10.15, *) {
        Task {
            let promptText = "Hello. You will provide a detailed overview of Latoken. Discuss its history, key features, and services it offers. Additionally, explain the platform's security measures, the types of assets available for trading, the user experience, and any notable partnerships or achievements."
            context.respondAsync("Starting...")
            do {
                try await asyncTaskForAIService(promptText: promptText, context: context, role: .system)
                context.respondAsync(responseFromChatGPT)
                isChatGptConversationStarted = true
            } catch {
                context.respondAsync(noResponseFromChatGPT)
                isChatGptConversationStarted = false
            }
        }
    } else {
        // Fallback on earlier versions
        print("Unsupported macOS version. Please update to macOS 10.15 or later.")
    }
    return true
}

func helpHandler(context: Context) -> Bool {
    for cmd in CommonCommands.allCases {
        context.respondAsync("\(cmd.description) \(cmd.comment)")
    }
    return true
}

func chatGPTHandler(context: Context) -> Bool {
//    if #available(macOS 10.15, *) {
//        Task {
//            context.respondAsync("Processing...")
//            let messageText = context.args.scanRestOfString()
//            await asyncTaskForAIService(promptText: messageText, context: context)
//        }
//    } else {
//        // Fallback on earlier versions
//        print("Unsupported macOS version. Please update to macOS 10.15 or later.")
//    }
//    return true
    context.respondAsync("\(CommonCommands.chatGPT.description) \(CommonCommands.chatGPT.comment)")
    return defaultHandler(context: context)
}

func defaultHandler(context: Context) -> Bool {
    if isChatGptConversationStarted {
        if #available(macOS 10.15, *) {
            Task {
                context.respondAsync("Processing...")
                let messageText = context.args.scanRestOfString()
                try await asyncTaskForAIService(promptText: messageText, context: context)
            }
        } else {
            // Fallback on earlier versions
            print("Unsupported macOS version. Please update to macOS 10.15 or later.")
        }
    } else {
        context.respondAsync("ChatGPT Conversation not initialized. Use /start command")
    }
    return true
}


// MARK: - Router Configuration

router[CommonCommands.greet.description] = greetHandler
router[CommonCommands.name.description] = nameHandler
router[CommonCommands.start.description] = startHandler
router[CommonCommands.help.description] = helpHandler
router[CommonCommands.chatGPT.description] = chatGPTHandler
router[.newChatMembers] = newChatMembers
router[.text] = defaultHandler

// MARK: - Main Update Loop
while let update = bot.nextUpdateSync() {
    print("Update: \(update)")
    try router.process(update: update)
}
