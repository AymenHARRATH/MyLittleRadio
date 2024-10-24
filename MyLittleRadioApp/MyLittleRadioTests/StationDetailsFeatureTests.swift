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
        
        let store = TestStore(initialState: StationDetailsFeature.State(station: Station.sample, mode: .notPlaying)) {
            StationDetailsFeature()
        } withDependencies: {
            $0.player.play = { @Sendable _ in }
            $0.player.playerStateObserver = {
                playerStateStream.continuation.yield(.init(status: .playing))
                playerStateStream.continuation.finish()
                return playerStateStream.stream
              }
        }
        //When
        await store.send(.playPauseButtonTapped)
        //Then
        await store.receive(\.updatePlayerState) {
            $0.mode = .playing
        }
    }

    @Test
    func play_action_should_set_state_to_loading_when_player_is_loading() async throws {
        //Given
        let playerStateStream = AsyncStream.makeStream(of: PlayerState.self)
        let state = StationDetailsFeature.State(station: Station.sample, mode: .notPlaying)
        let store = TestStore(initialState: state) {
            StationDetailsFeature()
        } withDependencies: {
            $0.player.play = { @Sendable _ in }
            $0.player.playerStateObserver = {
                playerStateStream.continuation.yield(.init(status: .loading))
                playerStateStream.continuation.finish()
                return playerStateStream.stream
              }
        }
        //When
        await store.send(.playPauseButtonTapped)
        //Then
        await store.receive(\.updatePlayerState) {
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
            $0.player.stop =  {
                playerStateStream.continuation.yield(.init(status: .stopped))
              }
        }
        //when
        await store.send(.playPauseButtonTapped)
        //Then
        await store.receive(\.updatePlayerState) {
            $0.mode = .notPlaying
        }
    }
}
