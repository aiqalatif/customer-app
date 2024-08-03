import 'dart:ui';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Screen/ProductPreview/Widget/productPreviewWidget.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:video_player/video_player.dart';
import '../../Helper/Constant.dart';
import '../../Helper/String.dart';
import '../VimeoPlayer/vimeoplayer.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'Widget/controlOverlay.dart';

class ProductPreview extends StatefulWidget {
  final int? pos, secPos, index;
  final bool? list, from;
  final String? id, video, videoType;
  final List<String?>? imgList;

  const ProductPreview({
    Key? key,
    this.pos,
    this.secPos,
    this.index,
    this.list,
    this.id,
    this.imgList,
    this.video,
    this.videoType,
    this.from,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => StatePreview();
}

class StatePreview extends State<ProductPreview> {
  int? curPos;
  YoutubePlayerController? _controller;
  VideoPlayerController? _videoController;
  PageController? _pageController;

  @override
  void initState() {
    super.initState();

    if (widget.from! && widget.videoType == 'youtube') {
      _controller = YoutubePlayerController(
        initialVideoId: YoutubePlayer.convertUrlToId(widget.video!)!,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          forceHD: false,
          loop: false,
          disableDragSeek: true,
        ),
      );
    } else if (widget.from! &&
        (widget.videoType == 'self_hosted' ||
            widget.videoType == 'Self Hosted') &&
        widget.video != '') {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.video ?? ''),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
        ),
      );

      _videoController!.addListener(
        () {
          setState(
            () {},
          );
        },
      );

