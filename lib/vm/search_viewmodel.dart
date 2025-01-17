import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:hub/services/api_service.dart';

class SearchViewModel extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;
  List<String> searchResults = [];
  bool isSearching = false;

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      performSearch(query);
    });
  }

  void performSearch(String query) async {
    if (query.isEmpty) {
      searchResults = [];
      isSearching = false;
      notifyListeners();
      return;
    }
    isSearching = true;
    notifyListeners();
    // ApiService apiService = ApiService();
    // List<Post> posts = await apiService.fetchPosts();
    // searchResults = posts.where((post) => post.title.toLowerCase().contains(query.toLowerCase())).map((post) => post.title).toList();

    isSearching = false;
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}
