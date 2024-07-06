// The Swift Programming Language
// https://docs.swift.org/swift-book


import Foundation
import TelegramBotSDK

enum CommonCommands: CaseIterable {
    case greet
    case name
    case letStart
    case help
    case chatGPT
    
    var description: String {
        switch self {
        case .greet:
            return "greet"
        case .name:
            return "name"
        case .letStart:
            return "letstart"
        case .help:
            return "help"
        case .chatGPT:
            return "chatGPT"
        }
        
    }
}

// MARK: - Constants
let tgToken = readToken(from: "TG_TOKEN")
let aiToken = readToken(from: "AI_TOKEN")

// MARK: - Services Initialization
let bot = TelegramBot(token: tgToken)
let router = Router(bot: bot)
router.partialMatch = nil
let aiService = OpenAIService()

// MARK: - Helper Functions

@available(macOS 10.15.0, *)
func asyncTaskForAIService(promptText: String, context: Context) async {
    let aiMessage = Message(
        id: UUID(),
        role: .user,
        content: promptText,
        createAt: Date()
    )
    
    let text = await aiService.sendMessage(messages: [aiMessage])
    context.respondAsync(text?.choices.first?.message.content ?? "empty answer")
}

// MARK: - Command Handlers

func greetHandler(context: Context) -> Bool {
    guard let from = context.message?.from else { return false }
    context.respondAsync("Hello \(from.firstName)")
    return true
}

func nameHandler(context: Context) -> Bool {
    let text = "My name is MithforTelegramBot"
    context.respondAsync(text)
    return true
}

func letStartHandler(context: Context) -> Bool {
    if #available(macOS 10.15, *) {
        Task {
            let promptText = "You are Latoken assistant. You will help me to know about latoken as much as possible."
            await asyncTaskForAIService(promptText: promptText, context: context)
        }
    } else {
        // Fallback on earlier versions
        print("Unsupported macOS version. Please update to macOS 10.15 or later.")
    }
    return true
}

func helpHandler(context: Context) -> Bool {
    for cmd in CommonCommands.allCases {
        context.respondAsync(cmd.description)
    }
    return true
}

func chatGPTHandler(context: Context) -> Bool {
    if #available(macOS 10.15, *) {
        Task {
            context.respondAsync("Processing...")
            let messageText = context.args.scanRestOfString()
            await asyncTaskForAIService(promptText: messageText, context: context)
        }
    } else {
        // Fallback on earlier versions
        print("Unsupported macOS version. Please update to macOS 10.15 or later.")
    }
    return true
}

// MARK: - Router Configuration

router[CommonCommands.greet.description] = greetHandler
router[CommonCommands.name.description] = nameHandler
router[CommonCommands.letStart.description] = letStartHandler
router[CommonCommands.help.description] = helpHandler
router[CommonCommands.chatGPT.description] = chatGPTHandler

// MARK: - Main Update Loop
while let update = bot.nextUpdateSync() {
    print(update)
    try router.process(update: update)
}

//let tgToken = readToken(from: "TG_TOKEN")
//let aiToken = readToken(from: "AI_TOKEN")
//let bot = TelegramBot(token: tgToken)
//let router = Router(bot: bot)
//router.partialMatch = nil
//let aiService = OpenAIService()
//
//router[CommonCommands.greet.description] = { context in
//    guard let from = context.message?.from else { return false }
//    context.respondAsync("Hello \(from.firstName)")
//    return true
//}
//
//router[CommonCommands.name.description] = { context in
//    let text = "My name is MithforTelegramBot"
//    context.respondAsync(text)
//    return true
//}
//
//router[CommonCommands.letStart.description] = { context in
//    
//    if #available(macOS 10.15, *) {
//        Task {
//            let promptText = "You are Latoken assistant You will help me to know about latoken as much as possible"
//            //    context.respondAsync(text)
//            
//            let aiMessage: Message =  .init(id: UUID(),
//                                            role: .user,
//                                            content: promptText,
//                                            createAt: Date())
//            let text = await aiService.sendMessage(messages: [aiMessage])
//        }
//    } else {
//        // Fallback on earlier versions
//    }
//    return true
//}
//
//router[CommonCommands.help.description] = { context in
//    
//    for cmd in CommonCommands.allCases {
//        let text = cmd.description
//        context.respondAsync(text)
//    }
//    return true
//}
//
//router[CommonCommands.chatGPT.description] = { context in
//    
//    if #available(macOS 10.15, *) {
//        Task {
//            context.respondAsync("Processing...")
//            let messageText = context.args.scanRestOfString()
//            let aiMessage: Message =  .init(id: UUID(),
//                                           role: .user,
//                                           content: messageText,
//                                           createAt: Date())
//            let text = await aiService.sendMessage(messages: [aiMessage])
//            context.respondAsync(text?.choices.first?.message.content ?? "empty answer")
//            return true
//        }
//    } else {
//        // Fallback on earlier versions
//    }
//    return true
//}
//while let update = bot.nextUpdateSync() {
//    print(update)
//    try router.process(update: update)
//}

