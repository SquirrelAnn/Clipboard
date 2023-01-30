import 'package:clipboard/models/category.dart';
import 'package:clipboard/widgets/alertwidgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/dark_theme.dart';
import '../theme/light_theme.dart';

class CategoriesOverview extends StatefulWidget {
  const CategoriesOverview({Key? key, required this.categories, required this.saveCategories}) : super(key: key);

  final List<Category> categories;

  final Function saveCategories;

  @override
  State<CategoriesOverview> createState() => _CategoriesOverviewState();
}

class _CategoriesOverviewState extends State<CategoriesOverview> {
  int catIndex = 0;

  @override
  Widget build(BuildContext context) {
    ScrollController controller = ScrollController(initialScrollOffset: 10);
    ScrollController controller2 = ScrollController(initialScrollOffset: 10);

    return Scaffold(
        body: Row(children: [
          Expanded(
            flex: 1,
            child: ListView.builder(
                controller: controller,
                padding: const EdgeInsets.only(bottom: 4.0),
                itemCount: widget.categories.length,
                itemBuilder: (BuildContext context, int index) {
                  if (widget.categories.isNotEmpty) {
                    return Column(children: [
                      Row(children: [
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10, top: 4),
                            child: TextButton(
                              style: index == catIndex
                                  ? CustomLightTheme.lightTheme.textButtonTheme.style
                                  : CustomDarkTheme.darkTheme.textButtonTheme.style,
                              child: Text(widget.categories[index].name),
                              onPressed: () async {
                                setState(() {
                                  catIndex = index;
                                });
                              },
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            showDecisionDialog(index);
                          },
                          icon: const Icon(Icons.delete),
                        ),
                      ]),
                    ]);
                  } else {
                    return Container();
                  }
                }),
          ),
          const VerticalDivider(
            color: Color.fromARGB(255, 134, 35, 226),
          ),
          Expanded(
            flex: 3,
            child: Container(
              child: getSnippets(controller2),
            ),
          ),
        ]),
        floatingActionButton: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          const SizedBox(
            width: 30,
          ),
          FloatingActionButton(
            onPressed: showAlertDialog,
            tooltip: 'Add new category',
            child: const Icon(Icons.add),
          ),
          const Spacer(),
          FloatingActionButton(
            onPressed: showAlertDialogSnippet,
            tooltip: 'Add snippet',
            child: const Icon(Icons.add),
          ),
        ]));
  }

  showAlertDialogSnippet() {
    AlertWidgets.showNumTxtDlg("Add new snippet", setValueSnippet, context);
  }

  setValueSnippet(String val) {
    widget.categories[catIndex].snippets.add(val);
    widget.saveCategories();
    setState(() {});
  }

  deleteSnippet(int index) {
    widget.categories[catIndex].snippets.removeAt(index);
    widget.saveCategories();
    setState(() {});
  }

  getSnippets(ScrollController controller) {
    if (widget.categories.isNotEmpty && widget.categories.length > catIndex) {
      return ListView.builder(
          controller: controller,
          padding: const EdgeInsets.only(bottom: 4.0),
          itemCount: widget.categories[catIndex].snippets.length,
          itemBuilder: (BuildContext context, int index) {
            if (widget.categories[catIndex].snippets.isNotEmpty) {
              return Column(children: [
                Row(children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4, right: 10),
                      child: TextButton(
                        child: RichText(
                          text: TextSpan(
                            text: widget.categories[catIndex].snippets[index],
                          ),
                        ),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: widget.categories[catIndex].snippets[index]));
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      deleteSnippet(index);
                    },
                    icon: const Icon(Icons.delete),
                  ),
                ]),
              ]);
            } else {
              return Container();
            }
          });
    } else {
      return Container();
    }
  }

  showAlertDialog() {
    AlertWidgets.showNumTxtDlg("Add new category", setValue, context);
  }

  setValue(String val) {
    if (val.isNotEmpty) {
      List<String> testSnippets = [];
      Category category = Category(val, testSnippets);
      widget.categories.add(category);
      widget.saveCategories();
    }
  }

  deleteCategory(int index) {
    widget.categories.removeAt(index);
    widget.saveCategories();
  }

  showDecisionDialog(int index) {
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: const Text("OK"),
      onPressed: () async {
        deleteCategory(index);
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Warning", style: CustomDarkTheme.darkTheme.textTheme.bodyMedium),
      content: Text(
        "Delete category?",
        style: CustomDarkTheme.darkTheme.textTheme.bodyMedium,
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
