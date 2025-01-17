import 'package:flutter/cupertino.dart';
import 'package:hub/v/widgets/news_wdgt.dart';
import 'package:hub/vm/all_vms.dart';
import 'package:hub/vm/list_viewmodel.dart';
import 'package:provider/provider.dart';

class NewsListView extends StatefulWidget {
  final ScrollController externalScrollController;
  final bool triggerFunction;
  final Function onRefreshCallback;

  const NewsListView({
    super.key,
    required this.externalScrollController,
    required this.triggerFunction,
    required this.onRefreshCallback,
  });

  @override
  State<NewsListView> createState() => _NewsListViewState();
}

class _NewsListViewState extends State<NewsListView> {
  @override
  void initState() {
    super.initState();
    widget.externalScrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (widget.externalScrollController.position.pixels == widget.externalScrollController.position.maxScrollExtent) {
      if (!listViewModel.isPageLoading && listViewModel.hasMorePage) {
        listViewModel.fetchPostsByPage();
      }
    }
    if ((widget.externalScrollController.offset <= -100.0 && widget.triggerFunction) && !listViewModel.isPageLoading) {
      listViewModel.resetPosts(fetchType: 'page');
      listViewModel.fetchPostsByPage();
    }
  }

  @override
  void dispose() {
    widget.externalScrollController.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: listViewModel,
      child: Consumer<ListViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: viewModel.pagePosts.length + 1,
                itemBuilder: (context, index) {
                  if (index == viewModel.pagePosts.length) {
                    return SizedBox(
                      height: 100,
                      child: Center(
                        child: viewModel.hasMorePage ? const CupertinoActivityIndicator() : const Text('Tüm veriler yüklendi.'),
                      ),
                    );
                  } else {
                    return NewsWdgt(news: viewModel.pagePosts[index], index: index);
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
