import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape_small.dart';
import 'package:hub/m/news_model.dart';
import 'package:hub/services/responsive.dart';
import 'package:hub/v/authordetail_view.dart';
import 'package:hub/vm/all_vms.dart';
import 'package:hub/vm/fav_viewmodel.dart';
import 'package:hub/vm/list_viewmodel.dart';
import 'package:hub/vm/news_viewmodel.dart';
import 'package:hub/vm/themenotifier.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

class NewsView extends StatefulWidget {
  const NewsView({
    super.key,
    required this.item,
    required this.index,
  });

  final int? index;
  final ContentItem item;

  @override
  State<NewsView> createState() => _NewsViewState();
}

late PageController _pageController;

class _NewsViewState extends State<NewsView> {
  HtmlUnescape unescape = HtmlUnescape();

  @override
  void initState() {
    super.initState();
    if (widget.index != null) {
      _pageController = PageController(initialPage: widget.index!);
    }
  }

  @override
  void dispose() {
    if (widget.index != null) {
      _pageController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ListViewModel>.value(value: listViewModel),
        ChangeNotifierProvider<FavViewModel>.value(value: favViewModel),
        ChangeNotifierProvider<ThemeNotifier>.value(value: themeNotifier),
      ],
      child: Scaffold(
          appBar: AppBar(
            title: Image.asset('assets/finanshub.png', height: 50),
            backgroundColor: themeNotifier.isDarkMode ? Colors.black : themeNotifier.iconColor,
          ),
          body: Consumer<ListViewModel>(
            builder: (context, listModel, child) {
              if (widget.index == null) {
                return NewsPageContent(
                  articleId: widget.item.id,
                );
              } else {
                return PageView.builder(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (index) async {
                    // await firebaseAnalytics.logEvent(
                    //   name: 'read_article',
                    //   parameters: {
                    //     'article_id': listModel.pagePosts[index].id,
                    //   },
                    // );
                    // debugPrint('logged: ${listModel.pagePosts[index].id}');
                    if (index >= listModel.pagePosts.length - 2 && listModel.hasMorePage && !listModel.isPageLoading) {
                      await listModel.fetchPostsByPage();
                      setState(() {});
                    }
                  },
                  itemCount: listModel.pagePosts.length,
                  itemBuilder: (context, index) {
                    ContentItem article = listModel.pagePosts[index];
                    return NewsPageContent(
                      articleId: article.id,
                    );
                  },
                );
              }
            },
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: (() {
            if (widget.index == null) {
              return const SizedBox();
            } else {
              return Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 36), // Sol tarafta butonun ekran kenarına yapışmasını önler
                  FloatingActionButton(
                    onPressed: () {
                      if (_pageController.hasClients) {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: const Icon(Icons.arrow_back),
                  ),
                  const Spacer(),
                  FloatingActionButton(
                    onPressed: () {
                      if (_pageController.hasClients) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: const Icon(Icons.arrow_forward),
                  ),
                  const SizedBox(width: 36), // Sağ tarafta butonun ekran kenarına yapışmasını önler
                ],
              );
            }
          }())),
    );
  }
}

class NewsPageContent extends StatefulWidget {
  final int articleId;

  const NewsPageContent({super.key, required this.articleId});

  @override
  State<NewsPageContent> createState() => _NewsPageContentState();
}

class _NewsPageContentState extends State<NewsPageContent> with AutomaticKeepAliveClientMixin<NewsPageContent> {
  @override
  bool get wantKeepAlive => true;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _dividerKey = GlobalKey();
  HtmlUnescape unescape = HtmlUnescape();
  Map<int, String> dataMap = {
    2: 'Analiz Vakti',
    5: 'Bankacılık',
    1056: 'Bilanço Haberleri',
    36: 'Borsa',
    1: 'Dünya',
    37: 'Ekonomi',
    2109: 'Finans Haberleri',
    106: 'Finans Hub Özel',
    2222: 'Gezi Rehberi',
    52: 'Gündem'
  };

  double _fabOpacity = 1.0;

  late NewsViewModel model;

  @override
  void initState() {
    super.initState();
    model = NewsViewModel();
    model.addListener(_onModelChange);
    model.fetchNewsByID(widget.articleId);
    _scrollController.addListener(_onScroll);
    // _logFirebase();
  }

