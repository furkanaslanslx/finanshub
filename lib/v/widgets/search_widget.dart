import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hub/vm/search_viewmodel.dart';

class SearchWidget extends StatefulWidget {
  final GlobalKey textFieldKey;

  const SearchWidget({super.key, required this.textFieldKey});

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  @override
  Widget build(BuildContext context) {
    final Map<int, String> imageExtensions = {
      0: 'jpg',
      1: 'png',
      2: 'jpg',
      3: 'jpeg',
      4: 'jpg',
    };
    return Consumer<SearchViewModel>(
      builder: (context, searchViewModel, child) {
        if (searchViewModel.isSearching || searchViewModel.searchResults.isNotEmpty) {
          return Positioned(
            left: 10,
            top: (widget.textFieldKey.currentContext?.findRenderObject() as RenderBox?)!.size.height.abs() + 8,
            right: 10,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.65,
              ),
              child: Card(
                elevation: 5,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: searchViewModel.searchResults.length,
                  itemBuilder: (context, index) {
                    String? extension = imageExtensions[index % 5];
                    String imagePath = 'assets/newsphotos/${index % 5}.$extension';
                    return ListTile(
                      leading: Image.asset(imagePath),
                      title: Text(searchViewModel.searchResults[index], maxLines: 3, overflow: TextOverflow.ellipsis),
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          searchViewModel.searchResults.clear();
                          searchViewModel.searchController.clear();
                        });
                      },
                    );
                  },
                ),
              ),
            ),
          );
        }
        return Container();
      },
    );
  }
}
