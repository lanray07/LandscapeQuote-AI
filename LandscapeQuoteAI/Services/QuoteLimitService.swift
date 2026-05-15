import Foundation

enum QuoteLimitService {
    static let freeMonthlyLimit = 3

    static func quotesCreatedThisMonth(in projects: [QuoteProject], calendar: Calendar = .current, now: Date = .now) -> Int {
        projects.filter { project in
            calendar.isDate(project.createdDate, equalTo: now, toGranularity: .month) &&
            calendar.isDate(project.createdDate, equalTo: now, toGranularity: .year)
        }.count
    }

    static func canCreateQuote(projects: [QuoteProject], isPro: Bool) -> Bool {
        isPro || quotesCreatedThisMonth(in: projects) < freeMonthlyLimit
    }
}
