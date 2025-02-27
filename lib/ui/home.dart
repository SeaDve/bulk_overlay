import 'package:bulk_overlay/data/save_status.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import '../data/output_config.dart';
import 'home_viewmodel.dart';
import 'image_tile.dart';

class Home extends StatelessWidget {
  const Home({super.key, required this.viewModel});

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final saveStatus = viewModel.saveStatus;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48.0),
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
                  spacing: 8,
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
                                viewModel.overlayImagePath = null;
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
                          viewModel.hasImage
                              ? Text('${viewModel.nImages} image(s) added')
                              : Text('No image added'),
                    ),
                    viewModel.hasImage
                        ? Expanded(
                          child: SizedBox(
                            height: 120,
                            child: ListView.builder(
                              restorationId: 'processed_image_list',
                              scrollDirection: Axis.horizontal,
                              itemCount: viewModel.nImages,
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
                          viewModel.hasImage && viewModel.canRemoveImages
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
                Row(
                  spacing: 8,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DropdownMenu(
                      label: Text('Format'),
                      initialSelection: viewModel.outputFormat,
                      dropdownMenuEntries: [
                        for (final format in OutputFormat.values)
                          DropdownMenuEntry(value: format, label: format.name),
                      ],
                      onSelected: (value) {
                        viewModel.outputFormat = value!;
                      },
                    ),
                    viewModel.outputFormat == OutputFormat.jpg
                        ? DropdownMenu(
                          label: Text('Quality'),
                          initialSelection: viewModel.jpgOutputQuality,
                          dropdownMenuEntries: [
                            for (int quality = 0; quality <= 100; quality++)
                              DropdownMenuEntry(
                                value: quality,
                                label: quality.toString(),
                              ),
                          ],
                          onSelected: (value) {
                            viewModel.jpgOutputQuality = value!;
                          },
                        )
                        : SizedBox(),
                  ],
                ),
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
                FilledButton(
                  onPressed:
                      viewModel.canSaveImages
                          ? () async {
                            await viewModel.saveImages();
                          }
                          : null,
                  child: switch (saveStatus) {
                    SaveStatusIdle _ => Text('Save image(s)'),
                    SaveStatusSuccess _ => Text('Done'),
                    SaveStatusFailure _ => Text(saveStatus.error),
                    SaveStatusInProgress _ => SizedBox(
                      width: 24,
                      height: 24,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: CircularProgressIndicator(
                          value: saveStatus.progress,
                        ),
                      ),
                    ),
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
