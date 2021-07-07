import Defaults
import Siesta
import SwiftUI
import URLImage

struct VideoDetailsView: View {
    @Default(.showingVideoDetails) var showDetails

    @ObservedObject private var store = Store<Video>()

    var resource: Resource {
        InvidiousAPI.shared.video(Defaults[.openVideoID])
    }

    init() {
        resource.addObserver(store)
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            if let video = store.item {
                VStack(alignment: .center) {
                    ZStack(alignment: .bottom) {
                        Group {
                            if let thumbnail = video.thumbnailURL(quality: "maxres") {
                                // to replace with AsyncImage when it is fixed with lazy views
                                URLImage(thumbnail) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 1600, height: 800)
                                }
                            }
                        }
                        .frame(width: 1600, height: 800)

                        VStack(alignment: .leading) {
                            Text(video.title)
                                .font(.system(size: 40))

                            HStack {
                                NavigationLink(destination: PlayerView(id: video.id)) {
                                    HStack(spacing: 10) {
                                        Image(systemName: "play.rectangle.fill")

                                        Text("Play")
                                    }
                                }

                                openChannelButton
                            }
                        }
                        .padding(40)
                        .frame(width: 1600, alignment: .leading)
                        .background(.thinMaterial)
                    }
                    .mask(RoundedRectangle(cornerRadius: 20))
                    VStack {
                        Text(video.description).lineLimit(nil).focusable()
                    }.frame(width: 1600, alignment: .leading)
                    Button("A") {}
                }
            }
        }
        .onAppear {
            resource.loadIfNeeded()
        }
        .edgesIgnoringSafeArea(.all)
    }

    var openChannelButton: some View {
        let channel = Channel.from(video: store.item!)

        return Button("Open \(channel.name) channel") {
            Defaults[.openChannel] = channel
            Defaults[.tabSelection] = .channel
            showDetails = false
        }
    }
}
