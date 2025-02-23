import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class ImageTile extends StatefulWidget {
  const ImageTile({
    super.key,
    required this.imageFuture,
    required this.onDelete,
  });

  final Future<ui.Image?> imageFuture;

  final VoidCallback? onDelete;

  @override
  State<ImageTile> createState() => _ImageTileState();
}

class _ImageTileState extends State<ImageTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
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
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Error: ${snapshot.error}'),
                      ),
                    );
                  }

                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              Positioned.directional(
                end: 8,
                top: 8,
                textDirection: TextDirection.ltr,
                child: AnimatedOpacity(
                  opacity: _isHovered ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 200),
                  child: IconButton.filled(
                    icon: Icon(Icons.delete),
                    onPressed: widget.onDelete,
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
