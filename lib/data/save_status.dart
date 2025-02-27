sealed class SaveStatus {}

class SaveStatusIdle extends SaveStatus {}

class SaveStatusInProgress extends SaveStatus {
  SaveStatusInProgress(this.progress);

  final double progress;
}

class SaveStatusSuccess extends SaveStatus {}

class SaveStatusFailure extends SaveStatus {
  SaveStatusFailure(this.error);

  final String error;
}
