import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:hub/vm/authors_viewmodel.dart';
import 'package:hub/vm/category_viewmodel.dart';
import 'package:hub/vm/fav_viewmodel.dart';
import 'package:hub/vm/list_viewmodel.dart';
import 'package:hub/vm/search_viewmodel.dart';
import 'package:hub/vm/themenotifier.dart';

FavViewModel favViewModel = FavViewModel();
AuthorsViewModel authorsViewModel = AuthorsViewModel()..fetchUsers();
CategoryViewModel categoryViewModel = CategoryViewModel();
ListViewModel listViewModel = ListViewModel();
SearchViewModel searchViewModel = SearchViewModel();
ThemeNotifier themeNotifier = ThemeNotifier(ThemeMode.system, const Color(0xFFFD4F46));
FirebaseAnalytics firebaseAnalytics = FirebaseAnalytics.instance;
