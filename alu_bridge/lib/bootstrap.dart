import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'app.dart';
import 'features/auth/data/auth_repository.dart';
import 'firebase_options.dart';

final sl = GetIt.instance;

void bootstrap() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      sl.registerLazySingleton(() => FirebaseAuth.instance);
      sl.registerLazySingleton(() => FirebaseFirestore.instance);
      sl.registerLazySingleton(
        () => AuthRepository(auth: sl(), firestore: sl()),
      );

      runApp(const AluBridgeApp());
    },
    (error, stack) => debugPrint('Uncaught error: $error\n$stack'),
  );
}
