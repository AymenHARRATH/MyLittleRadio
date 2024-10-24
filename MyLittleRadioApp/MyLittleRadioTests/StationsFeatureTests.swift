//
//  StationsFeatureTests.swift
//  MyLittleRadio
//
//  Created by HARRATH Aymen on 23/10/2024.
//

import ComposableArchitecture
import Testing


@testable import MyLittleRadio


@MainActor
struct StationsFeatureTests {
    
    @Test
    func fech_stations_should_update_state_with_stations_array_when_succeeded() async {
        //Given
        let store = TestStore(initialState: StationsFeature.State()) {
            StationsFeature()
        } withDependencies: {
            $0.apiClient.fetchStations = { [Station.sample] }
        }
        
        //When
        await store.send(.fetchStations)
        
        //Then
        await store.receive(\.setStations) {
            $0.stations = [Station.sample]
        }
    }
    
    
    @Test
    func fech_stations_should_set_state_alert_when_failed() async {
        //Given
        enum TestError: Error {
            case someError
        }
        let store = TestStore(initialState: StationsFeature.State()) {
            StationsFeature()
        } withDependencies: {
            $0.apiClient.fetchStations = { throw TestError.someError }
        }
        
        //When
        await store.send(.fetchStations)
        
        //Then
        await store.receive(\.fetchStationsFailure) {
            $0.alert = .fechStationsFailureState()
        }
    }
    
    
    @Test
    func alert_retry_action_should_retry_fech_stations_request() async {
        //Given
        let store = TestStore(initialState: StationsFeature.State(alert: .fechStationsFailureState())) {
            StationsFeature()
        } withDependencies: {
            $0.apiClient.fetchStations = { [Station.sample] }
        }

        //When
        await store.send(.alert(.presented(.retryRequest))) {
            $0.alert = nil
        }
        
        //Then
        await store.receive(\.fetchStations)
        await store.receive(\.setStations) {
            $0.stations = [Station.sample]
        }
    }
}

