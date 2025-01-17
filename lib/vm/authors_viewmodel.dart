import 'package:flutter/material.dart';
import 'package:hub/m/news_model.dart';
import 'package:hub/m/user_model.dart';
import 'package:hub/services/api_service.dart';

class AuthorsViewModel extends ChangeNotifier {
  final List<UserProfile> _authors = [];
  final List<ContentItem> _authorNews = [];
  final ApiService _apiService = ApiService();

  bool _isFetchingUsers = false;
  bool _hasMoreUsers = true;
  List<UserProfile>? fetchedUsers;

  bool _isFetchingAuthorNews = false;
  bool _hasMoreAuthorNews = true;
  List<ContentItem> fetchedAuthorNews = [];
  int _currentAuthorPage = 1;
  int? _lastFetchedAuthorId;

  List<UserProfile> get users => _authors;
  bool get isFetchingUsers => _isFetchingUsers;
  bool get hasMoreUsers => _hasMoreUsers;

  List<ContentItem> get authorNews => _authorNews;
  bool get hasMoreAuthorNews => _hasMoreAuthorNews;

  void resetAuthorNews() {
    _authorNews.clear();
    _currentAuthorPage = 1;
    _hasMoreAuthorNews = true;
    _lastFetchedAuthorId = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<void> fetchUsers() async {
    if (_isFetchingUsers || !_hasMoreUsers) return;
    _isFetchingUsers = true;
    notifyListeners();

    try {
      fetchedUsers = await _apiService.fetchUsers();
      if (fetchedUsers!.isEmpty) {
        _hasMoreUsers = false;
      } else {
        _authors.addAll(fetchedUsers!);
      }
      //  for (int i = 0; i < fetchedUsers!.length; i++) {
      //    debugPrint('${fetchedUsers?[i].id}');
      //  }
    } catch (e) {
      throw Exception('Failed to load users');
    } finally {
      _isFetchingUsers = false;
      notifyListeners();
    }
  }

  Future<void> fetchAuthorNews(int id) async {
    debugPrint('Fetching author news...');

    if (_lastFetchedAuthorId != null && _lastFetchedAuthorId != id) {
      resetAuthorNews();
    }

    if (_isFetchingAuthorNews || !_hasMoreAuthorNews) return;

    if (_lastFetchedAuthorId != null && _lastFetchedAuthorId == id) {
      _currentAuthorPage++;
    } else {
      _currentAuthorPage = 1;
      _hasMoreAuthorNews = true;
    }

    _isFetchingAuthorNews = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final news = await _apiService.fetchAuthorNews(id, _currentAuthorPage);

      if (news.isEmpty || news.length < 10) {
        _hasMoreAuthorNews = false;
      }

      if (_currentAuthorPage == 1) {
        _authorNews.clear();
      }

      _authorNews.addAll(news);
      _lastFetchedAuthorId = id;
    } catch (e) {
      throw Exception('Failed to load author news');
    } finally {
      _isFetchingAuthorNews = false;
      notifyListeners();
    }
  }

  UserProfile? returnUserProfileByID(int id) {
    try {
      return _authors.firstWhere((user) => user.id == id);
    } on StateError {
      // Eğer eşleşen bir kullanıcı bulunamazsa, StateError yakalanır ve null döndürülür
      return null;
    }
  }
}
