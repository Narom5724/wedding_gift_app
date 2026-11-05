import 'package:cloud_firestore/cloud_firestore.dart';

String firestoreErrorMessage(Object error, {required String operation}) {
  if (error is FirebaseException) {
    if (error.code == 'failed-precondition' &&
        (error.message ?? '').toLowerCase().contains('index')) {
      final details = error.message;
      return 'This Firestore query needs a composite index. Deploy '
          'firestore.indexes.json, wait for the index to finish building, '
          'then retry.${details == null || details.isEmpty ? '' : '\n$details'}';
    }

    return switch (error.code) {
      'unauthenticated' => 'Please sign in before managing this data.',
      'permission-denied' =>
        'Firestore denied this request. Check that the signed-in user owns '
            'the record and that the published security rules allow this operation.',
      'unavailable' =>
        'Firestore is temporarily unavailable. Check your connection and try again.',
      'failed-precondition' =>
        'Firestore cannot complete this request because a required setup '
            'step is missing. ${error.message ?? ''}',
      'not-found' => 'The requested record could not be found.',
      _ => error.message ?? 'Firestore failed to $operation (${error.code}).',
    };
  }

  if (error is StateError) return error.message;
  return 'Unable to $operation. $error';
}
