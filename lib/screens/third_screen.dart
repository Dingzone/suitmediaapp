import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ThirdScreen extends StatefulWidget {
  @override
  _ThirdScreenState createState() => _ThirdScreenState();
}

class _ThirdScreenState extends State<ThirdScreen> {
  List users = [];
  int page = 1;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
    });
    final response = await http.get(
      Uri.parse('https://reqres.in/api/users?page=$page&per_page=10'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        users.addAll(data['data']);
        page++;
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      users.clear();
      page = 1;
    });
    await fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          'Third Screen',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: users.isEmpty
          ? Center(child: Text('No users found'))
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView.builder(
                itemCount: users.length + 1,
                itemBuilder: (context, index) {
                  if (index == users.length) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: isLoading
                            ? CircularProgressIndicator()
                            : SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: fetchUsers,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF2b637b),
                                    padding:
                                        EdgeInsets.symmetric(vertical: 15.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  child: Text(
                                    'Load More',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                      ),
                    );
                  }
                  final user = users[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(user['avatar']),
                    ),
                    title: Text('${user['first_name']} ${user['last_name']}'),
                    subtitle: Text(user['email']),
                    onTap: () {
                      Navigator.pop(context,
                          '${user['first_name']} ${user['last_name']}');
                    },
                  );
                },
              ),
            ),
    );
  }
}
