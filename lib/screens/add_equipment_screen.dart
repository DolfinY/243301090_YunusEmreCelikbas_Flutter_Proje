import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddEquipmentScreen extends StatefulWidget {
  const AddEquipmentScreen({super.key});

  @override
  State<AddEquipmentScreen> createState() => _AddEquipmentScreenState();
}

class _AddEquipmentScreenState extends State<AddEquipmentScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String _selectedCategory = 'Ekipman';
  String _selectedSubCategory = 'Mont';

  final List<String> _subCategories = [
    'Mont',
    'Kask',
    'Snowboard',
    'Kayak Takımı',
    'Gözlük',
    'Diğer',
  ];

  void _saveData() async {
    String name = _nameController.text.trim();
    String price = _priceController.text.trim();

    if (name.isNotEmpty && price.isNotEmpty) {
      await FirebaseFirestore.instance.collection('equipments').add({
        'name': name,
        'price': double.tryParse(price) ?? 0.0,
        'category': _selectedCategory,
        'subCategory': _selectedCategory == 'Ekipman'
            ? _selectedSubCategory
            : null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen tüm alanları doldurun.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Yeni Kayıt Ekle"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Kategori",
              ),
              items: ['Ekipman', 'Skipass'].map((String category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedCategory = val!;
                });
              },
            ),
            const SizedBox(height: 15),

            if (_selectedCategory == 'Ekipman') ...[
              DropdownButtonFormField<String>(
                value: _selectedSubCategory,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Ekipman Türü",
                ),
                items: _subCategories.map((String sub) {
                  return DropdownMenuItem(value: sub, child: Text(sub));
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedSubCategory = val!;
                  });
                },
              ),
              const SizedBox(height: 15),
            ],

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Adı (Örn: Pro Snowboard)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: "Günlük Fiyat (TL)",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _saveData,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Kaydet"),
            ),
          ],
        ),
      ),
    );
  }
}
