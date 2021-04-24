import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/names_repository.dart';
import 'package:hello_me/user_profile.dart';
import 'package:provider/provider.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'dart:ui' as ui;

import 'auth_repository.dart';

class SuggestionsScreen extends StatefulWidget {
  @override
  _SuggestionsScreenState createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  final _suggestions = generateWordPairs().take(10).toList();
  final _biggerFont = TextStyle(fontSize: 18.0);
  final _snappingSheetController = SnappingSheetController();
  final _snappingPositions = [
    SnappingPosition.factor(
      positionFactor: 0.0,
      grabbingContentOffset: GrabbingContentOffset.top,
    ),
    SnappingPosition.pixels(positionPixels: 150)
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthRepository, NamesRepository>(
        builder: (context, authRepository, namesRepository, _) {
      return StreamBuilder(
          stream: namesRepository.savedStream,
          builder:
              (BuildContext context, AsyncSnapshot<Set<WordPair>> snapshot) {
            Set<WordPair> savedWordsStream = snapshot.data ?? {};
            double blurSigma = _snappingSheetController.isAttached
                ? (_snappingSheetController.currentPosition - 25) / 125 * 4
                : 0;
            return Scaffold(
              appBar: AppBar(
                title: Text('Startup Name Generator'),
                actions: [
                  IconButton(
                      icon: Icon(Icons.list),
                      onPressed: () =>
                          Navigator.of(context).pushNamed("/saved")),
                  authRepository.isAuthenticated
                      ? IconButton(
                          icon: Icon(Icons.exit_to_app),
                          onPressed: authRepository.signOut)
                      : IconButton(
                          icon: Icon(Icons.login),
                          onPressed: () =>
                              Navigator.of(context).pushNamed("/login"))
                ],
              ),
              body: authRepository.isAuthenticated
                  ? SnappingSheet(
                      controller: _snappingSheetController,
                      child: Stack(
                        children: [
                          _buildSuggestions(namesRepository, savedWordsStream),
                          IgnorePointer(
                              ignoring: _snappingSheetController.isAttached && _snappingSheetController
                                      .currentSnappingPosition ==
                                  _snappingPositions[0],
                              child: Container(
                                  child: BackdropFilter(
                                filter: ui.ImageFilter.blur(
                                    sigmaX: blurSigma, sigmaY: blurSigma),
                                child: Container(
                                  color: Colors.transparent,
                                ),
                              )))
                        ],
                      ),
                      grabbingHeight: 50,
                      grabbing: UserProfileBanner(
                        onTap: _openSheet,
                        isOpen: isOpen,
                        authRepository: authRepository,
                      ),
                      snappingPositions: _snappingPositions,
                      onSheetMoved: (double _) {
                        setState(() {});
                      },
                      sheetBelow: SnappingSheetContent(
                        sizeBehavior: SheetSizeStatic(height: 100),
                        draggable: true,
                        child: UserProfile(authRepository: authRepository),
                      ),
                    )
                  : _buildSuggestions(namesRepository, savedWordsStream),
            );
          });
    });
  }

  bool get isOpen {
    return _snappingSheetController.isAttached &&
        _snappingPositions
                .indexOf(_snappingSheetController.currentSnappingPosition) ==
            1;
  }

  void _openSheet() {
    setState(() {
      int currentSnapIndex = _snappingPositions
          .indexOf(_snappingSheetController.currentSnappingPosition);
      _snappingSheetController
          .snapToPosition(_snappingPositions[1 - currentSnapIndex]);
    });
  }

  Widget _buildSuggestions(
      NamesRepository namesRepository, Set<WordPair> savedWordsStream) {
    return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemBuilder: (BuildContext _context, int i) {
          if (i.isOdd) {
            return Divider();
          }

          final int index = i ~/ 2;
          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10).toList());
          }
          return _buildRow(
              _suggestions[index], namesRepository, savedWordsStream, _context);
        });
  }

  Widget _buildRow(WordPair pair, NamesRepository namesRepository,
      Set<WordPair> savedWordsStream, BuildContext context) {
    final alreadySaved = savedWordsStream.contains(pair); // NEW
    return ListTile(
        title: Text(
          pair.asPascalCase,
          style: _biggerFont,
        ),
        trailing: Icon(
          alreadySaved ? Icons.favorite : Icons.favorite_border,
          color: alreadySaved ? Theme.of(context).primaryColor : Colors.grey,
        ),
        onTap: () {
          if (alreadySaved) {
            namesRepository.deleteSuggestion(pair);
          } else {
            namesRepository.saveSuggestion(pair);
          }
        });
  }
}
