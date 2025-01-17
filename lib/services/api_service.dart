// ignore_for_file: prefer_is_empty, unrelated_type_equality_checks

import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:hub/m/category_model.dart';
import 'package:hub/m/news_model.dart';
import 'package:hub/m/user_model.dart';
import 'package:hub/services/token_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String _baseUrl = 'http://api.yazbakalim.com.tr/api/finanshub';
  final String _localFileName = 'default_db.json';

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<bool> _isConnected() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } on SocketException {
      return false;
    }
  }

  Future<void> initializeLocalDb() async {
    final file = await _getLocalFile();

    if (!await file.exists()) {
      try {
        String data = await rootBundle.loadString('assets/default_db.json');
        await file.writeAsString(data);
      } catch (e) {
        throw Exception(e);
      }
    }
  }

  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_localFileName');
  }

  Future<Map<String, dynamic>> _readLocalDb() async {
    final file = await _getLocalFile();
    try {
      if (await file.exists()) {
        String contents = await file.readAsString();
        return jsonDecode(contents);
      }
      return {};
    } on FormatException catch (e) {
      try {
        await file.delete();

        await initializeLocalDb();
      } catch (deleteError) {
        throw Exception(e);
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  Future<void> _writeLocalDb(Map<String, dynamic> data) async {
    try {
      final file = await _getLocalFile();
      String jsonString = jsonEncode(data);
      await file.writeAsString(jsonString);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> _updateLocalDb(String key, dynamic newData, {String? subKey}) async {
    final currentData = await _readLocalDb();

    if (subKey != null) {
      if (currentData[key] == null || currentData[key] is! Map) {
        currentData[key] = {};
      }
      currentData[key][subKey] = newData;
    } else {
      currentData[key] = newData;
    }

    await _writeLocalDb(currentData);
  }

  Map<String, dynamic> createRequestModel({int? page, int? aid, int? bid, int? cid}) {
    return {
      "T": globalToken,
      "Page": page,
      "AId": aid,
      "BId": bid,
      "CId": cid,
    };
  }

  Future<void> _checkToken() async {
    await checkAndRefreshToken();
  }

  Future<void> initialize() async {
    await initializeLocalDb();
  }

  Future<List<UserProfile>> fetchUsers() async {
    if (await _isConnected()) {
      try {
        await _checkToken();
        Uri url = Uri.parse('$_baseUrl/getusers');
        var requestModel = createRequestModel();

        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(requestModel),
        );

        if (response.statusCode == 200) {
          final List<dynamic> body = jsonDecode(response.body);

          if (body.isNotEmpty && body.length != 0) {
            await _updateLocalDb('users', body);
            return body.map((dynamic item) => UserProfile.fromJson(item)).toList();
          } else {
            return _getUsersFromLocalDb();
          }
        } else {
          return _getUsersFromLocalDb();
        }
      } catch (e) {
        return _getUsersFromLocalDb();
      }
    } else {
      return _getUsersFromLocalDb();
    }
  }

  Future<List<ContentItem>> fetchAuthorNews(int id, int page) async {
    if (await _isConnected()) {
      try {
        await _checkToken();
        Uri url = Uri.parse('$_baseUrl/getpostbyauthor');
        var requestModel = createRequestModel(page: page, aid: id);

        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(requestModel),
        );

        if (response.statusCode == 200) {
          final List<dynamic> body = jsonDecode(response.body);

          if (body.isNotEmpty && body.length != 0) {
            await _updateLocalDb('posts_by_author', body, subKey: id.toString());
            return body.map((dynamic item) => ContentItem.fromJson(item)).toList();
          } else {
            return _getPostsByAuthorFromLocalDb(id);
          }
        } else {
          return _getPostsByAuthorFromLocalDb(id);
        }
      } catch (e) {
        return _getPostsByAuthorFromLocalDb(id);
      }
    } else {
      return _getPostsByAuthorFromLocalDb(id);
    }
  }

  Future<List<Category>> fetchCategories() async {
    if (await _isConnected()) {
      try {
        await _checkToken();
        Uri url = Uri.parse('$_baseUrl/getcategory');
        var requestModel = createRequestModel();

        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(requestModel),
        );

        if (response.statusCode == 200) {
          final List<dynamic> body = jsonDecode(response.body);

          if (body.isNotEmpty && body.length != 0) {
            await _updateLocalDb('categories', body);
            return body.map((dynamic item) => Category.fromJson(item)).toList();
          } else {
            return _getCategoriesFromLocalDb();
          }
        } else {
          return _getCategoriesFromLocalDb();
        }
      } catch (e) {
        return _getCategoriesFromLocalDb();
      }
    } else {
      return _getCategoriesFromLocalDb();
    }
  }

  Future<List<ContentItem>> fetchPostsByCate(int cate, int page) async {
    if (await _isConnected()) {
      try {
        await _checkToken();
        Uri url = Uri.parse('$_baseUrl/getpostbycate');
        var requestModel = createRequestModel(page: page, cid: cate);

        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(requestModel),
        );

        if (response.statusCode == 200) {
          final List<dynamic> body = jsonDecode(response.body);

          if (body.isNotEmpty && body.length != 0) {
            await _updateLocalDb('posts_by_category', body, subKey: cate.toString());
            return body.map((dynamic item) => ContentItem.fromJson(item)).toList();
          } else {
            return _getPostsByCategoryFromLocalDb(cate);
          }
        } else {
          return _getPostsByCategoryFromLocalDb(cate);
        }
      } catch (e) {
        return _getPostsByCategoryFromLocalDb(cate);
      }
    } else {
      return _getPostsByCategoryFromLocalDb(cate);
    }
  }

  Future<List<ContentItem>> fetchPostsByPage(int page) async {
    if (await _isConnected()) {
      try {
        await _checkToken();
        Uri url = Uri.parse('$_baseUrl/getpostbypage');
        var requestModel = createRequestModel(page: page);

        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(requestModel),
        );

        if (response.statusCode == 200) {
          final List<dynamic> body = jsonDecode(response.body);

          if (body.isNotEmpty && body.length != 0) {
            await _updateLocalDb('posts_by_page', body, subKey: page.toString());
            return body.map((dynamic item) => ContentItem.fromJson(item)).toList();
          } else {
            return _getPostsByPageFromLocalDb(page);
          }
        } else {
          return _getPostsByPageFromLocalDb(page);
        }
      } catch (e) {
        return _getPostsByPageFromLocalDb(page);
      }
    } else {
      return _getPostsByPageFromLocalDb(page);
    }
  }

  Future<ContentItem> fetchNewsByID(int id) async {
    if (await _isConnected()) {
      try {
        await _checkToken();
        Uri url = Uri.parse('$_baseUrl/getblogbyid');
        var requestModel = createRequestModel(bid: id);

        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(requestModel),
        );

        if (response.statusCode == 200) {
          final dynamic body = jsonDecode(response.body);

          if (body != null && body.isNotEmpty && (body is Map<String, dynamic>) && body.length != 0) {
            await _updateLocalDb('single_posts', body, subKey: id.toString());
            return ContentItem.fromJson(body);
          } else {
            return _getPostByIdFromLocalDb(id);
          }
        } else {
          return _getPostByIdFromLocalDb(id);
        }
      } catch (e) {
        return _getPostByIdFromLocalDb(id);
      }
    } else {
      return _getPostByIdFromLocalDb(id);
    }
  }

  Future<List<UserProfile>> _getUsersFromLocalDb() async {
    final localData = await _readLocalDb();
    List<dynamic> usersJson = localData['users'] ?? [];
    return usersJson.map((dynamic item) => UserProfile.fromJson(item)).toList();
  }

  Future<List<ContentItem>> _getPostsByAuthorFromLocalDb(int authorId) async {
    final localData = await _readLocalDb();
    Map<String, dynamic> postsByAuthor = localData['posts_by_author'] ?? {};
    List<dynamic> postsJson = postsByAuthor[authorId.toString()] ?? [];
    return postsJson.map((dynamic item) => ContentItem.fromJson(item)).toList();
  }

  Future<List<Category>> _getCategoriesFromLocalDb() async {
    final localData = await _readLocalDb();
    List<dynamic> categoriesJson = localData['categories'] ?? [];
    return categoriesJson.map((dynamic item) => Category.fromJson(item)).toList();
  }

  Future<List<ContentItem>> _getPostsByCategoryFromLocalDb(int categoryId) async {
    final localData = await _readLocalDb();
    Map<String, dynamic> postsByCategory = localData['posts_by_category'] ?? {};
    List<dynamic> postsJson = postsByCategory[categoryId.toString()] ?? [];
    return postsJson.map((dynamic item) => ContentItem.fromJson(item)).toList();
  }

  Future<List<ContentItem>> _getPostsByPageFromLocalDb(int page) async {
    final localData = await _readLocalDb();
    Map<String, dynamic> postsByPage = localData['posts_by_page'] ?? {};
    List<dynamic> postsJson = postsByPage[page.toString()] ?? [];
    return postsJson.map((dynamic item) => ContentItem.fromJson(item)).toList();
  }

  Future<ContentItem> _getPostByIdFromLocalDb(int id) async {
    final localData = await _readLocalDb();
    Map<String, dynamic> singlePosts = localData['single_posts'] ?? {};
    dynamic postJson = singlePosts[id.toString()];

    if (postJson != null) {
      return ContentItem.fromJson(postJson);
    } else {
      throw Exception('ID $id\'ye sahip haber yerel veritabanında bulunamadı.');
    }
  }
}
