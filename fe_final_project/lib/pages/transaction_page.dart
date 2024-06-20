import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TransactionPage extends StatefulWidget {
  final DateTime date;
  final Map<String, dynamic>? transaction; // Add transaction parameter
  const TransactionPage({Key? key, required this.date, this.transaction})
      : super(key: key);

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  TextEditingController amountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  dynamic selectedCategory;
  List<DropdownMenuItem<dynamic>> categoryItems = [];
  List<dynamic> categories = [];
  List<dynamic> transactions = [];
  List<dynamic> filteredTransactions = [];
  bool isExpense = true;

  @override
  void initState() {
    super.initState();
    dateController.text =
        DateFormat('yyyy-MM-dd').format(widget.date); // Set initial date
    fetchCategories();
  }

  void fetchCategories() async {
    try {
      final response = await http
          .get(Uri.parse('http://192.168.43.173:3002/api/v2/categories'));
      if (response.statusCode == 200) {
        List<dynamic> categoriesData = json.decode(response.body)['data'];
        setState(() {
          categories = categoriesData;
          selectedCategory =
              categoriesData.isNotEmpty ? categoriesData[0] : null;
          categoryItems =
              categoriesData.map<DropdownMenuItem<dynamic>>((category) {
            return DropdownMenuItem<dynamic>(
              value: category,
              child: Text(category['name']),
            );
          }).toList();
          filterCategories(); // Initial category filter
        });
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  void filterCategories() {
    List<dynamic> filteredCategories = categories.where((category) {
      return category['isExpense'] == (isExpense ? 1 : 0);
    }).toList();
    setState(() {
      categoryItems =
          filteredCategories.map<DropdownMenuItem<dynamic>>((category) {
        return DropdownMenuItem<dynamic>(
          value: category,
          child: Text(category['name']),
        );
      }).toList();
      if (!filteredCategories.contains(selectedCategory)) {
        selectedCategory =
            filteredCategories.isNotEmpty ? filteredCategories[0] : null;
      }
    });
    filterTransactions(); // Update filtered transactions based on new category filter
  }

  void filterTransactions() {
    setState(() {
      filteredTransactions = transactions.where((transaction) {
        return transaction['isExpense'] == (isExpense ? 1 : 0);
      }).toList();
    });
  }

  void createTransaction() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.43.173:3002/api/v1/transactions'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'amount': double.tryParse(amountController.text) ?? 0,
          'category_id':
              selectedCategory != null ? selectedCategory['id'] : null,
          'transaction_date': dateController.text,
          'description': descriptionController.text,
          'isExpense': isExpense ? 1 : 0,
        }),
      );

      if (response.statusCode == 201) {
        final newTransaction = await json.decode(response.body)['data'];
        Navigator.of(context)
            .pop(newTransaction); // Kembalikan transaksi baru ke HomePage
      } else {
        print(
            'Failed to create transaction with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Failed to create transaction'),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('Error: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to create transaction: $e'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tambah Transaksi")),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 10),
                  Switch(
                    value: isExpense,
                    inactiveTrackColor: Colors.green[200],
                    inactiveThumbColor: Colors.green,
                    activeColor: Colors.red,
                    onChanged: (bool value) {
                      setState(() {
                        isExpense = value;
                        filterCategories(); // Update categories based on switch
                        filterTransactions();
                      });
                    },
                  ),
                  Text(
                    isExpense ? "Pengeluaran" : "Pemasukan",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Jumlah',
                  ),
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Kategori",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButton<dynamic>(
                  isExpanded: true,
                  value: selectedCategory,
                  icon: const Icon(Icons.arrow_downward),
                  elevation: 16,
                  onChanged: (dynamic newValue) {
                    setState(() {
                      selectedCategory = newValue;
                    });
                  },
                  items: categoryItems,
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Deskripsi',
                  ),
                ),
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    createTransaction();
                  },
                  child: Text('Simpan'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
