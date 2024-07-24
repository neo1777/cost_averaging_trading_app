// lib/ui/layouts/custom_page_layout.dart

import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class CustomPageLayout extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget? floatingActionButton;
  final bool useSliver;

  const CustomPageLayout({
    Key? key,
    required this.title,
    required this.children,
    this.floatingActionButton,
    this.useSliver = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveBuilder(
        builder: (context, sizingInformation) {
          if (useSliver) {
            return _buildSliverLayout(context, sizingInformation);
          } else {
            return _buildStandardLayout(context, sizingInformation);
          }
        },
      ),
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _buildSliverLayout(
      BuildContext context, SizingInformation sizingInformation) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Text(title),
          floating: true,
          snap: true,
          pinned: true,
        ),
        SliverPadding(
          padding: EdgeInsets.all(sizingInformation.isMobile ? 8.0 : 16.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: children[index],
                );
              },
              childCount: children.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStandardLayout(
      BuildContext context, SizingInformation sizingInformation) {
    return Column(
      children: [
        AppBar(
          title: Text(title),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(sizingInformation.isMobile ? 8.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children
                  .map((child) => Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: child,
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
