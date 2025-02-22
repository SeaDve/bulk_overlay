import 'package:flutter/material.dart';

import 'home_viewmodel.dart';

class Home extends StatelessWidget {
  const Home({super.key, required this.viewModel});

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          spacing: 24,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              spacing: 12,
              children: [
                Expanded(
                  child: TextButton.icon(
                    icon: Icon(Icons.file_copy),
                    label: Text(
                      viewModel.imageFiles.isEmpty
                          ? "Select Image(s)"
                          : "Selected ${viewModel.imageFiles.length} Image(s)",
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                    onPressed: () async {
                      await viewModel.selectImages();
                    },
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    icon: Icon(Icons.file_copy),
                    label: Text(
                      viewModel.overlayImageFile == null
                          ? "Select Overlay Image"
                          : "${viewModel.overlayImageFile.name}",
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                    onPressed: () async {
                      await viewModel.selectOverlayImage();
                    },
                  ),
                ),
                Expanded(child: LinearProgressIndicator(value: 0.0)),
                Expanded(
                  flex: 2,
                  child: TextButton.icon(
                    icon: Icon(Icons.folder),
                    label: Text(
                      viewModel.outputFolder == null
                          ? "Select Output Folder"
                          : "${viewModel.outputFolder}",
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                    onPressed: () async {
                      await viewModel.selectOutputFolder();
                    },
                  ),
                ),
              ],
            ),
            FilledButton.icon(
              onPressed:
                  viewModel.canProcess
                      ? () async {
                        await viewModel.startProcessing();
                      }
                      : null,
              icon: Icon(Icons.play_arrow),
              label: Text(
                "Start Processing",
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
