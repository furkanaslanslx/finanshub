import 'package:flutter/material.dart';
import 'package:hub/v/widgets/authors_widget.dart';
import 'package:hub/v/widgets/newslist_widget.dart';
import 'package:hub/vm/all_vms.dart';
import 'package:hub/vm/search_viewmodel.dart';
import 'package:hub/vm/themenotifier.dart';
import 'package:provider/provider.dart';
import 'package:hub/vm/list_viewmodel.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  bool _isRefreshing = false;
  bool _isDragging = false;
  bool _isRefreshed = false;
  double _dragOffset = 0.0;

  @override
  void initState() {
    super.initState();
    listViewModel.fetchPostsByPage();
  }

  Future<void> _onRefresh() async {
    if (mounted) {
      setState(() {
        _isDragging = false;
        _isRefreshing = true;
      });
    }
    listViewModel.resetPosts(fetchType: 'page');
    await listViewModel.fetchPostsByPage();
    if (mounted) {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  void scrollToTop() {
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeNotifier>(context, listen: true).isDarkMode;
    super.build(context);

    double safeAreaTop = MediaQuery.of(context).padding.top;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ListViewModel>.value(value: listViewModel),
        ChangeNotifierProvider<SearchViewModel>.value(value: searchViewModel),
      ],
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (scrollInfo is ScrollUpdateNotification) {
                        if (_scrollController.offset <= 0.0 && _scrollController.offset >= -100.0) {
                          setState(() {
                            _isDragging = true;
                            _dragOffset = (_scrollController.offset / 100).abs();
                          });
                        }
                        if (_scrollController.offset <= -100.0 && !_isRefreshing && !_isRefreshed) {
                          _isRefreshed = true;
                          _onRefresh();
                        }
                      }

                      if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                        if (!_isRefreshing && !listViewModel.isPageLoading) {
                          listViewModel.fetchPostsByPage();
                        }
                      }

                      if (scrollInfo is ScrollEndNotification) {
                        _isRefreshed = false;
                        setState(() {
                          _isDragging = false;
                          _dragOffset = 0.0;
                        });
                      }
                      return true;
                    },
                    child: Consumer<ListViewModel>(
                      builder: (context, viewModel, child) {
                        return ListView(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          children: [
                            const AuthorsListView(),
                            NewsListView(
                              externalScrollController: _scrollController,
                              triggerFunction: !_isRefreshing && !_isRefreshed,
                              onRefreshCallback: _onRefresh,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            if (_isDragging || _isRefreshing)
              Positioned(
                top: safeAreaTop,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: 4.0,
                  child: LinearProgressIndicator(
                    value: _dragOffset,
                    backgroundColor: Colors.transparent,
                    color: isDarkMode ? Colors.white : Colors.black,
                    minHeight: 4.0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
                //MARK:SİLMEYİN
                /* Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Consumer<SearchViewModel>(
                    builder: (context, searchViewModel, child) {
                      return TextField(
                        key: _textFieldKey,
                        controller: searchViewModel.searchController,
                        onChanged: searchViewModel.onSearchChanged,
                        
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0), 
                          isDense: true, 
                          hintText: 'Ara',
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF3970B8)),
                          hintStyle: const TextStyle(color: Color(0xFF3970B8)),
                          filled: true,
                          fillColor: Provider.of<ThemeNotifier>(context).isDarkMode ? Colors.grey[900] : Colors.grey[300],
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20.0)),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: const BorderSide(color: Color(0xFF3970B8), width: 1.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                          ),
                        ),
                      );
                    },
                  ),
                ), */            
                //MARK:SİLMEYİN
            /* SearchWidget(textFieldKey: _textFieldKey), */