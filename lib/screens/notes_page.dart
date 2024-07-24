import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:test_lan1111/models/note.dart';
import 'package:test_lan1111/services/api_service.dart';
import 'package:test_lan1111/screens/note_page_inp.dart'; // Import NotePage_inp
import 'package:test_lan1111/screens/NoteDetailPage.dart';

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> with SingleTickerProviderStateMixin {
  List<Note> notes = [];
  Map<String, Map<String, List<Note>>> dailyNotes = {};
  Map<String, Map<String, int>> dailyIncome = {};
  Map<String, Map<String, int>> dailyExpense = {};
  Map<String, Map<String, List<Note>>> notesByProductType = {}; // Thêm dòng này
  Map<String, Map<String, int>> productTypeIncome = {}; // Thêm dòng này
  Map<String, Map<String, int>> productTypeExpense = {}; // Thêm dòng này
  String? errorMessage;
  final ApiServicein apiServicein = ApiServicein();
  int totalIncome = 0;
  int totalExpense = 0;
  List<String> months = [];
  int _currentIndex = 0;
  String _selectedMonth = ''; // Add this line
  TabController? _tabController;
  bool _groupByProductType = false; // Thêm dòng này
  String _selectedProductType = 'Tất cả'; // Thêm dòng này

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void dispose() {
    _tabController?.dispose(); // Ensure _tabController is not null
    super.dispose();
  }

  Future<void> _loadNotes() async {
    try {
      var notesList = await apiServicein.fetchNotes();
      setState(() {
        notes = notesList;
        _calculateTotals();
        _groupNotesByMonthAndDay();
        _selectedMonth = months.isNotEmpty ? months[0] : ''; // Initialize selected month
        _tabController = TabController(length: months.length, vsync: this);
        _tabController!.addListener(_handleTabSelection);
        _updateMonthlyTotals(); // Update totals after initializing tab controller
      });
    } catch (e) {
      setState(() {
        errorMessage = "Lỗi khi lấy ghi chú: $e";
      });
    }
  }

  void _handleTabSelection() {
    if (!_tabController!.indexIsChanging) {
      setState(() {
        _selectedMonth = months[_tabController!.index];
        _updateMonthlyTotals();
      });
    }
  }

  void _calculateTotals() {
    int income = 0;
    int expense = 0;

    for (var note in notes) {
      if (note.processedData != null) {
        for (var data in note.processedData!) {
          if (data['Loại phương thức thanh toán'] == 'Thu') {
            income += (data['Số tiền'] as num).toInt();
          } else if (data['Loại phương thức thanh toán'] == 'Chi') {
            expense += (data['Số tiền'] as num).toInt();
          }
        }
      }
    }

    totalIncome = income;
    totalExpense = expense;
  }

  void _groupNotesByMonthAndDay() {
    Map<String, Map<String, List<Note>>> groupedNotesByDay = {};
    Map<String, Map<String, int>> incomeMapByDay = {};
    Map<String, Map<String, int>> expenseMapByDay = {};

    Map<String, Map<String, List<Note>>> groupedNotesByProductType = {};
    Map<String, Map<String, int>> incomeMapByProductType = {};
    Map<String, Map<String, int>> expenseMapByProductType = {};

    for (var note in notes) {
      if (note.timestamp != null && note.timestamp!.isNotEmpty) {
        DateTime dateTime = DateFormat('EEE, dd MMM yyyy HH:mm:ss zzz').parse(note.timestamp!);
        String monthKey = DateFormat('MMMM yyyy', 'vi').format(dateTime); // Use Vietnamese locale for month names
        String dayKey = DateFormat('dd/MM/yyyy').format(dateTime);
        String productTypeKey = note.processedData?.first['Loại sản phẩm']?.toLowerCase() ?? 'khác';

        if (!groupedNotesByDay.containsKey(monthKey)) {
          groupedNotesByDay[monthKey] = {};
          incomeMapByDay[monthKey] = {};
          expenseMapByDay[monthKey] = {};
          groupedNotesByProductType[monthKey] = {};
          incomeMapByProductType[monthKey] = {};
          expenseMapByProductType[monthKey] = {};
          months.add(monthKey);
        }

        if (!groupedNotesByDay[monthKey]!.containsKey(dayKey)) {
          groupedNotesByDay[monthKey]![dayKey] = [];
          incomeMapByDay[monthKey]![dayKey] = 0;
          expenseMapByDay[monthKey]![dayKey] = 0;
        }

        if (!groupedNotesByProductType[monthKey]!.containsKey(productTypeKey)) {
          groupedNotesByProductType[monthKey]![productTypeKey] = [];
          incomeMapByProductType[monthKey]![productTypeKey] = 0;
          expenseMapByProductType[monthKey]![productTypeKey] = 0;
        }

        groupedNotesByDay[monthKey]![dayKey]!.add(note);
        groupedNotesByProductType[monthKey]![productTypeKey]!.add(note);

        // Tính tổng thu và chi cho mỗi ngày trong tháng
        if (note.processedData != null) {
          for (var data in note.processedData!) {
            if (data['Loại phương thức thanh toán'] == 'thu') {
              incomeMapByDay[monthKey]![dayKey] = (incomeMapByDay[monthKey]![dayKey]! + (data['Số tiền'] as num).toInt());
              incomeMapByProductType[monthKey]![productTypeKey] = (incomeMapByProductType[monthKey]![productTypeKey]! + (data['Số tiền'] as num).toInt());
            } else if (data['Loại phương thức thanh toán'] == 'chi') {
              expenseMapByDay[monthKey]![dayKey] = (expenseMapByDay[monthKey]![dayKey]! + (data['Số tiền'] as num).toInt());
              expenseMapByProductType[monthKey]![productTypeKey] = (expenseMapByProductType[monthKey]![productTypeKey]! + (data['Số tiền'] as num).toInt());
            }
          }
        }
      }
    }
    setState(() {
      dailyNotes = groupedNotesByDay;
      dailyIncome = incomeMapByDay;
      dailyExpense = expenseMapByDay;
      notesByProductType = groupedNotesByProductType;
      productTypeIncome = incomeMapByProductType;
      productTypeExpense = expenseMapByProductType;
    });
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) {
      return 'Không có thời gian';
    }

    DateFormat inputFormat = DateFormat('EEE, dd MMM yyyy HH:mm:ss zzz');
    DateTime dateTime = inputFormat.parse(timestamp);

    DateFormat outputFormat = DateFormat('EEEE, dd/MM/yyyy');
    return outputFormat.format(dateTime);
  }

  String _getImageUrl(String productType) {
    return 'assets/images/$productType.png'; // Ensure 'productType' is lowercase
  }

  String capitalize(String s) => s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : s;

  String _formatCurrency(int amount) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ');
    return formatter.format(amount);
  }

  Widget _buildNoteItem(Note note) {
    String itemName = capitalize(note.processedData?.first['Món đồ'] ?? 'Không có món đồ');
    String itemPlace = capitalize(note.processedData?.first['Nơi mua'] ?? 'Không có nơi mua');
    String productType = note.processedData?.first['Loại sản phẩm']?.toLowerCase() ?? 'default'; // Convert to lowercase
    String imageUrl = _getImageUrl(productType);
    int amount = (note.processedData?.first['Số tiền'] as num).toInt();
    bool isIncome = note.processedData?.first['Loại phương thức thanh toán'] == 'thu';

    print("link $imageUrl");

    return ListTile(
      leading: Image.asset( // Use one of the above methods
        imageUrl, // Replace this with an absolute path if other methods fail.
        width: 40,
        height: 40,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.image_not_supported); // Display an icon if the image fails to load
        },
      ),
      title: Text(
        itemName,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            itemPlace,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          Text(
            _formatTimestamp(note.timestamp),
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
      trailing: Text(
        _formatCurrency(amount),
        style: TextStyle(fontSize: 17, color: isIncome ? Colors.green : Colors.red),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NoteDetailPage(note: note),
          ),
        );
      },
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _updateMonthlyTotals() {
    totalIncome = 0;
    totalExpense = 0;

    if (_groupByProductType && _selectedProductType != 'Tất cả') {
      for (var month in months) {
        totalIncome += productTypeIncome[month]?[_selectedProductType] ?? 0;
        totalExpense += productTypeExpense[month]?[_selectedProductType] ?? 0;
      }
    } else {
      var dayKeys = dailyIncome[_selectedMonth]?.keys.toList() ?? [];
      for (var day in dayKeys) {
        totalIncome += dailyIncome[_selectedMonth]?[day] ?? 0;
        totalExpense += dailyExpense[_selectedMonth]?[day] ?? 0;
      }
    }

    setState(() {}); // Trigger a rebuild to update the totals
  }

  Widget _buildDailyNotes(String monthKey) {
    Map<String, List<Note>> monthNotes = dailyNotes[monthKey]!;
    Map<String, int> monthIncome = dailyIncome[monthKey]!;
    Map<String, int> monthExpense = dailyExpense[monthKey]!;

    return ListView(
      children: monthNotes.keys.map((dayKey) {
        List<Note> dayNotes = monthNotes[dayKey]!;
        int income = monthIncome[dayKey]!;
        int expense = monthExpense[dayKey]!;

        return ExpansionTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dayKey, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(
                'Tổng thu: ${_formatCurrency(income)}',
                style: TextStyle(fontSize: 16, color: Colors.green),
              ),
              Text(
                'Tổng chi: ${_formatCurrency(expense)}',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            ],
          ),
          children: dayNotes.map((note) => _buildNoteItem(note)).toList(),
        );
      }).toList(),
    );
  }

  Widget _buildNotesByProductType(String monthKey) {
    Map<String, List<Note>> productTypeNotes = notesByProductType[monthKey]!;
    Map<String, int> productTypeIncome = this.productTypeIncome[monthKey]!;
    Map<String, int> productTypeExpense = this.productTypeExpense[monthKey]!;

    return ListView(
      children: productTypeNotes.keys.map((typeKey) {
        List<Note> typeNotes = productTypeNotes[typeKey]!;
        int income = productTypeIncome[typeKey]!;
        int expense = productTypeExpense[typeKey]!;

        return ExpansionTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(typeKey, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(
                'Tổng thu: ${_formatCurrency(income)}',
                style: TextStyle(fontSize: 16, color: Colors.green),
              ),
              Text(
                'Tổng chi: ${_formatCurrency(expense)}',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            ],
          ),
          children: typeNotes.map((note) => _buildNoteItem(note)).toList(),
        );
      }).toList(),
    );
  }

  Widget _buildNotesPageContent() {
    List<String> productTypes = ['Tất cả'] + (notesByProductType[_selectedMonth]?.keys.toList() ?? []);

    return Column(
      children: [
        if (errorMessage != null)
          Center(
            child: Text(
              errorMessage!,
              style: TextStyle(color: Colors.red),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tổng thu: ${_formatCurrency(totalIncome)}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tổng chi: ${_formatCurrency(totalExpense)}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              DropdownButton<String>(
                value: _groupByProductType ? 'Loại sản phẩm' : 'Ngày',
                items: <String>['Ngày', 'Loại sản phẩm'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _groupByProductType = value == 'Loại sản phẩm';
                    _selectedProductType = 'Tất cả';
                    _updateMonthlyTotals(); // Update totals when changing group by option
                  });
                },
              ),
              if (_groupByProductType)
                SizedBox(width: 16),
              if (_groupByProductType)
                DropdownButton<String>(
                  value: _selectedProductType,
                  items: productTypes.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedProductType = value!;
                      _updateMonthlyTotals(); // Update totals when changing product type
                    });
                  },
                ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: months.map((monthKey) {
              if (_groupByProductType) {
                if (_selectedProductType == 'Tất cả') {
                  return _buildNotesByProductType(monthKey);
                } else {
                  Map<String, List<Note>> filteredNotes = {
                    _selectedProductType: notesByProductType[monthKey]?[_selectedProductType] ?? [],
                  };
                  return ListView(
                    children: filteredNotes.keys.map((typeKey) {
                      List<Note> typeNotes = filteredNotes[typeKey]!;
                      int income = productTypeIncome[monthKey]?[typeKey] ?? 0;
                      int expense = productTypeExpense[monthKey]?[typeKey] ?? 0;

                      return ExpansionTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(typeKey, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text(
                              'Tổng thu: ${_formatCurrency(income)}',
                              style: TextStyle(fontSize: 16, color: Colors.green),
                            ),
                            Text(
                              'Tổng chi: ${_formatCurrency(expense)}',
                              style: TextStyle(fontSize: 16, color: Colors.red),
                            ),
                          ],
                        ),
                        children: typeNotes.map((note) => _buildNoteItem(note)).toList(),
                      );
                    }).toList(),
                  );
                }
              } else {
                return _buildDailyNotes(monthKey);
              }
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _children = [
      _buildNotesPageContent(),
      NotePage_inp(),
    ];

    String appBarTitle = _currentIndex == 0 ? 'Danh sách thu chi' : ''; // Điều chỉnh tiêu đề

    return DefaultTabController(
      length: months.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle), // Sử dụng appBarTitle đã tính toán
          backgroundColor: Colors.yellow[50],
          bottom: _currentIndex == 0
              ? TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: months.map((month) => Tab(text: month)).toList(),
          )
              : null,
        ),
        body: _children[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          onTap: _onTabTapped,
          currentIndex: _currentIndex,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.note),
              label: 'Notes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.input),
              label: 'Note Input',
            ),
          ],
        ),
      ),
    );
  }
}
