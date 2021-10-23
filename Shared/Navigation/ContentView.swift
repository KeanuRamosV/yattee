import Defaults
import SDWebImage
import SDWebImagePINPlugin
import SDWebImageWebPCoder
import Siesta
import SwiftUI

struct ContentView: View {
    @StateObject private var accounts = AccountsModel()
    @StateObject private var instances = InstancesModel()
    @StateObject private var navigation = NavigationModel()
    @StateObject private var player = PlayerModel()
    @StateObject private var playlists = PlaylistsModel()
    @StateObject private var recents = RecentsModel()
    @StateObject private var search = SearchModel()
    @StateObject private var subscriptions = SubscriptionsModel()

    #if os(iOS)
        @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif

    var body: some View {
        Section {
            #if os(iOS)
                if horizontalSizeClass == .compact {
                    AppTabNavigation()
                } else {
                    AppSidebarNavigation()
                }
            #elseif os(macOS)
                AppSidebarNavigation()
            #elseif os(tvOS)
                TVNavigationView()
            #endif
        }
        .onAppear(perform: configure)
        .environmentObject(accounts)
        .environmentObject(instances)
        .environmentObject(navigation)
        .environmentObject(player)
        .environmentObject(playlists)
        .environmentObject(recents)
        .environmentObject(search)
        .environmentObject(subscriptions)
        .sheet(isPresented: $navigation.presentingWelcomeScreen) {
            WelcomeScreen()
                .environmentObject(accounts)
                .environmentObject(navigation)
        }
        #if os(iOS)
            .fullScreenCover(isPresented: $player.presentingPlayer) {
                VideoPlayerView()
                    .environmentObject(accounts)
                    .environmentObject(instances)
                    .environmentObject(navigation)
                    .environmentObject(player)
                    .environmentObject(subscriptions)
            }
        #elseif os(macOS)
            .sheet(isPresented: $player.presentingPlayer) {
                VideoPlayerView()
                    .frame(minWidth: 900, minHeight: 800)
                    .environmentObject(accounts)
                    .environmentObject(instances)
                    .environmentObject(navigation)
                    .environmentObject(player)
                    .environmentObject(subscriptions)
            }
        #endif
        #if !os(tvOS)
            .sheet(isPresented: $navigation.presentingAddToPlaylist) {
                AddToPlaylistView(video: navigation.videoToAddToPlaylist)
                    .environmentObject(playlists)
            }
            .sheet(isPresented: $navigation.presentingPlaylistForm) {
                PlaylistFormView(playlist: $navigation.editedPlaylist)
                    .environmentObject(playlists)
            }
            .sheet(isPresented: $navigation.presentingSettings, onDismiss: openWelcomeScreenIfAccountEmpty) {
                SettingsView()
                    .environmentObject(accounts)
                    .environmentObject(instances)
            }
        #endif
    }

    func configure() {
        SiestaLog.Category.enabled = .common
        SDImageCodersManager.shared.addCoder(SDImageWebPCoder.shared)
        SDWebImageManager.defaultImageCache = PINCache(name: "net.yattee.app")

        if let account = accounts.lastUsed ??
            instances.lastUsed?.anonymousAccount ??
            instances.all.first?.anonymousAccount
        {
            accounts.setCurrent(account)
        }

        if accounts.current.isNil {
            navigation.presentingWelcomeScreen = true
        }

        player.accounts = accounts
        playlists.accounts = accounts
        search.accounts = accounts
        subscriptions.accounts = accounts
    }

    func openWelcomeScreenIfAccountEmpty() {
        guard Defaults[.instances].isEmpty else {
            return
        }

        navigation.presentingWelcomeScreen = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .injectFixtureEnvironmentObjects()
    }
}
