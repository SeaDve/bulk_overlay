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
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
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
                    "Add image(s)",
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                  onPressed: () async {
                    await viewModel.selectImages();
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      icon: Icon(Icons.file_copy),
                      label: Text(
                        viewModel.overlayImagePath == null
                            ? "Select overlay image"
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
                                viewModel.setOverlayImagePath(null);
                              }
                              : null,
                    ),
                  ],
                ),
              ],
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.secondaryContainer,
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  spacing: 8,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                        ? Expanded(
                          child: SizedBox(
                            height: 120,
                            child: ListView.builder(
                              restorationId: 'processed_image_list',
                              scrollDirection: Axis.horizontal,
                              itemCount: viewModel.imagePaths.length,
                              itemBuilder: (context, index) {
                                final imagePath = viewModel.getImagePathAt(
                                  index,
                                );
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4.0,
                                  ),
                                  child: ImageTile(
                                    imagePath: imagePath!,
                                    imageFuture: viewModel.getImage(imagePath),
                                    onRemove:
                                        viewModel.canRemoveImages
                                            ? () {
                                              viewModel.removeImage(imagePath);
                                            }
                                            : null,
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                        : SizedBox(),
                    TextButton.icon(
                      icon: Icon(Icons.delete),
                      label: Text(
                        "Remove all image(s)",
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
            ),
            Column(
              spacing: 8,
              children: [
                TextButton.icon(
                  icon: Icon(Icons.folder),
                  label: Text(
                    viewModel.outputFolder == null
                        ? "Select output folder"
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
                          width: 24,
                          height: 24,
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
                        "Save image(s)",
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
