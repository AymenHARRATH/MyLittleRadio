//
//  StationDetailsFeatureTests.swift
//  MyLittleRadio
//
//  Created by HARRATH Aymen on 23/10/2024.
//


import ComposableArchitecture
import Foundation
import Testing


@testable import MyLittleRadio


@MainActor
struct StationDetailsFeatureTests {

    @Test
    func play_action_should_set_state_to_playing_when_player_is_playing() async throws {
        //Given
        let playerStateStream = AsyncStream.makeStream(of: PlayerState.self)
        
        let store = TestStore(initialState: StationDetailsFeature.State(station: Station.sample)) {
            StationDetailsFeature()
        } withDependencies: {
            $0.player.play =  { @Sendable _ in
                playerStateStream.continuation.yield(.playing)
                playerStateStream.continuation.finish()
                return playerStateStream.stream
              }
        }
        //When
        await store.send(.playPauseButtonTapped)
        //Then
        await store.receive(\.playerClient) {
            $0.mode = .playing
        }
    }

    @Test
    func play_action_should_set_state_to_loading_when_player_is_loading() async throws {
        //Given
        let playerStateStream = AsyncStream.makeStream(of: PlayerState.self)
        let state = StationDetailsFeature.State(station: Station.sample)
        let store = TestStore(initialState: state) {
            StationDetailsFeature()
        } withDependencies: {
            $0.player.play =  { @Sendable _ in
                playerStateStream.continuation.yield(.loading)
                playerStateStream.continuation.finish()
                return playerStateStream.stream
              }
        }
        //When
        await store.send(.playPauseButtonTapped)
        //Then
        await store.receive(\.playerClient) {
            $0.mode = .loading
        }
    }
    
    @Test
    func play_action_should_set_state_to_stopped_when_player_is_stopped() async throws {
        //Given
        let playerStateStream = AsyncStream.makeStream(of: PlayerState.self)
        let state = StationDetailsFeature.State(station: Station.sample, mode: .playing)
        let store = TestStore(initialState: state) {
            StationDetailsFeature()
        } withDependencies: {
            $0.player.pause =  {
                playerStateStream.continuation.yield(.stopped)
              }
        }
        //when
        await store.send(.playPauseButtonTapped)
        //Then
        await store.receive(\.playerClient) {
            $0.mode = .notPlaying
        }
    }
}
