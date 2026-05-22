import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DetailScreen extends StatefulWidget {
  final String id;
  final String name;
  final double price;
  final String category;
  final String role;

  const DetailScreen({
    super.key,
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.role,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int _days = 1;

  @override
  Widget build(BuildContext context) {
    double totalPrice = widget.price * _days;

    return Scaffold(
      appBar: AppBar(title: Text(widget.name), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              widget.category == 'Skipass'
                  ? Icons.confirmation_number
                  : Icons.snowboarding,
              size: 100,
              color: Colors.blue.shade300,
            ),
            const SizedBox(height: 30),
            Text(
              widget.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.category,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Text(
              "Günlük Fiyat: ${widget.price} TL",
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 30),

            if (widget.role == 'Müşteri') ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.remove_circle,
                      size: 40,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      if (_days > 1) setState(() => _days--);
                    },
                  ),
                  const SizedBox(width: 20),
                  Text(
                    "$_days Gün",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle,
                      size: 40,
                      color: Colors.green,
                    ),
                    onPressed: () => setState(() => _days++),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                "Toplam: $totalPrice TL",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],

            const Spacer(),

            if (widget.role == 'Müşteri')
              ElevatedButton(
                onPressed: () async {
                  final userId = FirebaseAuth.instance.currentUser!.uid;

                  await FirebaseFirestore.instance.collection('rentals').add({
                    'userId': userId,
                    'equipmentId': widget.id,
                    'equipmentName': widget.name,
                    'category': widget.category,
                    'days': _days,
                    'totalPrice': totalPrice,
                    'createdAt': FieldValue.serverTimestamp(),
                  });

                  await FirebaseFirestore.instance.collection('logs').add({
                    'email':
                        FirebaseAuth.instance.currentUser?.email ??
                        'Bilinmiyor',
                    'action': '${widget.name} kiraladı.',
                    'timestamp': FieldValue.serverTimestamp(),
                  });

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Kiralama işlemi başarıyla tamamlandı!"),
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.green,
                ),
                child: Text("$_days Gün İçin Kirala ($totalPrice TL)"),
              ),

            if (widget.role == 'Admin')
              ElevatedButton(
                onPressed: () async {
                  await FirebaseFirestore.instance.collection('logs').add({
                    'email':
                        FirebaseAuth.instance.currentUser?.email ??
                        'Bilinmiyor',
                    'action': '${widget.name} adlı ürünü sildi.',
                    'timestamp': FieldValue.serverTimestamp(),
                  });

                  await FirebaseFirestore.instance
                      .collection('equipments')
                      .doc(widget.id)
                      .delete();

                  if (context.mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.red,
                ),
                child: const Text(
                  "Bu Kaydı Sil",
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
