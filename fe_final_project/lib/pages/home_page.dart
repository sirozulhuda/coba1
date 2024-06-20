import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uangkoo/pages/transaction_page.dart';

class HomePage extends StatefulWidget {
  final DateTime selectedDate;
  const HomePage({Key? key, required this.selectedDate}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> transactions = [];
  List<dynamic> categories = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchTransactions(widget.selectedDate);
    fetchCategories();
  }

  void fetchCategories() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http
          .get(Uri.parse('http://192.168.43.173:3002/api/v2/categories'));
      if (response.statusCode == 200) {
        setState(() {
          categories = json.decode(response.body)['data'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print(e.toString());
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchTransactions(DateTime date) async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http
          .get(Uri.parse('http://192.168.43.173:3002/api/v1/transactions'));
      if (response.statusCode == 200) {
        setState(() {
          transactions = json.decode(response.body)['data'];
          isLoading = false;
        });
        print("Fetched transactions: $transactions");
      } else {
        throw Exception('Failed to load transactions');
      }
    } catch (e) {
      print('Error fetching transactions: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteTransaction(int id) async {
    print("Deleting transaction with id: $id");
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.delete(
          Uri.parse('http://192.168.43.173:3002/api/v1/transactions/$id'));
      if (response.statusCode == 200) {
        await fetchTransactions(widget.selectedDate);
      } else {
        throw Exception('Failed to delete transaction');
      }
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void openEditDialog(dynamic transaction) {
    TextEditingController amountController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    amountController.text = transaction['amount'].toString();
    descriptionController.text = transaction['description'] ?? '';

    int? selectedCategory = transaction['category_id'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Transaksi'),
              SizedBox(height: 10),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Jumlah',
                ),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<int>(
                value: selectedCategory,
                hint: Text('Pilih Kategori'),
                items: categories.map<DropdownMenuItem<int>>((category) {
                  return DropdownMenuItem<int>(
                    value: category['id'],
                    child: Text(category['name']),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    selectedCategory = newValue;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Kategori',
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  hintText: 'Deskripsi',
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                updateTransaction({
                  'id': transaction['id'],
                  'amount': amountController.text,
                  'category_id': selectedCategory,
                  'description': descriptionController.text,
                });
                Navigator.of(context).pop();
              },
              child: Text('Simpan'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateTransaction(Map<String, dynamic> transactionData) async {
    final id = transactionData['id'];
    final int index = transactions.indexWhere((t) => t['id'] == id);

    if (index != -1) {
      setState(() {
        transactions[index] = transactionData;
      });
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Updating Transaction'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Please wait...'),
            ],
          ),
        );
      },
    );

    try {
      final response = await http.put(
        Uri.parse('http://192.168.43.173:3002/api/v1/transactions/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(transactionData),
      );

      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        print('Transaction updated successfully');
        await fetchTransactions(widget.selectedDate);
      } else {
        throw Exception('Failed to update transaction');
      }
    } catch (e) {
      Navigator.of(context).pop();
      print('Error updating transaction: $e');

      if (index != -1) {
        setState(() {
          transactions[index] = transactions[index];
        });
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to update transaction. Please try again.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daftar Transaksi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () => fetchTransactions(widget.selectedDate),
              child: transactions.isEmpty
                  ? Center(
                      child: Text('Tidak ada transaksi'),
                    )
                  : ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        return Card(
                          margin:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            leading: Icon(
                              transaction['isExpense'] == 1
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: transaction['isExpense'] == 1
                                  ? Colors.red
                                  : Colors.green,
                            ),
                            title: Text(
                              'Rp ${transaction['amount']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(transaction['category_name'] ?? ''),
                                SizedBox(height: 5),
                                Text(transaction['description'] ?? ''),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    openEditDialog(transaction);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () =>
                                      _deleteTransaction(transaction['id']),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
