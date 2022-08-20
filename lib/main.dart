import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

final PageController mangaBrowserController = PageController();
final PageController mangaReaderController = PageController();

int currentManga = 0;
int currentPage = 0;

List<bool> pages = [false, true, false];

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text('Home'),
          ),
          body: MangaBrowserWidget()),
    );
  }
}

class MangaBrowserWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: PageView.builder(
        controller: mangaBrowserController,
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        itemBuilder: (BuildContext context, int index) {
          return MangaReaderWidget();
        },
        onPageChanged: (page) {
          currentManga = page;
        },
      ),
    );
  }
}

class MangaReaderWidget extends StatelessWidget {
  double offset = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: PageView.builder(
        controller: mangaReaderController,
        scrollDirection: Axis.vertical,
        itemCount: pages.length,
        itemBuilder: (BuildContext context, int index) {
          double width = MediaQuery.of(context).size.width;
          final page = pages[index];
          ScrollController pageController = ScrollController();

          if (page) {
            pageController = ScrollController(initialScrollOffset: width);
          }

          return Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                    color: Colors.white,
                    child: Center(
                      child: GestureDetector(
                        child: AbsorbPointer(
                          absorbing: page, // If true, GestureDetector activates
                          child: MangaPageWidget(
                            isDoubleSpread: page,
                            controller: pageController,
                            isLeft: false,
                          ),
                        ),
                        onVerticalDragUpdate: (drag) {
                          double yChange = drag.delta.dy;
                          // yChange < 0 -> swiping up
                          // yChange > 0 -> swiping down

                          bool isSwipeUp = yChange < 0;

                          double currentOffset = min(
                              width, max(0, pageController.offset + yChange));
                          pageController.jumpTo(currentOffset);

                          bool isLeftSide = currentOffset == 0;
                          bool isRightSide = currentOffset == width;

                          if ((isLeftSide && isSwipeUp) ||
                              (isRightSide && !isSwipeUp)) {
                            double offset =
                                mangaReaderController.offset - yChange;
                            mangaReaderController.jumpTo(offset);
                          }
                        },
                        onVerticalDragEnd: (details) {
                          // Pan page left/right when swiping vertically
                          bool isSwipeUp =
                              details.velocity.pixelsPerSecond.direction < 0;
                          double width = MediaQuery.of(context).size.width;

                          if (pageController.offset == 0) {
                            // mangaReaderController.nextPage(
                            //     duration: Duration(milliseconds: 250),
                            //     curve: Curves.easeOut);
                          } else if (pageController.offset == width) {
                          } else {
                            pageController.animateTo(isSwipeUp ? 0 : width,
                                duration: Duration(milliseconds: 250),
                                curve: Curves.easeOut);
                          }
                        },
                        onHorizontalDragEnd: (details) {
                          // print('horiz drag end');
                          // bool isSwipeLeft =
                          //     details.velocity.pixelsPerSecond.dx < 0;
                          // print(isSwipeLeft);
                          // if (isSwipeLeft) {
                          //   mangaBrowserController.nextPage(
                          //       duration: Duration(milliseconds: 250),
                          //       curve: Curves.linear);
                          // } else {
                          //   mangaBrowserController.previousPage(
                          //       duration: Duration(milliseconds: 250),
                          //       curve: Curves.linear);
                          // }
                        },
                      ),
                    )),
              )
            ],
          );
        },
      ),
    );
  }
}

class MangaPageWidget extends StatelessWidget {
  bool isDoubleSpread = false;
  late ScrollController controller;
  bool isLeft = true;

  MangaPageWidget(
      {required this.isDoubleSpread,
      required this.controller,
      required this.isLeft});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    // IgnorePointer so scrollview won't be scrollable manually
    return IgnorePointer(
      ignoring: true,
      child: SingleChildScrollView(
        controller: controller,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: isDoubleSpread
              ? [
                  Container(
                    child: Image.network(
                        'https://storage.googleapis.com/manga-dev-313513.appspot.com/manga/en/e1bf1cc9-b6ad-4ad7-84b4-b926621da980/0001/00005.jpg'),
                    width: width,
                    height: height,
                  ),
                  Container(
                    child: Image.network(
                        'https://storage.googleapis.com/manga-dev-313513.appspot.com/manga/en/e1bf1cc9-b6ad-4ad7-84b4-b926621da980/0001/00006.jpg'),
                    width: width,
                    height: height,
                  ),
                ]
              : [
                  Container(
                    child: Image.network(
                        'https://storage.googleapis.com/manga-dev-313513.appspot.com/manga/en/e1bf1cc9-b6ad-4ad7-84b4-b926621da980/0001/00007.jpg'),
                    width: width,
                    height: height,
                  )
                ],
        ),
      ),
    );
  }
}
