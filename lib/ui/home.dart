import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import '../data/image_options.dart';
import '../data/output_config.dart';
import '../data/save_status.dart';
import 'filter_slider.dart';
import 'home_viewmodel.dart';
import 'image_tile.dart';

class Home extends StatelessWidget {
  const Home({super.key, required this.viewModel});

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final saveStatus = viewModel.saveStatus;
    final imageOptions = viewModel.imageOptions;

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
                Row(
                  spacing: 8,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      icon: Icon(Icons.add_a_photo),
                      label: Text(
                        "Add image(s)",
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                      onPressed:
                          viewModel.canModifyConfiguration
                              ? () async => await viewModel.selectImages()
                              : null,
                    ),
                    TextButton.icon(
                      icon: Icon(Icons.delete),
                      label: Text(
                        'Remove ${viewModel.nImages} image(s)',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                      onPressed:
                          viewModel.canModifyConfiguration && viewModel.hasImage
                              ? () => viewModel.removeAllImages()
                              : null,
                    ),
                  ],
                ),
                Row(
                  spacing: 8,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      icon: Icon(Icons.file_open),
                      label: Text(
                        imageOptions.overlayPath == null
                            ? "Select overlay image"
                            : path.basename(imageOptions.overlayPath!),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                      onPressed:
                          viewModel.canModifyConfiguration
                              ? () async => await viewModel.selectOverlayImage()
                              : null,
                    ),
                    TextButton.icon(
                      icon: Icon(Icons.delete),
                      label: Text('Remove overlay'),
                      onPressed:
                          viewModel.canModifyConfiguration &&
                                  imageOptions.overlayPath != null
                              ? () =>
                                  viewModel.imageOptions = imageOptions
                                      .copyWith(overlayPath: null)
                              : null,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Tooltip(
                      message: 'Horizontal offset',
                      child: FilterSlider(
                        icon: Icons.vertical_align_center,
                        divisions: 20,
                        min: -0.5,
                        max: 0.5,
                        label: imageOptions.offset.dy.toStringAsFixed(2),
                        value: imageOptions.offset.dy,
                        onChanged:
                            viewModel.canModifyConfiguration &&
                                    viewModel.hasImage
                                ? (value) =>
                                    viewModel.imageOptions = imageOptions
                                        .copyWith(offset: Offset(0, value))
                                : null,
                        onReset:
                            viewModel.canModifyConfiguration &&
                                    imageOptions.offset !=
                                        ImageOptions.defaultOffset
                                ? () =>
                                    viewModel.imageOptions = imageOptions
                                        .copyWith(
                                          offset: ImageOptions.defaultOffset,
                                        )
                                : null,
                      ),
                    ),
                    Tooltip(
                      message: 'Scale',
                      child: FilterSlider(
                        icon: Icons.zoom_in_map,
                        divisions: 20,
                        min: 0,
                        max: 2,
                        label: imageOptions.scale.toStringAsFixed(1),
                        value: imageOptions.scale,
                        onChanged:
                            viewModel.canModifyConfiguration &&
                                    viewModel.hasImage
                                ? (value) =>
                                    viewModel.imageOptions = imageOptions
                                        .copyWith(scale: value)
                                : null,
                        onReset:
                            viewModel.canModifyConfiguration &&
                                    imageOptions.scale !=
                                        ImageOptions.defaultScale
                                ? () =>
                                    viewModel.imageOptions = imageOptions
                                        .copyWith(
                                          scale: ImageOptions.defaultScale,
                                        )
                                : null,
                      ),
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
                    if (!viewModel.hasImage)
                      Center(child: Text('No image added')),
                    if (viewModel.hasImage)
                      Expanded(
                        child: ListView.builder(
                          restorationId: 'processed_image_list',
                          scrollDirection: Axis.horizontal,
                          itemCount: viewModel.nImages,
                          itemBuilder: (context, index) {
                            final imagePath = viewModel.getImagePathAt(index);
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: ImageTile(
                                imagePath: imagePath!,
                                imageIsSaved: viewModel.isImageSaved(imagePath),
                                imageFuture: viewModel.getImage(imagePath),
                                onRemove:
                                    viewModel.canModifyConfiguration
                                        ? () => viewModel.removeImage(imagePath)
                                        : null,
                              ),
                            );
                          },
                        ),
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
                      enabled: viewModel.canModifyConfiguration,
                      initialSelection: viewModel.outputFormat,
                      dropdownMenuEntries: [
                        for (final format in OutputFormat.values)
                          DropdownMenuEntry(value: format, label: format.name),
                      ],
                      onSelected: (value) {
                        viewModel.outputFormat = value!;
                      },
                    ),
                    if (viewModel.outputFormat == OutputFormat.jpg)
                      DropdownMenu(
                        label: Text('Quality'),
                        enabled: viewModel.canModifyConfiguration,
                        keyboardType: TextInputType.number,
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
                      ),
                  ],
                ),
                TextButton.icon(
                  icon: Icon(Icons.folder_open),
                  label: Text(
                    viewModel.outputFolder == null
                        ? "Select output folder"
                        : "${viewModel.outputFolder}",
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                  onPressed:
                      viewModel.canModifyConfiguration
                          ? () async => await viewModel.selectOutputFolder()
                          : null,
                ),
                FilledButton(
                  onPressed:
                      viewModel.canSaveImages
                          ? () async => await viewModel.saveImages()
                          : null,
                  child: switch (saveStatus) {
                    SaveStatusIdle _ => Text('Save image(s)'),
                    SaveStatusSuccess _ => Text('All imaged saved'),
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
