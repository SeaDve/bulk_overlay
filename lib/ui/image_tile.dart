import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class ImageTile extends StatefulWidget {
  const ImageTile({
    super.key,
    required this.imagePath,
    required this.imageIsSaved,
    required this.imageFuture,
    required this.onRemove,
  });

  final String imagePath;
  final bool imageIsSaved;
  final Future<ui.Image?> imageFuture;

  final VoidCallback? onRemove;

  @override
  State<ImageTile> createState() => _ImageTileState();
}

class _ImageTileState extends State<ImageTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.imagePath,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: Stack(
            children: [
              FutureBuilder(
                future: widget.imageFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return RawImage(image: snapshot.data);
                  }

                  if (snapshot.hasError) {
                    return Container(
                      padding: EdgeInsets.all(8.0),
                      alignment: Alignment.center,
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  return Center(
                    child: Container(
                      width: 240,
                      height: 80,
                      padding: const EdgeInsets.all(12.0),
                      alignment: Alignment.center,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                },
              ),
              if (widget.imageIsSaved)
                Positioned(
                  top: 4,
                  left: 4,
                  child: Card(
                    child: Icon(Icons.check_circle, color: Colors.green),
                  ),
                ),
              Positioned(
                right: 8,
                bottom: 8,
                child: AnimatedOpacity(
                  opacity: _isHovered ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 200),
                  child: IconButton.filled(
                    icon: Icon(Icons.delete),
                    onPressed: widget.onRemove,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
