import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hub/m/user_model.dart';
import 'package:hub/services/responsive.dart';
import 'package:hub/v/widgets/news_wdgt.dart';
import 'package:hub/vm/all_vms.dart';
import 'package:hub/vm/authors_viewmodel.dart';
import 'package:hub/vm/themenotifier.dart';
import 'package:provider/provider.dart';

class AuthordetailView extends StatefulWidget {
  const AuthordetailView({super.key, required this.id});

  final int id;

  @override
  State<AuthordetailView> createState() => _AuthordetailViewState();
}

class _AuthordetailViewState extends State<AuthordetailView> {
  late ScrollController _scrollController;
  late UserProfile authorProfile;

  @override
  void initState() {
    super.initState();
    debugPrint('statement');
    authorsViewModel.fetchAuthorNews(widget.id);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  void _fetchNews() async {
    await authorsViewModel.fetchAuthorNews(widget.id);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (authorsViewModel.hasMoreAuthorNews) {
        _fetchNews();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/finanshub.png', height: 50),
        backgroundColor: themeNotifier.isDarkMode ? Colors.black : themeNotifier.iconColor,
      ),
      body: ChangeNotifierProvider.value(
        value: authorsViewModel,
        child: Consumer<AuthorsViewModel>(
          builder: (context, model, child) {
            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              controller: _scrollController,
              itemCount: model.authorNews.length + 2,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Container(
                    margin: EdgeInsets.only(
                      top: ResponsiveSize.getWidth(context, 2.5),
                      left: ResponsiveSize.getWidth(context, 2.5),
                      right: ResponsiveSize.getWidth(context, 2.5),
                    ),
                    padding: EdgeInsets.all(ResponsiveSize.getWidth(context, 10)),
                    width: ResponsiveSize.getWidth(context, 95),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(ResponsiveSize.getWidth(context, 5)),
                      color: Provider.of<ThemeNotifier>(context).isDarkMode ? Colors.grey[900] : Colors.grey[300],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(ResponsiveSize.getWidth(context, 2.5)),
                          child: CachedNetworkImage(
                            imageUrl: authorsViewModel.returnUserProfileByID(widget.id)?.avatars[0].url ??
                                'https://www.finanshub.com/wp-content/uploads/2024/08/haber-hatti_avatar-90x90.png',
                            width: ResponsiveSize.getWidth(context, 30),
                            height: ResponsiveSize.getWidth(context, 30),
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: ResponsiveSize.getWidth(context, 10)),
                        Expanded(
                            child: Text(
                          authorsViewModel.returnUserProfileByID(widget.id)?.name ?? 'FinansHub',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                        )),
                      ],
                    ),
                  );
                }

                if (index == model.authorNews.length + 1) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: model.hasMoreAuthorNews ? const CupertinoActivityIndicator() : const Text('Tüm veriler yüklendi'),
                    ),
                  );
                }

                final news = model.authorNews[index - 1];
                return NewsWdgt(news: news, index: null);
              },
            );
          },
        ),
      ),
    );
  }
}
