/// Completes a retained read only for the still-current owner and generation.
Future<void> retainedRead<T>({
  required Future<T> Function() request,
  required bool Function() isCurrent,
  required void Function(T) onSuccess,
  required void Function() onFailure,
}) async {
  try {
    final value = await request();
    if (isCurrent()) onSuccess(value);
  } catch (_) {
    if (isCurrent()) onFailure();
  }
}