      _videoController!.setLooping(false);
      _videoController!.initialize();
    }

    curPos = widget.pos;
    _pageController = PageController(initialPage: widget.pos!);
  }

  @override
  void dispose() {
    super.dispose();
    if (_controller != null) _controller!.dispose();
    if (_videoController != null) _videoController!.dispose();
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    if (_controller != null) _controller!.pause();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Hero(
        tag: widget.list!
            ? '$heroTagUniqueString${widget.id}'
            : '$heroTagUniqueString${widget.imgList}${widget.secPos}${widget.index}',
        child: Stack(
          children: <Widget>[
            widget.video == ''
                ? PhotoViewGallery.builder(
                    scrollPhysics: const BouncingScrollPhysics(),
                    builder: (BuildContext context, int index) {
                      return PhotoViewGalleryPageOptions(
                          initialScale: PhotoViewComputedScale.contained,
                          minScale: PhotoViewComputedScale.contained * 0.9,
                          imageProvider: NetworkImage(widget.imgList![index]!));
                    },
                    itemCount: widget.imgList!.length,
                    loadingBuilder: (context, event) => Center(
                      child: SizedBox(
                        width: 20.0,
                        height: 20.0,
                        child: CircularProgressIndicator(
                          value: event == null
                              ? 0
                              : event.cumulativeBytesLoaded /
                                  event.expectedTotalBytes!,
                        ),
                      ),
                    ),
                    backgroundDecoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.white),
                    pageController: _pageController,
                    onPageChanged: (index) {
                      if (mounted) {
                        setState(() {
                          curPos = index;
                        });
                      }
                    },
                  )
                : PageView.builder(
                    itemCount: widget.imgList!.length,
                    controller: _pageController,
                    onPageChanged: (index) {
                      if (mounted) {
                        setState(
                          () {
                            curPos = index;
                          },
                        );
                        if ((widget.videoType == 'self_hosted' ||
                                widget.videoType == 'Self Hosted') &&
                            index != 1) {
                          if (_videoController?.value.isPlaying ?? false) {
                            _videoController?.pause();
                          }
                        }
                      }
                    },
                    itemBuilder: (BuildContext context, int index) {
                      if (index == 1 &&
                          widget.from! &&
                          widget.videoType != null &&
                          widget.video != '') {
                        if (widget.videoType == 'youtube') {
                          _controller!.reset();
                          return SafeArea(
                            child: Center(
                              child: SizedBox(
                                width: double.maxFinite,
                                height: MediaQuery.of(context).size.height / 3,
                                child: YoutubePlayer(
                                  controller: _controller!,
                                  showVideoProgressIndicator: true,
                                  progressIndicatorColor:
                                      Theme.of(context).colorScheme.fontColor,
                                  liveUIColor: colors.primary,
                                ),
                              ),
                            ),
                          );
                        } else if (widget.videoType == 'vimeo') {
                          List<String> id =
                              widget.video!.split('https://vimeo.com/');
                          return SafeArea(
                            child: Center(
                              child: SizedBox(
                                width: double.maxFinite,
                                height: MediaQuery.of(context).size.height / 3,
                                child: VimeoPlayer(
                                  id: id[1],
                                  autoPlay: true,
                                  looping: false,
                                ),
                              ),
                            ),
                          );
                        } else {
                          return _videoController!.value.isInitialized
                              ? SafeArea(
                                  child: Center(
                                  child: SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height / 3,
                                    width: _videoController!.value.size.width,
                                    child: Stack(
                                      alignment: Alignment.bottomCenter,
                                      children: <Widget>[
                                        VideoPlayer(
                                          _videoController!,
                                        ),
                                        ControlsOverlay(
                                          controller: _videoController,
                                        ),
                                        VideoProgressIndicator(
                                          _videoController!,
                                          allowScrubbing: true,
                                        ),
                                      ],
                                    ),
                                  ),
                                ))
                              : const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color?>(
                                      colors.primary,
                                    ),
                                  ),
                                );
                        }
                      }

                      return PhotoView(
                        backgroundDecoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.white),

                        initialScale: PhotoViewComputedScale.contained,
                        minScale: PhotoViewComputedScale.contained * 0.9,
                        gaplessPlayback: false,
                        // maxScale: PhotoViewComputedScale.contained,
                        customSize: MediaQuery.of(context).size,
                        imageProvider: NetworkImage(
                          widget.imgList![index]!,
                        ),
                      );
                    },
                  ),
            //
            //Back button
            const IOSRundedButton(),
            curPos != 0
                ? Positioned.directional(
                    start: 10,
                    top: MediaQuery.of(context).size.height * 0.45,
                    textDirection: Directionality.of(context),
                    child: ClipRRect(
                      clipBehavior: Clip.hardEdge,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 10.0,
                          sigmaY: 10.0,
                        ),
                        child: Container(
                          height: 60,
                          width: 40,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(circularBorderRadius7),
                            color: Colors.white.withOpacity(0.5),
                          ),
                          child: Center(
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios_outlined),
                              onPressed: () {
                                setState(
                                  () {
                                    _pageController!.animateToPage(
                                      (curPos! - 1),
                                      duration:
                                          const Duration(milliseconds: 200),
                                      curve: Curves.linear,
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
            curPos != (widget.imgList!.length - 1)
                ? Positioned.directional(
                    textDirection: Directionality.of(context),
                    end: 10,
                    top: MediaQuery.of(context).size.height * 0.45,
                    child: ClipRRect(
                      clipBehavior: Clip.hardEdge,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 10.0,
                          sigmaY: 10.0,
                        ),
                        child: Container(
                          height: 60,
                          width: 40,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(circularBorderRadius7),
                            color: Colors.white.withOpacity(0.5),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_forward_ios_outlined),
                            onPressed: () {
                              setState(
                                () {
                                  _pageController!.animateToPage(
                                    (curPos! + 1),
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.linear,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
            Positioned.directional(
              textDirection: Directionality.of(context),
              bottom: 10.0,
              start: 25.0,
              end: 25.0,
              child: SelectedPhoto(
                numberOfDots: widget.imgList!.length,
                photoIndex: curPos,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SelectedPhoto extends StatelessWidget {
  final int? numberOfDots;
  final int? photoIndex;

  const SelectedPhoto({
    Key? key,
    this.numberOfDots,
    this.photoIndex,
  }) : super(key: key);

  Widget _inactivePhoto() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 3.0, end: 3.0),
      child: Container(
        height: 8.0,
        width: 8.0,
        decoration: BoxDecoration(
          color: colors.primary.withOpacity(0.4),
          borderRadius: BorderRadius.circular(circularBorderRadius4),
        ),
      ),
    );
  }

  Widget _activePhoto() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 5.0, end: 5.0),
      child: Container(
        height: 10.0,
        width: 10.0,
        decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: BorderRadius.circular(circularBorderRadius5),
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              spreadRadius: 0.0,
              blurRadius: 2.0,
            )
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDots() {
    List<Widget> dots = [];
    for (int i = 0; i < numberOfDots!; i++) {
      dots.add(
        i == photoIndex ? _activePhoto() : _inactivePhoto(),
      );
    }
    return dots;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _buildDots(),
      ),
    );
  }
}
