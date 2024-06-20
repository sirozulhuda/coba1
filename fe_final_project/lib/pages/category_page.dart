import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CategoryPage extends StatefulWidget {
  const CategoryPage({Key? key}) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  bool isExpense = true;
  List categories = [];
  List filteredCategories = [];

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  void fetchCategories() async {
    try {
      final response = await http
          .get(Uri.parse('http://192.168.43.173:3002/api/v2/categories'));
      if (response.statusCode == 200) {
        setState(() {
          categories = json.decode(response.body)['data'];
          filterCategories();
        });
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print(e.toString());
      // Handle error gracefully
    }
  }

  void filterCategories() {
    setState(() {
      filteredCategories = categories
          .where((category) => category['isExpense'] == (isExpense ? 1 : 0))
          .toList();
    });
  }

  void openDialog(dynamic category) {
    TextEditingController categoryNameController = TextEditingController();
    bool isExpenseDialog = isExpense; // Use a local variable for dialog state
    if (category != null) {
      categoryNameController.text = category['name'];
      isExpenseDialog =
          category['isExpense'] == 1; // Check if category is expense
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              title: TextField(
                controller: categoryNameController,
                decoration: InputDecoration(hintText: "Nama Kategori"),
              ),
              actions: <Widget>[
                ElevatedButton(
                  child: Text("Simpan"),
                  onPressed: () {
                    if (category == null) {
                      createCategory(
                          categoryNameController.text, isExpenseDialog);
                    } else {
                      updateCategory(category['id'],
                          categoryNameController.text, isExpenseDialog);
                    }
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text("Batal"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void createCategory(String name, bool isExpense) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.43.173:3002/api/v2/categories'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'isExpense': isExpense}),
      );

      if (response.statusCode == 201) {
        fetchCategories();
      } else {
        throw Exception('Failed to create category');
      }
    } catch (e) {
      print(e.toString());
      // Handle error gracefully
    }
  }

  void updateCategory(int id, String name, bool isExpense) async {
    try {
      final response = await http.put(
        Uri.parse('http://192.168.43.173:3002/api/v2/categories/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'isExpense': isExpense}),
      );

      if (response.statusCode == 200) {
        fetchCategories();
      } else {
        throw Exception('Failed to update category');
      }
    } catch (e) {
      print(e.toString());
      // Handle error gracefully
    }
  }

  void deleteCategory(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://192.168.43.173:3002/api/v2/categories/$id'),
      );

      if (response.statusCode == 200) {
        fetchCategories();
      } else {
        throw Exception('Failed to delete category');
      }
    } catch (e) {
      print(e.toString());
      // Handle error gracefully
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kategori"),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Switch(
                value: isExpense,
                inactiveTrackColor: Colors.green[200],
                inactiveThumbColor: Colors.green,
                activeColor: Colors.red,
                onChanged: (bool value) {
                  setState(() {
                    isExpense = value;
                    filterCategories(); // Filter categories based on switch
                  });
                },
              ),
              Text(
                isExpense ? "Pengeluaran" : "Pemasukan",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Expanded(
            child: filteredCategories.isEmpty
                ? Center(
                    child:
                        CircularProgressIndicator()) // Show a loading indicator
                : ListView.builder(
                    itemCount: filteredCategories.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Card(
                          elevation: 10,
                          child: ListTile(
                            title: Text(filteredCategories[index]['name']),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    openDialog(filteredCategories[index]);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    deleteCategory(
                                        filteredCategories[index]['id']);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          openDialog(null);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
