import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'add_equipment_screen.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  String userRole = 'Müşteri';

  String _selectedFilter = 'Tümü';
  final List<String> _filters = [
    'Tümü',
    'Mont',
    'Kask',
    'Snowboard',
    'Kayak Takımı',
    'Gözlük',
    'Diğer',
  ];

  @override
  void initState() {
    super.initState();
    _getUserRole();
  }

  Future<void> _getUserRole() async {
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          userRole = userDoc['role'] ?? 'Müşteri';
        });
      }
    }
  }

  Widget _buildListItem(DocumentSnapshot item, String category) {
    Map<String, dynamic> dataMap = item.data() as Map<String, dynamic>;
    String subCategory =
        dataMap.containsKey('subCategory') && dataMap['subCategory'] != null
        ? dataMap['subCategory']
        : category;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: Icon(
          category == 'Skipass'
              ? Icons.confirmation_number
              : Icons.snowboarding,
          color: Colors.blue,
        ),
        title: Text(
          item['name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("$subCategory - ${item['price']} TL/Gün"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailScreen(
                id: item.id,
                name: item['name'],
                price: item['price'].toDouble(),
                category: category,
                role: userRole,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Kayak Merkezi"),
          actions: [
            IconButton(icon: const Icon(Icons.person), onPressed: () {}),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async => await _authService.signOut(),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.snowboarding), text: "Ekipmanlar"),
              Tab(icon: Icon(Icons.confirmation_number), text: "Skipass"),
            ],
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('equipments')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError)
              return const Center(child: Text("Bir hata oluştu."));
            if (snapshot.connectionState == ConnectionState.waiting)
              return const Center(child: CircularProgressIndicator());

            final allDocs = snapshot.requireData.docs;

            var skipassDocs = allDocs
                .where(
                  (d) =>
                      (d.data() as Map<String, dynamic>)['category'] ==
                      'Skipass',
                )
                .toList();
            var equipDocs = allDocs.where((d) {
              var map = d.data() as Map<String, dynamic>;
              return !map.containsKey('category') ||
                  map['category'] == 'Ekipman';
            }).toList();

            if (_selectedFilter != 'Tümü') {
              equipDocs = equipDocs.where((d) {
                var map = d.data() as Map<String, dynamic>;
                return map['subCategory'] == _selectedFilter;
              }).toList();
            }

            return TabBarView(
              children: [
                Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: Row(
                        children: _filters.map((filter) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(filter),
                              selected: _selectedFilter == filter,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedFilter = filter;
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    Expanded(
                      child: equipDocs.isEmpty
                          ? const Center(
                              child: Text("Bu kategoride ekipman bulunamadı."),
                            )
                          : ListView.builder(
                              itemCount: equipDocs.length,
                              itemBuilder: (context, index) =>
                                  _buildListItem(equipDocs[index], 'Ekipman'),
                            ),
                    ),
                  ],
                ),

                skipassDocs.isEmpty
                    ? const Center(child: Text("Henüz Skipass eklenmemiş."))
                    : ListView.builder(
                        itemCount: skipassDocs.length,
                        itemBuilder: (context, index) =>
                            _buildListItem(skipassDocs[index], 'Skipass'),
                      ),
              ],
            );
          },
        ),

        floatingActionButton: userRole == 'Admin'
            ? FloatingActionButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddEquipmentScreen(),
                  ),
                ),
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }
}
