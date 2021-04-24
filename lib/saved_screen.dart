import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/names_repository.dart';
import 'package:provider/provider.dart';

class SavedScreen extends StatelessWidget {
  final _biggerFont = TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    return Consumer<NamesRepository>(
      builder: (context, namesRepository, _) {
        return StreamBuilder<Set<WordPair>>(
          stream: namesRepository.savedStream,
          builder: (BuildContext context, AsyncSnapshot<Set<WordPair>> snapshot) {
            Set<WordPair> snapshotData = snapshot.data ?? {};

            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading");
            }

            final tiles = snapshotData.map(
                  (WordPair pair) {
                return ListTile(
                    title: Text(
                      pair.asPascalCase,
                      style: _biggerFont,
                    ),
                    trailing: IconButton(
                        icon: Icon(Icons.delete_outline,
                            color: Theme.of(context).primaryColor),
                        onPressed: () {
                          namesRepository.deleteSuggestion(pair);
                        }));
              },
            );
            final divided = ListTile.divideTiles(
              context: context,
              tiles: tiles,
            );


            return Scaffold(
              appBar: AppBar(
                title: Text('Saved Suggestions'),
              ),
              body: snapshotData.isNotEmpty
                  ? ListView(children: divided.toList())
                  : SafeArea(child: Text('There are no saved names')),
            );
          }
        );

      }
    );
  }
}
