import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/auth_repository.dart';
import 'package:provider/provider.dart';

const DEFAULT_AVATAR = 'https://cdn3.iconfinder.com/data/icons/avatars-round-flat/33/avat-01-512.png';

class UserProfile extends StatefulWidget {
  final AuthRepository? authRepository;

  UserProfile({this.authRepository});

  @override
  _UserProfileState createState() =>
      _UserProfileState(authRepository: authRepository);
}

class _UserProfileState extends State<UserProfile> {
  final AuthRepository? authRepository;

  _UserProfileState({this.authRepository});

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: EdgeInsets.only(top: 16),
                child: SizedBox(
                    width: 100,
                    child: Container(
                      height: 85,
                      width: 85,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: NetworkImage(
                                (authRepository?.user?.photoURL ?? DEFAULT_AVATAR),
                              ))),
                    ))),
            Expanded(
                flex: 1,
                child: Padding(
                    padding: EdgeInsets.only(top: 25, left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            child: Text(authRepository?.user?.email ?? "null",
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .bodyText1)),
                        Expanded(
                            flex: 1,
                            child: Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Column(children: [
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          primary:
                                          Theme
                                              .of(context)
                                              .accentColor),
                                      onPressed: _onChangeAvatarPress,
                                      child: Text("Change Avatar",
                                          style: (Theme
                                              .of(context)
                                              .textTheme
                                              .bodyText1 as TextStyle)
                                              .merge(TextStyle(
                                              color: Colors.white))))
                                ])))
                      ],
                    )))
          ],
        ));
  }

  _onChangeAvatarPress() async {
    FilePickerResult? result =
    await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      File file = File(result.files.single.path!);
      await Provider.of<AuthRepository>(context, listen: false)
          .changeAvatar(file);
    }
  }
}

class UserProfileBanner extends StatelessWidget {
  final VoidCallback? onTap;
  final bool? isOpen;
  final AuthRepository? authRepository;

  UserProfileBanner({this.onTap, this.isOpen, this.authRepository});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          onTap?.call();
        },
        child: Container(
          color: Theme
              .of(context)
              .bottomAppBarColor,
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              Expanded(
                  flex: 1,
                  child: Text('Welcome back, ${authRepository?.user?.email}',
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodyText2)),
              Icon((isOpen ?? false) ? Icons.expand_more : Icons.expand_less)
            ],
          ),
        ));
  }
}
