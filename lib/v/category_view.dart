import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hub/v/widgets/news_wdgt.dart';
import 'package:hub/vm/all_vms.dart';
import 'package:hub/vm/list_viewmodel.dart';
import 'package:hub/vm/themenotifier.dart';
import 'package:provider/provider.dart';

class CategoryView extends StatefulWidget {
  const CategoryView({super.key});

  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  bool _isLoading = false;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);

    _fetchCategoryPage();
  }

  void _fetchCategoryPage() async {
    setState(() => _isLoading = true);
    await categoryViewModel.fetchCategories();
    setState(() {
      _isLoading = false;
      _tabController?.dispose();
      _tabController = TabController(length: categoryViewModel.categories.length, vsync: this);
    });

    if (categoryViewModel.categories.isNotEmpty) {
      listViewModel.fetchPostsByCate(categoryViewModel.categories[0].id);
    }
  }

  void _scrollListener() {
    if (_scrollController.position.extentAfter < 50) {
      listViewModel.fetchPostsByCate(categoryViewModel.categories[_tabController!.index].id);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeNotifier>(context, listen: true).isDarkMode;

    return Scaffold(
      body: Column(
        children: [
          if (_isLoading)
            LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              color: isDarkMode ? Colors.white : Colors.black,
              minHeight: 4.0,
            ),
          if (!_isLoading && _tabController != null)
            Container(
              color: isDarkMode ? Colors.black : Colors.white,
              child: TabBar(
                labelColor: isDarkMode ? Colors.white : Colors.black,
                unselectedLabelColor: isDarkMode ? Colors.white60 : Colors.black54,
                indicatorColor: isDarkMode ? Colors.white : Colors.black,
                controller: _tabController,
                isScrollable: true,
                physics: const BouncingScrollPhysics(),
                onTap: (index) {
                  if (listViewModel.isCateLoading) return;
                  listViewModel.resetPosts(fetchType: 'cate');
                  listViewModel.fetchPostsByCate(categoryViewModel.categories[index].id);
                },
                tabs: categoryViewModel.categories.map((category) => Tab(text: category.name)).toList(),
              ),
            ),
          Expanded(
            child: _tabController != null
                ? ChangeNotifierProvider<ListViewModel>.value(
                    value: listViewModel,
                    child: Consumer<ListViewModel>(
                      builder: (context, model, child) {
                        if (model.isCateLoading && model.catePosts.isEmpty) {
                          return const Center(child: CupertinoActivityIndicator());
                        }
                        return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          controller: _scrollController,
                          itemCount: model.catePosts.length + (model.hasMoreCate ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == model.catePosts.length) {
                              return const Center(
                                child: SizedBox(
                                  height: 50,
                                  child: CupertinoActivityIndicator(),
                                ),
                              );
                            }
                            final news = model.catePosts[index];
                            return NewsWdgt(news: news, index: null);
                          },
                        );
                      },
                    ),
                  )
                : const Center(child: Text('No Categories Available')),
          ),
        ],
      ),
    );
  }
}
