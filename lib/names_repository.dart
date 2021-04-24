import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/cupertino.dart';
import 'package:hello_me/auth_repository.dart';

class NamesRepository with ChangeNotifier {
  final AuthRepository _authRepository;
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');
  final Set<WordPair> _localSavedNames = <WordPair>{};

  NamesRepository(this._authRepository);

  void update(AuthRepository newAuthRepository) async {
    if (_authRepository.user != newAuthRepository.user) {
      if (newAuthRepository.isAuthenticated) {
        DocumentReference userReference =
            users.doc(newAuthRepository.user?.uid);

        Set<WordPair> userWordPairs = await _getUserSavedWords();
        _localSavedNames.addAll(userWordPairs);

        await userReference.set({
          'names': _localSavedNames
              .map((e) => {'first': e.first, 'second': e.second})
              .toList()
        });
      } else {
        _localSavedNames.clear();
      }
      notifyListeners();
    }
  }

  Set<WordPair> get saved {
    return _localSavedNames;
  }

  Stream<Set<WordPair>> get _localSavedStream async* {
    yield _localSavedNames;
  }

  Stream<Set<WordPair>> get savedStream {
    if (_authRepository.isAuthenticated) {
      return users
          .doc(_authRepository.user?.uid)
          .snapshots()
          .map<Set<WordPair>>((snapshot) {
        Map<String, dynamic>? userData = snapshot.data();
        return userData?['names']
            .map<WordPair>((e) => WordPair(e['first'], e['second']))
            .toSet();
      });
    }
    return _localSavedStream;
  }

  Future<Set<WordPair>> _getUserSavedWords() async {
    DocumentReference userReference = users.doc(_authRepository.user?.uid);
    DocumentSnapshot userSnapshot = await userReference.get();

    Set<WordPair> userNames = {};
    if (userSnapshot.exists) {
      Map<String, dynamic>? userData = userSnapshot.data();
      Set<WordPair> userWordPairs = userData?['names']
          .map<WordPair>((e) => WordPair(e['first'], e['second']))
          .toSet();
      userNames.addAll(userWordPairs);
    }
    return userNames;
  }

  void saveSuggestion(WordPair suggestion) async {
    if (_authRepository.isAuthenticated) {
      DocumentReference userReference = users.doc(_authRepository.user?.uid);

      Set<WordPair> userNames = await _getUserSavedWords();
      userNames.add(suggestion);

      await userReference.set({
        'names': userNames
            .map((WordPair pair) => {'first': pair.first, 'second': pair.second})
            .toList()
      });
    } else {
      _localSavedNames.add(suggestion);
    }
    notifyListeners();
  }

  void deleteSuggestion(WordPair suggestion) async {
    if (_authRepository.isAuthenticated) {
      DocumentReference userReference = users.doc(_authRepository.user?.uid);

      Set<WordPair> userNames = await _getUserSavedWords();
      userNames.remove(suggestion);

      await userReference.set({
        'names': userNames
            .map((e) => {'first': e.first, 'second': e.second})
            .toList()
      });
    } else {
      _localSavedNames.remove(suggestion);
    }
    notifyListeners();
  }
}
