import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape_small.dart';
import 'package:hub/m/news_model.dart';
import 'package:hub/services/responsive.dart';
import 'package:hub/v/news_view.dart';
import 'package:hub/vm/all_vms.dart';
import 'package:hub/vm/themenotifier.dart';
import 'package:provider/provider.dart';

class NewsWdgt extends StatelessWidget {
  const NewsWdgt({super.key, required this.news, required this.index});
  final ContentItem news;
  final int? index;

  @override
  Widget build(BuildContext context) {
    HtmlUnescape unescape = HtmlUnescape();

    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveSize.getWidth(context, 2.5), top: ResponsiveSize.getWidth(context, 2.5)),
      child: GestureDetector(
        onTap: () async {
          await firebaseAnalytics.logEvent(
            name: 'page_view',
            parameters: {
              'page_title': news.header,
            },
          );
          debugPrint('logged: ${news.id}');
          if (!context.mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                // final newsViewModel = NewsViewModel();
                return NewsView(
                  item: news,
                  index: index,
                  // model: newsViewModel,
                );
              },
            ),
          );
        },
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            if (news.imgUrl.isEmpty)
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
                  errorWidget: (context, url, error) => const Center(child: Icon(Icons.warning_amber_rounded, color: Colors.red)),
                  memCacheWidth: 712,
                  memCacheHeight: 375,
                  imageUrl: news.imgUrl,
                  width: ResponsiveSize.getWidth(context, 95),
                  height: ResponsiveSize.getWidth(context, 50),
                  fit: BoxFit.cover,
                ),
              ),
            Container(
              margin: EdgeInsets.only(
                left: ResponsiveSize.getWidth(context, 4.5),
                right: ResponsiveSize.getWidth(context, 4.5),
                bottom: ResponsiveSize.getWidth(context, 2),
              ),
              padding: EdgeInsets.all(ResponsiveSize.getWidth(context, 1)),
              decoration: BoxDecoration(
                color: Provider.of<ThemeNotifier>(context).isDarkMode ? Colors.black54 : Colors.white70,
                borderRadius: const BorderRadius.all(Radius.circular(6)),
              ),
              child: Text(
                unescape.convert(news.header),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Provider.of<ThemeNotifier>(context).isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
