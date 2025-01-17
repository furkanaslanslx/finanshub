import 'package:flutter/material.dart';
import 'package:hub/m/news_model.dart';
import 'package:hub/services/api_service.dart';

class ListViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<ContentItem> catePosts = [];
  bool isCateLoading = false;
  bool _isCateFetching = false;
  int _cateCurrentPage = 1;
  bool hasMoreCate = true;
  int? _currentCategoryId;
  DateTime? _lastCateFetchTime;

  List<ContentItem> pagePosts = [];
  bool isPageLoading = false;
  bool _isPageFetching = false;
  int _pageCurrentPage = 1;
  bool hasMorePage = true;
  DateTime? _lastPageFetchTime;

  Future<void> fetchPostsByCate(int cate) async {
    final currentTime = DateTime.now();

    if (cate != _currentCategoryId) {
      resetPosts(fetchType: 'cate');
      _currentCategoryId = cate;
    }

    if ((_isCateFetching || !hasMoreCate || (_lastCateFetchTime != null && currentTime.difference(_lastCateFetchTime!).inSeconds < 1)) && !(cate != _currentCategoryId)) {
      return;
    }

    _lastCateFetchTime = currentTime;
    _isCateFetching = true;
    isCateLoading = true;
    notifyListeners();

    try {
      List<ContentItem> newPosts = await _apiService.fetchPostsByCate(cate, _cateCurrentPage);

      if (_currentCategoryId != cate) return;

      if (newPosts.length < 10) {
        hasMoreCate = false;
      }

      catePosts.addAll(newPosts);
      _cateCurrentPage++;
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (_currentCategoryId == cate) {
        isCateLoading = false;
        _isCateFetching = false;
        notifyListeners();
      }
    }
  }

  Future<void> fetchPostsByPage() async {
    final currentTime = DateTime.now();

    if (_isPageFetching || !hasMorePage || (_lastPageFetchTime != null && currentTime.difference(_lastPageFetchTime!).inSeconds < 1)) {
      return;
    }

    _lastPageFetchTime = currentTime;
    _isPageFetching = true;
    isPageLoading = true;
    notifyListeners();

    try {
      List<ContentItem> newPosts = await _apiService.fetchPostsByPage(_pageCurrentPage);

      if (newPosts.length < 10) {
        hasMorePage = false;
      }

      pagePosts.addAll(newPosts);
      _pageCurrentPage++;
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isPageLoading = false;
      _isPageFetching = false;
      notifyListeners();
    }
  }

  void resetPosts({required String fetchType}) {
    if (fetchType == 'cate') {
      catePosts.clear();
      _cateCurrentPage = 1;
      hasMoreCate = true;
      isCateLoading = false;
      _isCateFetching = false;
    } else if (fetchType == 'page') {
      pagePosts.clear();
      _pageCurrentPage = 1;
      hasMorePage = true;
      isPageLoading = false;
      _isPageFetching = false;
    }
    notifyListeners();
  }
}
