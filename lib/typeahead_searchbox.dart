import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:searchbase/searchbase.dart';
import 'package:searchbase/src/searchwidget.dart';

class SearchBoxTypeAhead extends StatelessWidget {
  final TextEditingController _typeAheadController = TextEditingController();
  final SearchWidget searchWidget;

  SearchBoxTypeAhead(this.searchWidget);

  Future getSuggestions(String query) async {
    await Future.delayed(Duration(seconds: 1));
    //
    // return List.generate(3, (index) {
    //   return 'name: ${query + index.toString()}';
    // });
    print('inside future ==>> $query');
    if (searchWidget != null) {
      searchWidget.setValue(query, options: Options(triggerDefaultQuery: true));
    }

    return searchWidget.suggestions.map((elem) => elem.label);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        TypeAheadField(
            textFieldConfiguration: TextFieldConfiguration(
              // autofocus: true,
              style: DefaultTextStyle.of(context)
                  .style
                  .copyWith(fontStyle: FontStyle.italic),
              decoration: InputDecoration(border: OutlineInputBorder()),
              controller: this._typeAheadController,
            ),
            suggestionsCallback: (pattern) async {
              print(pattern);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                // print('suggestions callback');
                if (searchWidget != null) {
                  searchWidget.setValue(pattern,
                      options: Options(
                          triggerDefaultQuery: true, stateChanges: false));
                  this._typeAheadController.text = pattern;
                  // searchWidget.triggerCustomQuery();
                  // print('search widget ==>> ${searchWidget.suggestions}');
                }
              });
              // print('pattern ==>> $pattern');

              // searchWidget.setValue(pattern);
              // searchWidget.triggerCustomQuery();
              // Completer<List<String>> completer = new Completer();
              // completer.complete(<String>["cobalt", "copper"]);
              return searchWidget.suggestions.map((elem) => elem.label);
            },
            keepSuggestionsOnLoading: false,
            debounceDuration: Duration(milliseconds: 100),
            // suggestionsCallback: (pattern) async {
            //   print('inside suggestionsCallback ==>> $pattern');
            //
            //   // return await getSuggestions(pattern);
            //   return ["cobalt", "copper"];
            // },
            itemBuilder: (context, suggestion) {
              // print(
              //     'search widget2 ==>> ${searchWidget.results.numberOfResults}');
              return ListTile(title: Text(suggestion));
            },
            onSuggestionSelected: (suggestion) {
              this._typeAheadController.text = suggestion;
            })
      ],
    );
  }
}
