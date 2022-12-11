import Cache
import Foundation
import Logging
import SwiftyJSON

struct PlaylistsCacheModel {
    static let shared = PlaylistsCacheModel()
    static let limit = 30
    let logger = Logger(label: "stream.yattee.cache.playlists")

    static let diskConfig = DiskConfig(name: "playlists")
    static let memoryConfig = MemoryConfig()

    let storage = try! Storage<String, JSON>(
        diskConfig: Self.diskConfig,
        memoryConfig: Self.memoryConfig,
        transformer: CacheModel.jsonTransformer
    )

    func storePlaylist(account: Account, playlists: [Playlist]) {
        let date = CacheModel.shared.iso8601DateFormatter.string(from: Date())
        logger.info("caching \(playlistCacheKey(account)) -- \(date)")
        let feedTimeObject: JSON = ["date": date]
        let playlistsObject: JSON = ["playlists": playlists.map { $0.json.object }]
        try? storage.setObject(feedTimeObject, forKey: playlistTimeCacheKey(account))
        try? storage.setObject(playlistsObject, forKey: playlistCacheKey(account))
    }

    func retrievePlaylists(account: Account) -> [Playlist] {
        logger.info("retrieving cache for \(playlistCacheKey(account))")

        if let json = try? storage.object(forKey: playlistCacheKey(account)),
           let playlists = json.dictionaryValue["playlists"]
        {
            return playlists.arrayValue.map { Playlist.from($0) }
        }

        return []
    }

    func getPlaylistsTime(account: Account) -> Date? {
        if let json = try? storage.object(forKey: playlistTimeCacheKey(account)),
           let string = json.dictionaryValue["date"]?.string,
           let date = CacheModel.shared.iso8601DateFormatter.date(from: string)
        {
            return date
        }

        return nil
    }

    func getFormattedPlaylistTime(account: Account) -> String {
        if let time = getPlaylistsTime(account: account) {
            let isSameDay = Calendar(identifier: .iso8601).isDate(time, inSameDayAs: Date())
            let formatter = isSameDay ? CacheModel.shared.dateFormatterForTimeOnly : CacheModel.shared.dateFormatter
            return formatter.string(from: time)
        }

        return ""
    }

    func clear() {
        try? storage.removeAll()
    }

    private func playlistCacheKey(_ account: Account) -> String {
        "playlists-\(account.id)"
    }

    private func playlistTimeCacheKey(_ account: Account) -> String {
        "\(playlistCacheKey(account))-time"
    }
}
