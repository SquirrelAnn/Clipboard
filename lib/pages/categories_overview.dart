import 'package:clipboard/models/category.dart';
import 'package:clipboard/widgets/alertwidgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/dark_theme.dart';
import '../theme/light_theme.dart';

import 'package:uuid/uuid.dart';

class CategoriesOverview extends StatefulWidget {
  const CategoriesOverview({Key? key, required this.categories, required this.saveCategories}) : super(key: key);

  final List<Category> categories;

  final Function saveCategories;

  @override
  State<CategoriesOverview> createState() => _CategoriesOverviewState();
}

class _CategoriesOverviewState extends State<CategoriesOverview> {
  int catIndex = 0;
  int hoveredIndex = -1; // Track the hovered index for categories
  int hoveredSnippetIndex = -1; // Track hovered index for snippets

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
                            child: MouseRegion(
                              // Wrap with MouseRegion
                              onHover: (PointerHoverEvent event) {
                                setState(() {
                                  hoveredIndex = index;
                                });
                              },
                              onExit: (PointerExitEvent event) {
                                setState(() {
                                  hoveredIndex = -1;
                                });
                              },
                              child: TextButton(
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                                    if (states.contains(WidgetState.hovered)) {
                                      return CustomDarkTheme.darkTheme.cardColor;
                                    }
                                    return index == catIndex
                                        ? CustomLightTheme.lightTheme.textButtonTheme.style?.backgroundColor
                                                ?.resolve(states) ??
                                            Colors.grey // Selected background color
                                        : CustomDarkTheme.darkTheme.textButtonTheme.style?.backgroundColor
                                                ?.resolve(states) ??
                                            Colors.transparent; // Default background color (transparent)
                                  }),
                                  foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                                    //Keep the original foreGroundColor logic
                                    return index == catIndex
                                        ? CustomLightTheme.lightTheme.textButtonTheme.style?.foregroundColor
                                                ?.resolve(states) ??
                                            Colors.black // Selected color
                                        : CustomDarkTheme.darkTheme.textButtonTheme.style?.foregroundColor
                                                ?.resolve(states) ??
                                            Colors.white; // Default color
                                  }),
                                ),
                                child: Text(widget.categories[index].name),
                                onPressed: () {
                                  setState(() {
                                    catIndex = index;
                                  });
                                },
                              ),
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
    AlertWidgets.showNumTxtDlgSnippet("Add new snippet", setValueSnippet, context);
  }

  setValueSnippet(Snippet val) {
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
                      child: MouseRegion(
                        onHover: (PointerHoverEvent event) {
                          setState(() {
                            hoveredSnippetIndex = index; // Track the hovered snippet
                          });
                        },
                        onExit: (PointerExitEvent event) {
                          setState(() {
                            hoveredSnippetIndex = -1;
                          });
                        },
                        child: TextButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                              if (states.contains(WidgetState.hovered)) {
                                return CustomDarkTheme.darkTheme.cardColor; // Hover background color
                              }
                              return CustomDarkTheme.darkTheme.textButtonTheme.style?.backgroundColor
                                      ?.resolve(states) ??
                                  Colors.transparent;
                            }),
                            foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                              return CustomDarkTheme.darkTheme.textButtonTheme.style?.foregroundColor
                                      ?.resolve(states) ??
                                  Colors.transparent;
                            }),
                          ),
                          child: RichText(
                            text: TextSpan(
                              text:
                                  "${widget.categories[catIndex].snippets[index].snippetTitle}: ${widget.categories[catIndex].snippets[index].snippetText}",
                            ),
                          ),
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: widget.categories[catIndex].snippets[index].snippetText));
                          },
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      deleteSnippet(index);
                    },
                    icon: const Icon(Icons.delete),
                  ),
                  Container(
                    width: 70,
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
      List<Snippet> testSnippets = [];
      var uuid = const Uuid();
      var v1 = uuid.v1();
      Category category = Category(id: v1, name: val, snippets: testSnippets);
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