  void _logFirebase() async {
    if (!model.isLoading) {
      await firebaseAnalytics.logEvent(
        name: 'read_article',
        parameters: {
          'article_id': model.contentItem!.id,
        },
      );
      debugPrint('logged: ${model.contentItem?.id}');
    }
  }

  void _onModelChange() {
    setState(() {});
  }

  void _onScroll() {
    if (_dividerKey.currentContext != null) {
      RenderBox dividerBox = _dividerKey.currentContext!.findRenderObject() as RenderBox;
      Offset dividerPosition = dividerBox.localToGlobal(Offset.zero);

      double screenHeight = MediaQuery.of(context).size.height;

      if (dividerPosition.dy <= screenHeight - kToolbarHeight - 80) {
        if (_fabOpacity != 0.0) {
          setState(() => _fabOpacity = 0.0);
        }
      } else {
        if (_fabOpacity != 1.0) {
          setState(() => _fabOpacity = 1.0);
        }
      }
    }
  }

  @override
  void dispose() {
    model.removeListener(_onModelChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    ContentItem? article = model.contentItem;

    if (model.isLoading || article == null) {
      return const Center(child: CupertinoActivityIndicator());
    } else {}

    String? category = dataMap[model.contentItem!.categories!.first.id];
    category ??= 'Haberler';
    DateFormat inputFormat = DateFormat('M/d/yyyy h:mm:ss a');
    DateTime insertedDate = article.insertedAt != null ? inputFormat.parse(article.insertedAt!) : DateTime.now();
    String insertedDateForView = DateFormat('dd MMMM yyyy HH:mm', 'tr_TR').format(insertedDate);
    DateTime updatedDate = article.updatedAt != null ? inputFormat.parse(article.updatedAt!) : DateTime.now();
    String updatedDateForView = DateFormat('dd MMMM yyyy HH:mm', 'tr_TR').format(updatedDate);

    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            if (scrollInfo.metrics.pixels == scrollInfo.metrics.minScrollExtent) {
              if (_fabOpacity != 1.0) {
                setState(() => _fabOpacity = 1.0);
              }
            }
            return true;
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    if (article.imgUrl.isEmpty)
                      ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(30)),
                        child: Image.asset(
                          'assets/appicon.png',
                          width: ResponsiveSize.getWidth(context, 95),
                          height: ResponsiveSize.getWidth(context, 50),
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        child: CachedNetworkImage(
                          imageUrl: article.imgUrl,
                          width: ResponsiveSize.getWidth(context, 98),
                          height: ResponsiveSize.getWidth(context, 55),
                          fit: BoxFit.cover,
                        ),
                      ),
                    Container(
                      margin: EdgeInsets.only(
                        left: ResponsiveSize.getWidth(context, 3),
                        right: ResponsiveSize.getWidth(context, 3),
                        bottom: ResponsiveSize.getWidth(context, 2),
                      ),
                      padding: EdgeInsets.all(ResponsiveSize.getWidth(context, 2)),
                      decoration: BoxDecoration(
                        color: themeNotifier.isDarkMode ? Colors.black54 : Colors.white70,
                        borderRadius: const BorderRadius.all(Radius.circular(6)),
                      ),
                      child: Text(
                        unescape.convert(article.header),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: themeNotifier.isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: ResponsiveSize.getWidth(context, 90),
                  child: const Row(
                    children: [
                      Text('finanshub.com'),
                      Spacer(),
                    ],
                  ),
                ),
                Divider(
                  color: themeNotifier.iconColor,
                  height: 20,
                ),
                SizedBox(
                  width: ResponsiveSize.getWidth(context, 95),
                  child: Row(
                    children: [
                      Icon(Icons.home, color: themeNotifier.iconColor),
                      Expanded(
                        child: Text(
                          ' / $category / ${unescape.convert(article.header)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: themeNotifier.iconColor,
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    if (!mounted) return;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AuthordetailView(id: article.userId),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width: ResponsiveSize.getWidth(context, 18),
                        margin: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(ResponsiveSize.getWidth(context, 11.5)),
                              child: CachedNetworkImage(
                                imageUrl: authorsViewModel.returnUserProfileByID(article.userId)?.avatars[0].url ??
                                    'https://www.finanshub.com/wp-content/uploads/2024/08/haber-hatti_avatar-90x90.png',
                                fit: BoxFit.cover,
                                placeholder: (context, url) => SizedBox(
                                  height: ResponsiveSize.getWidth(context, 18),
                                  width: ResponsiveSize.getWidth(context, 18),
                                  child: const Center(child: CupertinoActivityIndicator()),
                                ),
                                errorWidget: (context, url, error) => SizedBox(
                                  height: ResponsiveSize.getWidth(context, 18),
                                  width: ResponsiveSize.getWidth(context, 18),
                                  child: const Center(child: Icon(Icons.error)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            authorsViewModel.returnUserProfileByID(article.userId)?.name ?? 'FinansHub',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          Text('Yayınlanma:\n$insertedDateForView'),
                          Text('Güncellenme:\n$updatedDateForView'),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: themeNotifier.iconColor,
                  height: 20,
                ),
                article.blogs != null && article.blogs!.isNotEmpty
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: article.blogs!.length,
                        itemBuilder: (context, index) {
                          if (article.blogs![index].content != null) {
                            return Padding(
                              padding: const EdgeInsets.all(10),
                              child: (() {
                                switch (article.blogs![index].elementType) {
                                  case 'li':
                                    return Text('• ${unescape.convert(article.blogs![index].content!)}');
                                  case 'h2':
                                    return Text(
                                      unescape.convert(article.blogs![index].content!),
                                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                    );
                                  case 'pre':
                                    String duzenlenmisMetin = article.blogs![index].content!.replaceAllMapped('•', (match) {
                                      return '\n•';
                                    });
                                    return Text(duzenlenmisMetin);
                                  default:
                                    return Text(unescape.convert(article.blogs![index].content!));
                                }
                              }()),
                            );
                          } else {
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => FullScreenImage(imageUrl: article.blogs![index].url!),
                                ));
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                                  child: CachedNetworkImage(imageUrl: article.blogs![index].url!),
                                ),
                              ),
                            );
                          }
                        },
                      )
                    : const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CupertinoActivityIndicator(),
                        ),
                      ),
                Divider(
                  key: _dividerKey,
                  color: themeNotifier.iconColor,
                  height: 20,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 116.0,
          right: 36.0,
          child: Opacity(
            opacity: _fabOpacity,
            child: Consumer<FavViewModel>(
              builder: (context, fav, child) {
                bool isContains = fav.isFavorite(article);
                return FloatingActionButton(
                  heroTag: 'news_page_fab_${widget.articleId}',
                  backgroundColor: Colors.black87,
                  child: Icon(
                    Icons.favorite,
                    size: 30,
                    color: isContains ? Colors.red : Colors.white,
                  ),
                  onPressed: () {
                    if (_fabOpacity == 0.0) return;
                    if (isContains) {
                      fav.removeFavorite(article);
                    } else {
                      fav.addFavorite(article);
                    }
                  },
                );
              },
            ),
          ),
        ),
        // Positioned(
        //   bottom: 36.0,
        //   right: 36.0,
        //   left: 36.0,
        //   child: Row(
        //     mainAxisSize: MainAxisSize.max,
        //     children: [
        //       FloatingActionButton(
        //         onPressed: () {
        //           if (_pageController.hasClients) {
        //             _pageController.previousPage(
        //               duration: const Duration(milliseconds: 500),
        //               curve: Curves.easeInOut,
        //             );
        //           }
        //         },
        //         child: const Icon(Icons.arrow_back),
        //       ),
        //       const Spacer(),
        //       FloatingActionButton(
        //         onPressed: () {
        //           if (_pageController.hasClients) {
        //             _pageController.nextPage(
        //               duration: const Duration(milliseconds: 500),
        //               curve: Curves.easeInOut,
        //             );
        //           }
        //         },
        //         child: const Icon(Icons.arrow_forward),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }
}

class FullScreenImage extends StatefulWidget {
  final String imageUrl;

  const FullScreenImage({super.key, required this.imageUrl});

  @override
  State<FullScreenImage> createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage> {
  late PhotoViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PhotoViewController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          _controller.scale = 0.0;
          Navigator.of(context).pop();
        },
        child: Container(
          decoration: const BoxDecoration(color: Colors.black),
          child: Center(
            child: ClipRRect(
              child: PhotoView(
                controller: _controller,
                imageProvider: CachedNetworkImageProvider(widget.imageUrl),
                backgroundDecoration: const BoxDecoration(color: Colors.black),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 3.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
