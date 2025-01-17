import 'package:flutter/material.dart';
import 'package:hub/m/news_model.dart';
import 'package:hub/services/api_service.dart';

class NewsViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  ContentItem? contentItem;
  bool isLoading = false;

  Future<void> fetchNewsByID(int id) async {
    isLoading = true;
    notifyListeners();
    try {
      contentItem = await _apiService.fetchNewsByID(id);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
