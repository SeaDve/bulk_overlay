import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'data/image_repository.dart';
import 'ui/home.dart';
import 'ui/home_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    size: Size(800, 600),
    title: "Bulk Overlay",
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setMinimumSize(Size(360, 294));
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (context) => ImageRepository()),
        ChangeNotifierProvider(
          create: (context) => HomeViewModel(imageRepository: context.read()),
        ),
      ],
      child: MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          return Home(viewModel: viewModel);
        },
      ),
    );
  }
}
