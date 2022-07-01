import Defaults
import Foundation
import SwiftUI

struct SettingsView: View {
    #if os(macOS)
        private enum Tabs: Hashable {
            case browsing, player, history, sponsorBlock, locations, advanced, help
        }

        @State private var selection = Tabs.browsing
    #endif

    @Environment(\.colorScheme) private var colorScheme

    #if os(iOS)
        @Environment(\.presentationMode) private var presentationMode
    #endif

    @EnvironmentObject<AccountsModel> private var accounts
    @EnvironmentObject<NavigationModel> private var navigation
    @EnvironmentObject<SettingsModel> private var model

    @Default(.instances) private var instances

    var body: some View {
        settings
            .environmentObject(model)
            .alert(isPresented: $model.presentingAlert) { model.alert }
    }

    var settings: some View {
        #if os(macOS)
            TabView(selection: $selection) {
                Form {
                    BrowsingSettings()
                }
                .tabItem {
                    Label("Browsing", systemImage: "list.and.film")
                }
                .tag(Tabs.browsing)

                Form {
                    PlayerSettings()
                }
                .tabItem {
                    Label("Player", systemImage: "play.rectangle")
                }
                .tag(Tabs.player)

                Form {
                    HistorySettings()
                }
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
                .tag(Tabs.history)

                Form {
                    SponsorBlockSettings()
                }
                .tabItem {
                    Label("SponsorBlock", systemImage: "dollarsign.circle")
                }
                .tag(Tabs.sponsorBlock)

                Form {
                    LocationsSettings()
                }
                .tabItem {
                    Label("Locations", systemImage: "globe")
                }
                .tag(Tabs.locations)

                Group {
                    AdvancedSettings()
                }
                .tabItem {
                    Label("Advanced", systemImage: "wrench.and.screwdriver")
                }
                .tag(Tabs.advanced)

                Form {
                    Help()
                }
                .tabItem {
                    Label("Help", systemImage: "questionmark.circle")
                }
                .tag(Tabs.help)
            }
            .padding(20)
            .frame(width: 480, height: windowHeight)
        #else
            Group {
                #if os(tvOS)
                    settingsList
                #else
                    NavigationView {
                        settingsList
                    }
                #endif
            }

        #endif
    }

    #if !os(macOS)
        var settingsList: some View {
            List {
                #if os(tvOS)
                    AccountSelectionView()
                    Divider()
                #endif

                Section {
                    #if os(tvOS)
                        NavigationLink {
                            EditFavorites()
                        } label: {
                            Label("Favorites", systemImage: "heart.fill")
                        }
                    #endif

                    NavigationLink {
                        BrowsingSettings()
                    } label: {
                        Label("Browsing", systemImage: "list.and.film")
                    }

                    NavigationLink {
                        PlayerSettings()
                    } label: {
                        Label("Player", systemImage: "play.rectangle")
                    }

                    NavigationLink {
                        HistorySettings()
                    } label: {
                        Label("History", systemImage: "clock.arrow.circlepath")
                    }

                    NavigationLink {
                        SponsorBlockSettings()
                    } label: {
                        Label("SponsorBlock", systemImage: "dollarsign.circle")
                    }

                    NavigationLink {
                        LocationsSettings()
                    } label: {
                        Label("Locations", systemImage: "globe")
                    }

                    NavigationLink {
                        AdvancedSettings()
                    } label: {
                        Label("Advanced", systemImage: "wrench.and.screwdriver")
                    }
                }

                Section(footer: versionString) {
                    NavigationLink {
                        Help()
                    } label: {
                        Label("Help", systemImage: "questionmark.circle")
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    #if !os(tvOS)
                        Button("Done") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .keyboardShortcut(.cancelAction)
                    #endif
                }
            }
            .frame(maxWidth: 1000)
            #if os(iOS)
                .listStyle(.insetGrouped)
            #endif
        }
    #endif

    #if os(macOS)
        private var windowHeight: Double {
            switch selection {
            case .browsing:
                return 390
            case .player:
                return 390
            case .history:
                return 480
            case .sponsorBlock:
                return 660
            case .locations:
                return 480
            case .advanced:
                return 300
            case .help:
                return 570
            }
        }
    #endif

    private var versionString: some View {
        Text("Yattee \(YatteeApp.version) (build \(YatteeApp.build))")
        #if os(tvOS)
            .foregroundColor(.secondary)
        #endif
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .injectFixtureEnvironmentObjects()
        #if os(macOS)
            .frame(width: 600, height: 300)
        #endif
    }
}
