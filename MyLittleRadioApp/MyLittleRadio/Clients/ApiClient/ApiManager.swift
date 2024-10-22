// Copyright © Radio France. All rights reserved.

import Foundation

final class ApiManager {

    func fetchStations() async throws -> [Station] {
        do {
            guard let url =  URL(string: "http://localhost:3000/stations") else { return [] }
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedData = try JSONDecoder().decode([String: [Station]].self, from: data)
            return decodedData["stations"] ?? []
        }
        catch {
            throw(error)
        }
    }
}
