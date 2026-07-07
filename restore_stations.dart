import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:washify/firebase_options.dart';

void main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final firestore = FirebaseFirestore.instance;
  
  final snapshot = await firestore.collection('stations').where('isActive', isEqualTo: false).get();
  
  for (var doc in snapshot.docs) {
    await doc.reference.update({'isActive': true});
    print('Restored station: ${doc.id}');
  }
  print('Done!');
}
