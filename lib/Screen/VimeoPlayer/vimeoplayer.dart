library vimeoplayer;

import 'package:eshop_multivendor/Screen/Language/languageSettings.dart';
import 'package:eshop_multivendor/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import 'quality_links.dart';
import 'dart:async';
import 'fullscreen_player.dart';
import '../../Helper/Color.dart';

class VimeoPlayer extends StatefulWidget {
  final String id;
  final bool? autoPlay;
  final bool? looping;
  final int? position;

  const VimeoPlayer({
    required this.id,
    this.autoPlay,
    this.looping,
    this.position,
    Key? key,
  }) : super(key: key);

  @override
  _VimeoPlayerState createState() => _VimeoPlayerState(
        id,
        autoPlay,
        looping,
        position,
      );
}

class _VimeoPlayerState extends State<VimeoPlayer> {
  final String _id;
  bool? autoPlay = false;
  bool? looping = false;
  bool _overlay = true;
  bool fullScreen = false;
  int? position;

  _VimeoPlayerState(this._id, this.autoPlay, this.looping, this.position);

  //Custom controller
  VideoPlayerController? _controller;
  Future<void>? initFuture;

  //Quality Class
  late QualityLinks _quality;
  late Map _qualityValues;
  var _qualityValue;

  bool _seek = false;

  double? videoHeight;
  double? videoWidth;
  late double videoMargin;

  double doubleTapRMargin = 36;
  double doubleTapRWidth = 400;
  double doubleTapRHeight = 160;
  double doubleTapLMargin = 10;
  double doubleTapLWidth = 400;
  double doubleTapLHeight = 160;

