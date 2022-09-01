import SwiftUI

struct NetworkState: View {
    @EnvironmentObject<NetworkStateModel> private var model

    var body: some View {
        Buffering(state: model.fullStateText)
            .opacity(model.osdVisible ? 1 : 0)
    }
}

struct NetworkState_Previews: PreviewProvider {
    static var previews: some View {
        let networkState = NetworkStateModel()
        networkState.bufferingState = 30

        return NetworkState()
            .environmentObject(networkState)
            .environmentObject(PlayerModel())
    }
}
