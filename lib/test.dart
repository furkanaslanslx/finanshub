import 'package:flutter/material.dart';
import 'package:hub/services/api_service.dart';
import 'package:hub/services/token_service.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  final ApiService _apiService = ApiService();
  @override
  void initState() {
    super.initState();
    fetch();
    loadOrFetchTokenAndSet();
  }

  Future<void> loadOrFetchTokenAndSet() async {
    await loadOrFetchToken();
    setState(() {});
  }

  fetch() {
    _apiService.fetchPostsByPage(0);
    // _apiService.fetchUsers();
    // _apiService.fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
