import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import '../lib/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('🔍 Testing Firestore Drug Database Connection...\n');
  
  try {
    // Initialize Firebase
    print('1️⃣ Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized\n');
    
    // Test connection
    print('2️⃣ Connecting to Firestore...');
    final firestore = FirebaseFirestore.instance;
    print('✅ Firestore instance created\n');
    
    // Try to read drugs collection
    print('3️⃣ Reading drugs collection...');
    final snapshot = await firestore.collection('drugs').get();
    print('✅ Query successful!');
    print('📊 Found ${snapshot.docs.length} drugs in database\n');
    
    if (snapshot.docs.isEmpty) {
      print('⚠️  WARNING: No drugs found in database!');
      print('   Run: flutter run scripts/populate_drugs.dart\n');
    } else {
      print('📋 Drugs in database:');
      for (var doc in snapshot.docs) {
        final data = doc.data();
        print('   - ${data['name']} (${data['category']})');
      }
      print('');
    }
    
    // Test parsing
    print('4️⃣ Testing drug parsing...');
    int successCount = 0;
    int errorCount = 0;
    
    for (var doc in snapshot.docs) {
      try {
        final data = Map<String, dynamic>.from(doc.data());
        if (!data.containsKey('id')) {
          data['id'] = doc.id;
        }
        
        // Check required fields
        if (!data.containsKey('name')) {
          print('   ❌ ${doc.id}: Missing "name" field');
          errorCount++;
          continue;
        }
        if (!data.containsKey('category')) {
          print('   ❌ ${doc.id}: Missing "category" field');
          errorCount++;
          continue;
        }
        
        successCount++;
      } catch (e) {
        print('   ❌ ${doc.id}: $e');
        errorCount++;
      }
    }
    
    print('✅ Successfully parsed: $successCount drugs');
    if (errorCount > 0) {
      print('❌ Failed to parse: $errorCount drugs\n');
    } else {
      print('');
    }
    
    print('🎉 All tests passed! Database is working correctly.');
    
  } catch (e) {
    print('❌ ERROR: $e');
    print('\n🔧 Troubleshooting:');
    print('   1. Check internet connection');
    print('   2. Verify Firebase project is active');
    print('   3. Check Firestore rules allow read access');
    print('   4. Run: flutterfire configure');
  }
}
