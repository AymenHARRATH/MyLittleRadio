// Copyright © Radio France. All rights reserved.

import Foundation

final class ApiManager {
    
    private let session: URLSessionProtocol
    private let decoder: JSONDecoderProtocol

    init(session: URLSessionProtocol = URLSession.shared,
         decoder: JSONDecoderProtocol = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    func fetchStations() async throws -> [Station] {
        do {
            guard let url = APIEndpoint.stations.url else { throw URLError(.badURL) }
            let (data, _) = try await session.getData(from: url)
            let decodedData = try decoder.decode(StationsList.self, from: data)
            return decodedData.stations
        }
        catch {
            throw error
        }
    }
}

//MARK: - API Endpoints
enum APIEndpoint {
    case stations
    
    var url: URL? {
        switch self {
        case .stations:
            return URL(string: "http://localhost:3000/stations")
        }
    }
}

//MARK: - URL Session Protocol
protocol URLSessionProtocol {
    func getData(from url: URL) async throws -> (Data, URLResponse)
}
extension URLSession: URLSessionProtocol {
    func getData(from url: URL) async throws -> (Data, URLResponse) {
        return try await data(from: url)
    }
}

//MARK: - JSON Decoder Protocol
protocol JSONDecoderProtocol {
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable
}
extension JSONDecoder: JSONDecoderProtocol {}

