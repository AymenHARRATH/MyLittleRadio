// Copyright © Radio France. All rights reserved.

import Foundation

struct Station: Codable, Equatable, Identifiable {
    
    struct Analytics: Codable {
        let value: String
        let stationAudienceId: Int
    }

    struct Colors: Codable {
        let primary: String
    }

    struct Assets: Codable {
        let squareImageUrl: String
    }

    let id: String
    let brandId: String
    let title: String
    let hasTimeshift: Bool
    let shortTitle: String
    let type: String
    let streamUrl: String
    let analytics: Analytics
    let liveRule: String
    let colors: Colors
    let assets: Assets?
    let isMusical: Bool
    
    static func == (lhs: Station, rhs: Station) -> Bool {
        lhs.id == rhs.id
    }
}

extension Station {
    static var sample: Station {
        Station(
            id: "7",
            brandId: "FIP",
            title: "FIP",
            hasTimeshift: false,
            shortTitle: "Fip",
            type: "on_air",
            streamUrl: "https://icecast.radiofrance.fr/fip-midfi.mp3",
            analytics: Analytics(value: "fip", stationAudienceId: 7),
            liveRule: "apprf_fip_player",
            colors: Colors(primary: "#e2007a"),
            assets: Assets(squareImageUrl: "https://www.radiofrance.fr/s3/cruiser-production/2022/05/a174aea6-c3f3-4a48-a42c-ebc034f62c10/1000x1000_squareimage_fip_v2.jpg"),
            isMusical: true
        )
    }
}
