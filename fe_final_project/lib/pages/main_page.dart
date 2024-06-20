import 'package:flutter/material.dart';
import 'home_page.dart';
import 'category_page.dart';
import 'transaction_page.dart';
import 'account_page.dart';
import 'package:calendar_appbar/calendar_appbar.dart';

class MainPage extends StatefulWidget {
  final DateTime selectedDate;
  const MainPage({Key? key, required this.selectedDate}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  DateTime _selectedDate = DateTime.now();

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _pages = [
      HomePage(selectedDate: _selectedDate),
      CategoryPage(),
      Container(), // Placeholder for the TransactionPage
      AccountPage(),
    ];
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TransactionPage(date: _selectedDate),
        ),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CalendarAppBar(
        onDateChanged: (value) {
          setState(() {
            _selectedDate = value;
            _pages[0] = HomePage(selectedDate: _selectedDate);
          });
        },
        firstDate: DateTime.now().subtract(Duration(days: 140)),
        lastDate: DateTime.now(),
        accent: Colors.blue.shade700,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Kategori',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Tambah Transaksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Akun',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}
