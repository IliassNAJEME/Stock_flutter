import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreTenantService {
  FirestoreTenantService(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> categories(String clientId) {
    return _firestore.collection('clients').doc(clientId).collection('categories');
  }

  CollectionReference<Map<String, dynamic>> products(String clientId) {
    return _firestore.collection('clients').doc(clientId).collection('products');
  }

  CollectionReference<Map<String, dynamic>> movements(String clientId) {
    return _firestore.collection('clients').doc(clientId).collection('movements');
  }
}
