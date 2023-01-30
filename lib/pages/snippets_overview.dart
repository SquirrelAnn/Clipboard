import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/category.dart';
import '../theme/dark_theme.dart';
import '../widgets/alertwidgets.dart';

class SnippetsOverview extends StatefulWidget {
  const SnippetsOverview({Key? key, required this.title, required this.category, required this.saveCategories})
      : super(key: key);

  final Category category;
  final Function saveCategories;
  final String title;

  @override
  _SnippetsOverviewState createState() => _SnippetsOverviewState();
}

class _SnippetsOverviewState extends State<SnippetsOverview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: CustomDarkTheme.darkTheme.textTheme.headlineMedium,
        ),
      ),
      body: Column(children: [
        Expanded(
          child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 4.0),
              itemCount: widget.category.snippets.length,
              itemBuilder: (BuildContext context, int index) {
                if (widget.category.snippets.isNotEmpty) {
                  return Column(children: [
                    Row(children: [
                      IconButton(
                        onPressed: () {
                          deleteSnippet(index);
                        },
                        icon: const Icon(Icons.delete),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4, right: 10),
                          child: TextButton(
                            child: RichText(
                              text: TextSpan(
                                text: widget.category.snippets[index],
                              ),
                            ),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: widget.category.snippets[index]));
                            },
                          ),
                        ),
                      ),
                    ]),
                  ]);
                } else {
                  return Container();
                }
              }),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: showAlertDialog,
        tooltip: 'Add category',
        child: const Icon(Icons.add),
      ),
    );
  }

  showAlertDialog() {
    AlertWidgets.showNumTxtDlg("Add new snippet", setValue, context);
  }

  setValue(String val) {
    widget.category.snippets.add(val);
    widget.saveCategories();
  }

  deleteSnippet(int index) {
    widget.category.snippets.removeAt(index);
    widget.saveCategories();
  }
}
