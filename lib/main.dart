import 'package:flutter/material.dart';
import 'package:searchbase/searchbase.dart';
import 'package:flutter_searchbox/flutter_searchbox.dart';
import 'results.dart';
import 'author_filter.dart';
import 'custom_appbar.dart';
import 'typeahead_searchbox.dart';

void main() {
  runApp(FlutterSearchBoxApp());
}

class FlutterSearchBoxApp extends StatelessWidget {
  final SearchBase searchbase;
  final index = 'good-books-ds';
  final credentials = 'a03a1cb71321:75b6603d-9456-4a5a-af6b-a487b309eb61';
  final url = 'https://arc-cluster-appbase-demo-6pjy6z.searchbase.io';

  FlutterSearchBoxApp({Key key, this.searchbase}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // The SearchBaseProvider should wrap your MaterialApp or WidgetsApp. This will
    // ensure all routes have access to the store.
    return SearchBaseProvider(
      // Pass the searchbase instance to the SearchBaseProvider. Any ancestor `SearchWidgetConnector`
      // Widgets will find and use this value as the `SearchWidget`.
      searchbase: SearchBase(index, url, credentials,
          appbaseConfig: AppbaseSettings(
              recordAnalytics: true,
              // Use unique user id to personalize the recent searches
              userId: 'jon@appbase.io')),
      child: MaterialApp(
        title: "SearchBox Demo",
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SearchBox Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        key: _scaffoldKey,
        appBar: CustomAppBar(
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: SearchWidgetConnector(
                  id: 'search-widget',
                  enablePopularSuggestions: true,
                  maxPopularSuggestions: 3,
                  size: 10,
                  type: QueryType.search,
                  dataField: [
                    {'field': 'original_title', 'weight': 1},
                    {'field': 'original_title.search', 'weight': 3}
                  ],
                  value: '',
                  builder: (context, searchWidget) {
                    print(searchWidget);
                    // if (searchWidget.query == null) {
                    //   searchWidget.triggerDefaultQuery();
                    // }
                    return SearchBoxTypeAhead(searchWidget);
                  },
                  triggerQueryOnInit: false,
                  destroyOnDispose: false,
                ),
              ),
            ],
          ),
        ),
        body: Center(
          // A custom UI widget to render a list of results
          child: SearchWidgetConnector(
              id: 'result-widget',
              dataField: 'original_title',
              // subscribeTo: ['requestPending'],
              react: {
                'and': ['search-widget', 'author-filter'],
              },
              size: 10,
              triggerQueryOnInit: true,
              preserveResults: true,
              builder: (context, searchWidget) => ResultsWidget(searchWidget)),
        ),
        // A custom UI widget to render a list of authors
        drawer: SearchWidgetConnector(
          id: 'author-filter',
          type: QueryType.term,
          dataField: "authors.keyword",
          size: 10,
          // Initialize with default value
          value: List<String>(),
          react: {
            'and': ['search-widget']
          },
          builder: (context, searchWidget) {
            // Call searchWidget's query at first time
            if (searchWidget.query == null) {
              searchWidget.triggerDefaultQuery();
            }
            return AuthorFilter(searchWidget);
          },
          // Avoid fetching query for each open/close action instead call it manually
          triggerQueryOnInit: false,
          // Do not remove the search widget's instance after unmount
          destroyOnDispose: false,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          // isExtended: true,
          child: Icon(Icons.add),
          backgroundColor: Colors.green,
          onPressed: () {
            _scaffoldKey.currentState.openDrawer();
          },
        ),
      ),
    );
  }
}
