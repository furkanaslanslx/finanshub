import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hub/services/responsive.dart';
import 'package:hub/v/authordetail_view.dart';
import 'package:hub/vm/all_vms.dart';
import 'package:hub/vm/authors_viewmodel.dart';
import 'package:provider/provider.dart';

class AuthorsListView extends StatefulWidget {
  const AuthorsListView({super.key});

  @override
  State<AuthorsListView> createState() => _AuthorsListViewState();
}

class _AuthorsListViewState extends State<AuthorsListView> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthorsViewModel>.value(
      value: authorsViewModel,
      child: Consumer<AuthorsViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              SizedBox(
                child: (() {
                  if (viewModel.fetchedUsers == null) {
                    return const Center(child: CupertinoActivityIndicator());
                  }
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: viewModel.fetchedUsers!.map((user) {
                        return GestureDetector(
                          onTap: () {
                            if (!mounted) return;
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => AuthordetailView(id: user.id),
                              ),
                            );
                          },
                          child: Container(
                            width: ResponsiveSize.getWidth(context, 18),
                            margin: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(ResponsiveSize.getWidth(context, 11.5)),
                                  child: CachedNetworkImage(
                                    imageUrl: user.avatars[0].url,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => SizedBox(
                                      height: ResponsiveSize.getWidth(context, 18),
                                      width: ResponsiveSize.getWidth(context, 18),
                                      child: const Center(child: CupertinoActivityIndicator()),
                                    ),
                                    errorWidget: (context, url, error) => SizedBox(
                                      height: ResponsiveSize.getWidth(context, 18),
                                      width: ResponsiveSize.getWidth(context, 18),
                                      child: const Center(child: Icon(Icons.error)),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  user.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }()),
              ),
            ],
          );
        },
      ),
    );
  }
}