  @override
  void initState() {
    //Create class
    _quality = QualityLinks(_id);

    _quality.getQualitiesSync().then(
      (value) {
       if(value != null){
        //TODO empty check + error handling and showing error instead of play error
        _qualityValues = value;
        _qualityValue = value[value.lastKey()];
        
        if (_controller != null && _controller!.value.isPlaying) {
          _controller!.pause();
        }
        if(_qualityValue == null){
          
        }
        _controller = VideoPlayerController.networkUrl(Uri.parse(_qualityValue));
        _controller!.setLooping(looping!);
        if (autoPlay!) _controller!.play();
        initFuture = _controller!.initialize();

        setState(
          () {
            SystemChrome.setPreferredOrientations(
              [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp],
            );
          },
        );} else{
          setSnackbar(getTranslated(context, 'somethingMSg'), context);
        }
      },
    );

    SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp],
    );
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          GestureDetector(
            child: FutureBuilder(
              future: initFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  double delta = MediaQuery.of(context).size.width -
                      MediaQuery.of(context).size.height *
                          _controller!.value.aspectRatio;

                  if (MediaQuery.of(context).orientation ==
                          Orientation.portrait ||
                      delta < 0) {
                    videoHeight = MediaQuery.of(context).size.width /
                        _controller!.value.aspectRatio;
                    videoWidth = MediaQuery.of(context).size.width;
                    videoMargin = 0;
                  } else {
                    videoHeight = MediaQuery.of(context).size.height;
                    videoWidth = videoHeight! * _controller!.value.aspectRatio;
                    videoMargin =
                        (MediaQuery.of(context).size.width - videoWidth!) / 2;
                  }

                  if (_seek && _controller!.value.duration.inSeconds > 2) {
                    _controller!.seekTo(
                      Duration(seconds: position!),
                    );
                    _seek = false;
                  }

                  return Stack(
                    children: <Widget>[
                      Center(
                        child: Container(
                          height: videoHeight,
                          width: videoWidth,
                          margin: EdgeInsets.only(left: videoMargin),
                          child: VideoPlayer(_controller!),
                        ),
                      ),
                      _videoOverlay(),
                    ],
                  );
                } else {
                  return const Center(
                    heightFactor: 6,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                    ),
                  );
                }
              },
            ),
            onTap: () {
              setState(
                () {
                  _overlay = !_overlay;
                  if (_overlay) {
                    doubleTapRHeight = videoHeight! - 36;
                    doubleTapLHeight = videoHeight! - 10;
                    doubleTapRMargin = 36;
                    doubleTapLMargin = 10;
                  } else if (!_overlay) {
                    doubleTapRHeight = videoHeight! + 36;
                    doubleTapLHeight = videoHeight! + 16;
                    doubleTapRMargin = 0;
                    doubleTapLMargin = 0;
                  }
                },
              );
            },
          ),
          GestureDetector(
            //======= Перемотка назад =======//
            child: Container(
              width: doubleTapLWidth / 2 - 30,
              height: doubleTapLHeight - 46,
              margin: EdgeInsets.fromLTRB(
                0,
                10,
                doubleTapLWidth / 2 + 30,
                doubleTapLMargin + 20,
              ),
              decoration: const BoxDecoration(),
            ),
            onTap: () {
              setState(
                () {
                  _overlay = !_overlay;
                  if (_overlay) {
                    doubleTapRHeight = videoHeight! - 36;
                    doubleTapLHeight = videoHeight! - 10;
                    doubleTapRMargin = 36;
                    doubleTapLMargin = 10;
                  } else if (!_overlay) {
                    doubleTapRHeight = videoHeight! + 36;
                    doubleTapLHeight = videoHeight! + 16;
                    doubleTapRMargin = 0;
                    doubleTapLMargin = 0;
                  }
                },
              );
            },
            onDoubleTap: () {
              setState(
                () {
                  _controller!.seekTo(
                    Duration(
                      seconds: _controller!.value.position.inSeconds - 10,
                    ),
                  );
                },
              );
            },
          ),
          GestureDetector(
            child: Container(
              //======= Перемотка вперед =======//
              width: doubleTapRWidth / 2 - 45,
              height: doubleTapRHeight - 60,
              margin: EdgeInsets.fromLTRB(
                doubleTapRWidth / 2 + 45,
                doubleTapRMargin,
                0,
                doubleTapRMargin + 20,
              ),
              decoration: const BoxDecoration(
                  //color: Colors.red,
                  ),
            ),
            onTap: () {
              setState(
                () {
                  _overlay = !_overlay;
                  if (_overlay) {
                    doubleTapRHeight = videoHeight! - 36;
                    doubleTapLHeight = videoHeight! - 10;
                    doubleTapRMargin = 36;
                    doubleTapLMargin = 10;
                  } else if (!_overlay) {
                    doubleTapRHeight = videoHeight! + 36;
                    doubleTapLHeight = videoHeight! + 16;
                    doubleTapRMargin = 0;
                    doubleTapLMargin = 0;
                  }
                },
              );
            },
            onDoubleTap: () {
              setState(
                () {
                  _controller!.seekTo(
                    Duration(
                      seconds: _controller!.value.position.inSeconds + 10,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  //================================ Quality ================================//
  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        //Формирования списка качества
        final children = <Widget>[];
        _qualityValues.forEach(
          (elem, value) => (children.add(
            ListTile(
              title: Text(
                ' ${elem.toString()} fps',
                style: const TextStyle(
                  fontFamily: 'ubuntu',
                ),
              ),
              onTap: () => {
                //Обновление состояние приложения и перерисовка
                setState(
                  () {
                    _controller!.pause();
                    _qualityValue = value;
                    _controller = VideoPlayerController.networkUrl(Uri.parse(_qualityValue));
                    _controller!.setLooping(true);
                    _seek = true;
                    initFuture = _controller!.initialize();
                    _controller!.play();
                  },
                ),
              },
            ),
          )),
        );
        //Вывод элементов качество списком
        return Wrap(
          children: children,
        );
      },
    );
  }

  //================================ OVERLAY ================================//
  Widget _videoOverlay() {
    return _overlay
        ? Stack(
            children: <Widget>[
              GestureDetector(
                child: Center(
                  child: Container(
                    width: videoWidth,
                    height: videoHeight,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          Color(0x662F2C47),
                          Color(0x662F2C47),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: IconButton(
                  padding: EdgeInsets.only(
                    top: videoHeight! / 2 - 30,
                    bottom: videoHeight! / 2 - 30,
                  ),
                  icon: _controller!.value.isPlaying
                      ? const Icon(
                          Icons.pause,
                          size: 60.0,
                        )
                      : const Icon(
                          Icons.play_arrow,
                          size: 60.0,
                        ),
                  onPressed: () {
                    setState(
                      () {
                        _controller!.value.isPlaying
                            ? _controller!.pause()
                            : _controller!.play();
                      },
                    );
                  },
                ),
              ),
              Center(
                child: Container(
                  margin: EdgeInsets.only(
                    top: videoHeight! - 70,
                    left: videoWidth! + videoMargin - 50,
                  ),
                  child: IconButton(
                    alignment: AlignmentDirectional.center,
                    icon: const Icon(
                      Icons.fullscreen,
                      size: 30.0,
                    ),
                    onPressed: () async {
                      setState(
                        () {
                          _controller!.pause();
                        },
                      );

                      position = await Navigator.push(
                        context,
                        PageRouteBuilder(
                          opaque: false,
                          pageBuilder: (BuildContext context, _, __) =>
                              FullscreenPlayer(
                            id: _id,
                            autoPlay: true,
                            controller: _controller,
                            position: _controller!.value.position.inSeconds,
                            initFuture: initFuture,
                            qualityValue: _qualityValue,
                          ),
                          transitionsBuilder: (___, Animation<double> animation,
                              ____, Widget child) {
                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: animation,
                                child: child,
                              ),
                            );
                          },
                        ),
                      );
                      setState(
                        () {
                          _controller!.play();
                          _seek = true;
                        },
                      );
                    },
                  ),
                ),
              ),
              Center(
                child: Container(
                  margin: EdgeInsets.only(
                    left: videoWidth! + videoMargin - 48,
                    bottom: videoHeight! - 70,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.settings,
                      size: 26.0,
                    ),
                    onPressed: () {
                      position = _controller!.value.position.inSeconds;
                      _seek = true;
                      _settingModalBottomSheet(context);
                      setState(
                        () {},
                      );
                    },
                  ),
                ),
              ),
              Container(
                //===== Ползунок =====//
                margin: EdgeInsets.only(
                  top: videoHeight! - 26,
                  left: videoMargin,
                ), //CHECK IT
                child: _videoOverlaySlider(),
              )
            ],
          )
        : Center(
            child: Container(
              height: 5,
              width: videoWidth,
              margin: EdgeInsets.only(top: videoHeight! - 5),
              child: VideoProgressIndicator(
                _controller!,
                allowScrubbing: true,
                colors: VideoProgressColors(
                  playedColor: colors.primary,
                  backgroundColor: const Color(0x5515162B),
                  bufferedColor: colors.primary.withOpacity(0.5),
                ),
                padding: const EdgeInsets.only(top: 2),
              ),
            ),
          );
  }

  //=================== ПОЛЗУНОК ===================//
  Widget _videoOverlaySlider() {
    return ValueListenableBuilder(
      valueListenable: _controller!,
      builder: (context, VideoPlayerValue value, child) {
        if (!value.hasError && value.isInitialized) {
          return Row(
            children: <Widget>[
              Container(
                width: 46,
                alignment: const Alignment(0, 0),
                child: Text(
                  '${value.position.inMinutes}:${value.position.inSeconds - value.position.inMinutes * 60}',
                  style: const TextStyle(
                    fontFamily: 'ubuntu',
                  ),
                ),
              ),
              SizedBox(
                height: 20,
                width: videoWidth! - 92,
                child: VideoProgressIndicator(
                  _controller!,
                  allowScrubbing: true,
                  colors: VideoProgressColors(
                    playedColor: colors.primary,
                    backgroundColor: const Color(0x5515162B),
                    bufferedColor: colors.primary.withOpacity(0.5),
                  ),
                  padding: const EdgeInsets.only(
                    top: 8.0,
                    bottom: 8.0,
                  ),
                ),
              ),
              Container(
                width: 46,
                alignment: const Alignment(0, 0),
                child: Text(
                  '${value.duration.inMinutes}:${value.duration.inSeconds - value.duration.inMinutes * 60}',
                  style: const TextStyle(
                    fontFamily: 'ubuntu',
                  ),
                ),
              ),
            ],
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  @override
  void deactivate() {
    if (_controller != null) {
      _controller!.dispose();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller!.dispose();
    }
    super.dispose();
  }
}
