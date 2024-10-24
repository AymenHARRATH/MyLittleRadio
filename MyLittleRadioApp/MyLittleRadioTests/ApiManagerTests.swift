//
//  ApiManagerTests.swift
//  MyLittleRadio
//
//  Created by HARRATH Aymen on 24/10/2024.
//

import XCTest
@testable import MyLittleRadio

final class ApiManagerTests: XCTestCase {
    
    var mockSession: MockURLSession!
    var mockDecoder: MockJSONDecoder!
    var sut: ApiManager!

    override func setUp() {
        super.setUp()
        mockSession = MockURLSession()
        mockDecoder = MockJSONDecoder()
        sut = ApiManager(session: mockSession, decoder: mockDecoder)
    }
    
    override func tearDown() {
        mockSession = nil
        mockDecoder = nil
        sut = nil
        super.tearDown()
    }

    
    func test_fech_station_should_retur_array_of_stations_when_succeeded() async {
        //Given
        let station = Station.sample
        let stationsList = StationsList(stations: [station])
        mockDecoder.decodedObject = stationsList
        
        //When
        let stations = try! await sut.fetchStations()
        
        //Then
        XCTAssertEqual(stations.count, 1)
        XCTAssertEqual(stations.first?.title, Station.sample.title)
    }
    
    func test_fech_stations_should_throw_error_when_failed() async {
        // Given
        mockSession.error = URLError(.badServerResponse)
        
        //When + Then
        do {
            _ = try await sut.fetchStations()
            XCTFail("Expected fetchStations error to be thrown")
        } catch {
            XCTAssertTrue(error is URLError)
        }
    }
    
    func test_fech_stations_should_throw_error_when_decoding_failed() async {
        // Given
        mockSession.data = Data("Fake JSON".utf8)

        //When + Then
        do {
            _ = try await sut.fetchStations()
            XCTFail("Expected decoding error to be thrown")
        } catch {
            XCTAssertTrue(error is DecodingError, "Invalid json data \(error).")
        }
    }
}

final class MockURLSession: URLSessionProtocol {
    var data: Data?
    var error: Error?

    func getData(from url: URL) async throws -> (Data, URLResponse) {
        if let error = error {
            throw error
        }
        return (data ?? Data(), URLResponse())
    }
}

final class MockJSONDecoder: JSONDecoderProtocol {
    var decodedObject: Any?
    var error: Error?

    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        if let error = error {
            throw error
        }
        guard let decoded = decodedObject as? T else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "No object available for decoding"))
        }
        return decoded
    }
}

