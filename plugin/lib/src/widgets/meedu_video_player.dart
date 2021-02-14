import 'package:flutter/material.dart';
import 'package:flutter_meedu/rx.dart';
import 'package:meedu_player/meedu_player.dart';
import 'package:meedu_player/src/controller.dart';
import 'package:meedu_player/src/helpers/responsive.dart';
import 'package:meedu_player/src/widgets/closed_caption_view.dart';
import 'package:meedu_player/src/widgets/styles/primary/primary_player_controls.dart';
import 'package:meedu_player/src/widgets/styles/secondary/secondary_player_controls.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class MeeduVideoPlayer extends StatefulWidget {
  final MeeduPlayerController controller;

  final Widget Function(
    BuildContext context,
    MeeduPlayerController controller,
    Responsive responsive,
  ) header;

  final Widget Function(
    BuildContext context,
    MeeduPlayerController controller,
    Responsive responsive,
  ) bottomRight;

  final CustomIcons Function(
    Responsive responsive,
  ) customIcons;

  MeeduVideoPlayer({
    Key key,
    @required this.controller,
    this.header,
    this.bottomRight,
    this.customIcons,
  })  : assert(controller != null),
        super(key: key);

  @override
  _MeeduVideoPlayerState createState() => _MeeduVideoPlayerState();
}

class _MeeduVideoPlayerState extends State<MeeduVideoPlayer> {
  Widget _getView(MeeduPlayerController _) {
    // if (_.dataStatus.none) return Container();
    // if (_.dataStatus.loading) {
    //   return Center(
    //     child: _.loadingWidget,
    //   );
    // }
    if (_.dataStatus.error) {
      return Center(
        child: Text(
          _.errorText ?? 'Error',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return LayoutBuilder(
      builder: (ctx, constraints) {
        final responsive = Responsive(
          constraints.maxWidth,
          constraints.maxHeight,
        );

        if (widget.customIcons != null) {
          _.customIcons = this.widget.customIcons(responsive);
        }

        if (widget.header != null) {
          _.header = this.widget.header(context, _, responsive);
        }

        if (widget.bottomRight != null) {
          _.bottomRight = this.widget.bottomRight(context, _, responsive);
        }
        return Stack(
          alignment: Alignment.center,
          children: [
            RxBuilder(
                observables: [_.videoFit],
                builder: (__) {
                  return SizedBox.expand(
                    child: VlcPlayer(
                      controller: _.videoPlayerController,
                      aspectRatio: 16 / 9,
                    ),
                    // child: FittedBox(
                    //   fit: widget.controller.videoFit.value,
                    //   child: SizedBox(
                    //     width: _.videoPlayerController.value.size.width ?? 0,
                    //     height: _.videoPlayerController.value.size.height ?? 0,
                    //     child: VlcPlayer(
                    //       controller: _.videoPlayerController,
                    //       aspectRatio: 16 / 9,
                    //     ),
                    //   ),
                    // ),
                  );
                }),
            ClosedCaptionView(responsive: responsive),
            if (_.controlsEnabled && _.controlsStyle == ControlsStyle.primary)
              PrimaryVideoPlayerControls(
                responsive: responsive,
              ),
            if (_.controlsEnabled && _.controlsStyle == ControlsStyle.secondary)
              SecondaryVideoPlayerControls(
                responsive: responsive,
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MeeduPlayerProvider(
      child: Container(
        color: Colors.black,
        width: 0.0,
        height: 0.0,
        child: RxBuilder(
          observables: [
            widget.controller.showControls,
            widget.controller.dataStatus.status
          ],
          builder: (__) => _getView(widget.controller),
        ),
      ),
      controller: widget.controller,
    );
  }
}

class MeeduPlayerProvider extends InheritedWidget {
  final MeeduPlayerController controller;

  MeeduPlayerProvider({
    Key key,
    @required Widget child,
    @required this.controller,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}
