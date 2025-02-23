import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import 'home_viewmodel.dart';
import 'image_tile.dart';

class Home extends StatelessWidget {
  const Home({super.key, required this.viewModel});

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          spacing: 24,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              spacing: 8,
              children: [
                TextButton.icon(
                  icon: Icon(Icons.file_copy),
                  label: Text(
                    "Add Image(s)",
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                  onPressed: () async {
                    await viewModel.addImages();
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      icon: Icon(Icons.file_copy),
                      label: Text(
                        viewModel.overlayImagePath == null
                            ? "Select Overlay Image"
                            : path.basename(viewModel.overlayImagePath!),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                      onPressed: () async {
                        await viewModel.selectOverlayImage();
                      },
                    ),
                    IconButton(
                      color: Theme.of(context).colorScheme.primary,
                      icon: Icon(Icons.delete),
                      onPressed:
                          viewModel.overlayImagePath != null &&
                                  viewModel.canRemoveImages
                              ? () {
                                viewModel.removeOverlayImage();
                              }
                              : null,
                    ),
                  ],
                ),
              ],
            ),
            Container(
              color: Theme.of(context).colorScheme.secondaryContainer,
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Column(
                spacing: 8,
                children: [
                  Center(
                    child:
                        viewModel.imagePaths.isEmpty
                            ? Text('No image added')
                            : Text(
                              '${viewModel.imagePaths.length} image(s) added',
                            ),
                  ),
                  viewModel.imagePaths.isNotEmpty
                      ? SizedBox(
                        height: 200,
                        child: ListView.builder(
                          restorationId: 'processed_image_list',
                          scrollDirection: Axis.horizontal,
                          itemCount: viewModel.imagePaths.length,
                          itemBuilder: (context, index) {
                            return ImageTile(
                              imageFuture: viewModel.getImageAt(index),
                              onDelete:
                                  viewModel.canRemoveImages
                                      ? () {
                                        viewModel.removeImageAt(index);
                                      }
                                      : null,
                            );
                          },
                        ),
                      )
                      : SizedBox(),
                  TextButton.icon(
                    icon: Icon(Icons.delete),
                    label: Text(
                      "Remove All Image(s)",
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                    onPressed:
                        viewModel.imagePaths.isNotEmpty &&
                                viewModel.canRemoveImages
                            ? () {
                              viewModel.removeAllImages();
                            }
                            : null,
                  ),
                ],
              ),
            ),
            Column(
              spacing: 8,
              children: [
                TextButton.icon(
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
                Builder(
                  builder: (context) {
                    if (viewModel.saveError != null) {
                      return Text(viewModel.saveError!);
                    }

                    if (viewModel.saveProgress != null) {
                      if (viewModel.saveProgress == 1.0) {
                        return Text('Images saved successfully');
                      } else {
                        return SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            value: viewModel.saveProgress,
                          ),
                        );
                      }
                    }

                    return FilledButton.icon(
                      onPressed:
                          viewModel.canSaveImages
                              ? () async {
                                await viewModel.saveImages();
                              }
                              : null,
                      icon: Icon(Icons.save),
                      label: Text(
                        "Save Image(s)",
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
