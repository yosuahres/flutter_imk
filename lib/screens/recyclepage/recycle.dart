import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fp_imk/db/firestore.dart';


class RecycleScreen extends StatefulWidget {
  const RecycleScreen({ Key? key }) : super(key: key);

  @override
  _RecycleState createState() => _RecycleState();
}

class _RecycleState extends State<RecycleScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recycle'),
        backgroundColor: const Color(0xFF609966), 
      ),
    );
  }
}