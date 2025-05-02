import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_space_shooter/screens/menu_screen.dart';

// Thay đổi trong hàm main để bắt đầu với MainMenuScreen
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Thiết lập hướng màn hình chỉ cho phép dọc
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((
    _,
  ) {
    runApp(
      MaterialApp(
        title: 'Space Shooter',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const MainMenuScreen(), // Thay đổi ở đây để start từ menu
      ),
    );
  });
}
