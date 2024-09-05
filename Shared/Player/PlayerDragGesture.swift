import Defaults
import SwiftUI

extension VideoPlayerView {
    var playerDragGesture: some Gesture {
        DragGesture(minimumDistance: 30, coordinateSpace: .global)
        #if os(iOS)
            .updating($dragGestureOffset) { value, state, _ in
                guard isVerticalDrag else { return }
                var translation = value.translation
                translation.height = max(-translation.height, translation.height)
                state = translation
            }
        #endif
            .updating($dragGestureState) { _, state, _ in
                state = true
            }
            .onChanged { value in
                guard player.presentingPlayer,
                      !controlsOverlayModel.presenting,
                      dragGestureState,
                      !disableToggleGesture else { return }

                if player.controls.presentingControls, !player.musicMode {
                    player.controls.presentingControls = false
                }

                if player.musicMode {
                    player.backend.stopControlsUpdates()
                }

                let verticalDrag = value.translation.height
                let horizontalDrag = value.translation.width

                #if os(iOS)
                    if viewDragOffset > 0, !isVerticalDrag {
                        isVerticalDrag = true
                    }
                #endif

                if !isVerticalDrag,
                   horizontalPlayerGestureEnabled,
                   abs(horizontalDrag) > seekGestureSensitivity,
                   !isHorizontalDrag,
                   player.activeBackend == .mpv || !avPlayerUsesSystemControls
                {
                    isHorizontalDrag = true
                    player.seek.onSeekGestureStart()
                    viewDragOffset = 0
                }

                if horizontalPlayerGestureEnabled, isHorizontalDrag {
                    player.seek.updateCurrentTime {
                        let time = player.backend.playerItemDuration?.seconds ?? 0
                        if player.seek.gestureStart.isNil {
                            player.seek.gestureStart = time
                        }
                        let timeSeek = (time / player.playerSize.width) * horizontalDrag * seekGestureSpeed

                        player.seek.gestureSeek = timeSeek
                    }
                    return
                }

                // Toggle fullscreen on upward drag only when not disabled
                if verticalDrag < -50 {
                    player.toggleFullScreenAction()
                    disableGestureTemporarily()
                    return
                }

                // Ignore downward swipes when in fullscreen
                guard verticalDrag > 0 && !player.playingFullScreen else {
                    return
                }
                viewDragOffset = verticalDrag
            }
            .onEnded { _ in
                onPlayerDragGestureEnded()
            }
    }

    func onPlayerDragGestureEnded() {
        if horizontalPlayerGestureEnabled, isHorizontalDrag {
            isHorizontalDrag = false
            player.seek.onSeekGestureEnd()
        }

        isVerticalDrag = false

        guard player.presentingPlayer,
              !controlsOverlayModel.presenting else { return }

        if viewDragOffset > 100 {
            withAnimation(Constants.overlayAnimation) {
                viewDragOffset = Self.hiddenOffset
            }
        } else {
            withAnimation(Constants.overlayAnimation) {
                viewDragOffset = 0
            }
            player.backend.setNeedsDrawing(true)
            player.show()

            if player.musicMode {
                player.backend.startControlsUpdates()
            }
        }
    }

    // Function to temporarily disable the toggle gesture after a fullscreen change
    private func disableGestureTemporarily() {
        disableToggleGesture = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            disableToggleGesture = false
        }
    }
}
