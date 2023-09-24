//
//  ReachabilityChecker.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 17.01.2023.
//  Copyright © 2023 Vyacheslav Khorkov. All rights reserved.
//

import Foundation

enum ReachabilityCheckerError: LocalizedError {
    case urlUnreachable(URL)

    var errorDescription: String? {
        switch self {
        case .urlUnreachable(let url):
            return "\(url) unreachable."
        }
    }
}

// MARK: - Implementation

final class ReachabilityChecker {
    private typealias Error = ReachabilityCheckerError

    func checkIfURLIsReachable(_ url: URL) async throws -> Bool {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "HEAD"
        let (_, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = (response as? HTTPURLResponse) else { throw Error.urlUnreachable(url) }
        return httpResponse.statusCode == 200
    }
}
