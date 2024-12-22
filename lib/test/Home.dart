import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mechinetest/main.dart';
import 'package:mechinetest/test/drawer.dart';

class Home extends StatefulWidget {
  final String userId;

  const Home({super.key, required this.userId});

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final ageController = TextEditingController();
  final searchController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String userName = '';

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    ageController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadUsers();
    fetchUserName();
  }

  Future<void> loadUsers() async {
    final userCollection = FirebaseFirestore.instance.collection('users').doc(widget.userId).collection('userData');
    final querySnapshot = await userCollection.get();
    final userList = querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
    setState(() {
      users = userList.cast<Map<String, dynamic>>();
      filteredUsers = users;
    });
  }

  Future<void> fetchUserName() async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
    setState(() {
      userName = userDoc.data()?['name'] ?? 'User';
    });
  }

  Future<void> addUser() async {
    if (formKey.currentState!.validate()) {
      String name = nameController.text;
      String phoneNumber = phoneController.text;
      int age = int.tryParse(ageController.text) ?? 0;
      final userCollection = FirebaseFirestore.instance.collection('users').doc(widget.userId).collection('userData');
      final newUser = {
        'name': name,
        'phoneNumber': phoneNumber,
        'age': age,
      };
      final docRef = await userCollection.add(newUser);
      newUser['id'] = docRef.id;
      setState(() {
        users.add(newUser);
        filteredUsers = users;
      });
      nameController.clear();
      phoneController.clear();
      ageController.clear();
    }
  }

  Future<void> deleteUser(String id) async {
    final userCollection = FirebaseFirestore.instance.collection('users').doc(widget.userId).collection('userData');
    await userCollection.doc(id).delete();
    setState(() {
      users.removeWhere((user) => user['id'] == id);
      filteredUsers = users;
    });
  }

  void searchUser(String query) {
    setState(() {
      filteredUsers = users.where((user) {
        return user['name'].toLowerCase().contains(query.toLowerCase()) || user['phoneNumber'].contains(query);
      }).toList();
    });
  }

  void sortUsersByAge() {
    setState(() {
      filteredUsers.sort((a, b) => a['age'].compareTo(b['age']));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(),
      appBar: AppBar(
        title: Text('$userName',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22),), // Display user name in AppBar title
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: formKey,
              child: Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2)),
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'Name',
                        hintStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 2.0,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 5.h),
                    TextFormField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        hintText: 'Phone NO',
                        hintStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 2.0,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a phone number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 5.h),
                    TextFormField(
                      controller: ageController,
                      decoration: InputDecoration(
                        hintText: 'Age',
                        hintStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 2.0,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: addUser,
                      child: Text(
                        'Add User',
                        style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.h),
            TextFormField(
              controller: searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search by name or phone No',
                hintStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(
                    color: Colors.black,
                    width: 2.0,
                  ),
                ),
              ),
              onChanged: searchUser,
            ),
            SizedBox(height: 5),
            ElevatedButton(
              onPressed: sortUsersByAge,
              child: Text(
                'Sort by Age',
                style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return Card(
                    margin: EdgeInsets.all(8.0),
                    elevation: 4.0,
                    child: ListTile(
                      title: Text('${user['name']} (${user['age']})'),
                      subtitle: Text(user['phoneNumber']),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          deleteUser(user['id']);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
