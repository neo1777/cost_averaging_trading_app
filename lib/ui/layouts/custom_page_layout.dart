import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:cost_averaging_trading_app/ui/widgets/responsive_text.dart';

class CustomPageLayout extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget? floatingActionButton;

  const CustomPageLayout({
    super.key,
    required this.title,
    required this.children,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: ResponsiveText(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  centerTitle: false,
                ),
              ),
              SliverPadding(
                padding:
                    EdgeInsets.all(sizingInformation.isMobile ? 16.0 : 24.0),
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
          ),
          floatingActionButton: floatingActionButton,
        );
      },
    );
  }
}
