import 'package:flutter/material.dart';
import 'package:hub/m/news_model.dart';
import 'package:hub/services/variables.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavViewModel extends ChangeNotifier {
  List<ContentItem> favs = [];

  Future<void> loadFavorites() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedFavs = prefs.getStringList(savedContentItemsKey) ?? [];

    favs = savedFavs.map((favJson) {
      Map<String, dynamic> json = jsonDecode(favJson);
      return ContentItem.fromJson(json);
    }).toList();

    notifyListeners();
  }

  bool isFavorite(ContentItem item) {
    return favs.any((favItem) => favItem.id == item.id);
  }

  Future<void> removeFavorite(ContentItem item) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    favs.removeWhere((favItem) => favItem.id == item.id);

    List<String> updatedFavs = favs.map((fav) => jsonEncode(fav.toJson())).toList();
    await prefs.setStringList(savedContentItemsKey, updatedFavs);

    notifyListeners();
  }

  Future<void> addFavorite(ContentItem item) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (!favs.any((favItem) => favItem.id == item.id)) {
      favs.add(item);

      List<String> updatedFavs = favs.map((fav) => jsonEncode(fav.toJson())).toList();
      await prefs.setStringList(savedContentItemsKey, updatedFavs);

      notifyListeners();
    }
  }
}
