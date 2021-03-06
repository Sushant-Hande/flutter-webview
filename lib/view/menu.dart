import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum _MenuOptions {
  navigationDelegate,
  listCookies,
  clearCookies,
  addCookie,
  setCookie,
  removeCookie,
  addSessionStorageItem,
}

class Menu extends StatefulWidget {
  const Menu({required this.controller, Key? key}) : super(key: key);

  final Completer<WebViewController> controller;

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  final CookieManager cookieManager = CookieManager();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: widget.controller.future,
      builder: (context, controller) {
        return PopupMenuButton<_MenuOptions>(
          onSelected: (value) async {
            switch (value) {
              case _MenuOptions.navigationDelegate:
                controller.data!.loadUrl('https://youtube.com');
                break;

              case _MenuOptions.addCookie:
                _onAddCookie(controller.data!);
                break;

              case _MenuOptions.setCookie:
                _onSetCookie(controller.data!);
                break;

              case _MenuOptions.removeCookie:
                _onRemoveCookie(controller.data!);
                break;

              case _MenuOptions.clearCookies:
                _onClearCookies();
                break;

              case _MenuOptions.listCookies:
                _onListCookies(controller.data!);
                break;

              case _MenuOptions.addSessionStorageItem:
                _addSessionStorageItem(controller.data!);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.navigationDelegate,
              child: Text('Navigate to YouTube'),
            ),
            const PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.addCookie,
              child: Text('Add Cookie'),
            ),
            const PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.setCookie,
              child: Text('Set Cookie'),
            ),
            const PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.listCookies,
              child: Text('List Cookies'),
            ),
            const PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.addSessionStorageItem,
              child: Text('Add Session Storage Item'),
            ),
            const PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.removeCookie,
              child: Text('Remove Cookie'),
            ),
            const PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.clearCookies,
              child: Text('Clear Cookies'),
            )
          ],
        );
      },
    );
  }

  Future<void> _onAddCookie(WebViewController controller) async {
    await controller.runJavascript('''var date = new Date();
  date.setTime(date.getTime()+(30*24*60*60*1000));
  document.cookie = "FirstName=Sushant; expires=" + date.toGMTString();''');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Custom cookie added.'),
      ),
    );
  }

  Future<void> _onSetCookie(WebViewController controller) async {
    await cookieManager.setCookie(
      const WebViewCookie(name: 'foo', value: 'bar', domain: 'flutter.dev'),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Custom cookie is set.'),
      ),
    );
  }

  Future<void> _onListCookies(WebViewController controller) async {
    final String cookies =
        await controller.runJavascriptReturningResult('document.cookie');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(cookies.isNotEmpty ? cookies : 'There are no cookies.'),
      ),
    );
  }

  Future<void> _onClearCookies() async {
    final hadCookies = await cookieManager.clearCookies();
    String message = 'There were cookies. Now, they are gone!';
    if (!hadCookies) {
      message = 'There were no cookies to clear.';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<void> _onRemoveCookie(WebViewController controller) async {
    await controller.runJavascript(
        'document.cookie="FirstName=Sushant; expires=Thu, 01 Jan 1970 00:00:00 UTC" ');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Custom cookie removed.'),
      ),
    );
  }

  Future<void> _addSessionStorageItem(WebViewController controller) async {
    await controller.runJavascript(
        'sessionStorage.setItem("latitude", "12.956430"); sessionStorage.setItem("longitude", "80.176804")');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Session storage Item added.'),
      ),
    );
  }
}
