sealed class OutputConfig {
  abstract final OutputFormat format;
}

class JpgOutputConfig extends OutputConfig {
  @override
  final format = OutputFormat.jpg;

  final int quality;

  JpgOutputConfig({required this.quality});
}

class PngOutputConfig extends OutputConfig {
  @override
  final format = OutputFormat.png;
}

enum OutputFormat {
  png(name: 'PNG', extension: '.png'),
  jpg(name: 'JPG', extension: '.jpg');

  final String name;
  final String extension;

  const OutputFormat({required this.name, required this.extension});
}
