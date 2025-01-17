import 'package:flutter/material.dart';
import 'package:hub/v/widgets/news_wdgt.dart';
import 'package:hub/vm/all_vms.dart';
import 'package:hub/vm/fav_viewmodel.dart';
import 'package:provider/provider.dart';

class FavouritesView extends StatefulWidget {
  const FavouritesView({super.key});

  @override
  State<FavouritesView> createState() => _FavouritesViewState();
}

class _FavouritesViewState extends State<FavouritesView> {
  String avatarSrc = 'assets/authorlogo.webp';

  @override
  void initState() {
    super.initState();
    favViewModel.loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: favViewModel,
      child: Consumer<FavViewModel>(
        builder: (context, model, child) {
          return Scaffold(
            body: model.favs.isEmpty
                ? const Center(child: Text('Henüz favoriniz yok.'))
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: model.favs.length,
                    itemBuilder: (context, index) {
                      return NewsWdgt(news: model.favs[model.favs.length - index - 1], index: null);
                    },
                  ),
          );
        },
      ),
    );
  }
}
