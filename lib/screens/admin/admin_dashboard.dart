import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../../constants/app_theme.dart';
import '../../constants/baringo_data.dart';
import '../../models/user_model.dart';
import '../../models/work_report_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../about_screen.dart';
import 'map_view_screen.dart';
import 'user_details_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  final DatabaseService _databaseService = DatabaseService();
  late final TabController _tabController;

  String _selectedDepartment = 'All';
  late DateTimeRange _selectedDateRange;
  Map<String, UserModel> _userMap = {};

  static const _allDepartments = 'All';
  static List<String> get _departmentFilters =>
      [_allDepartments, ...BaringoData.departments];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedDateRange = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 30)),
      end: DateTime.now(),
    );
    _loadUsers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    final users = await _databaseService.getAllUsersOnce();
    if (!mounted) return;
    setState(() => _userMap = {for (final u in users) u.id: u});
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primaryGreen,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDateRange = picked);
  }

  bool _matchesFilters(WorkReportModel report) {
    final deptOk = _selectedDepartment == _allDepartments ||
        report.department == _selectedDepartment;
    final start = _selectedDateRange.start;
    final endInclusive = _selectedDateRange.end.add(const Duration(days: 1));
    final dateOk = !report.date.isBefore(start) && report.date.isBefore(endInclusive);
    return deptOk && dateOk;
  }

  Future<void> _printUsers(List<UserModel> users) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => pw.Column(
          children: [
            pw.Text(
              'BARINGO COUNTY GOVERNMENT',
              style:
                  pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'STAFF PERFORMANCE MAPPING — USERS LIST',
              style:
                  pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 16),
          ],
        ),
        build: (context) => [
          pw.TableHelper.fromTextArray(
            cellPadding: const pw.EdgeInsets.all(6),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            headerStyle:
                pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
            cellStyle: const pw.TextStyle(fontSize: 10),
            headers: const [
              'Name',
              'Department',
              'Sub-County',
              'Email',
              'Phone',
            ],
            data: users
                .map((u) => [
                      '${u.firstName} ${u.middleName} ${u.surname}',
                      u.department,
                      u.subCounty,
                      u.email,
                      u.phoneNumber,
                    ])
                .toList(),
          ),
        ],
        footer: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Text(
              'Page ${context.pageNumber}/${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ],
        ),
      ),
    );
    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
      name: 'users_list.pdf',
    );
  }

  Future<void> _printTasks(List<WorkReportModel> reports) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => pw.Column(
          children: [
            pw.Text(
              'BARINGO COUNTY GOVERNMENT',
              style:
                  pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'STAFF PERFORMANCE MAPPING — TASK REPORTS',
              style:
                  pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'Period: ${DateFormat('dd/MM/yyyy').format(_selectedDateRange.start)} '
              '– ${DateFormat('dd/MM/yyyy').format(_selectedDateRange.end)}'
              '   |   Department: $_selectedDepartment',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 16),
          ],
        ),
        build: (context) => [
          pw.TableHelper.fromTextArray(
            cellPadding: const pw.EdgeInsets.all(6),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            headerStyle:
                pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
            cellStyle: const pw.TextStyle(fontSize: 8),
            headers: const [
              'Staff',
              'Department',
              'Task',
              'Location',
              'M',
              'F',
              'Total',
              'Description',
              'Remarks',
              'Date',
            ],
            data: reports.map((r) {
              final user = _userMap[r.userId];
              final name = user == null
                  ? 'Unknown'
                  : '${user.firstName} ${user.middleName} ${user.surname}';
              return [
                name,
                r.department,
                r.task,
                r.location,
                r.maleAttendance.toString(),
                r.femaleAttendance.toString(),
                r.totalAttendance.toString(),
                r.description,
                r.remarks,
                DateFormat('dd/MM/yyyy HH:mm').format(r.date),
              ];
            }).toList(),
          ),
        ],
      ),
    );
    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
      name: 'tasks_list.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Print current view',
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              if (_tabController.index == 0) {
                final users = await _databaseService.getAllUsersOnce();
                await _printUsers(users);
              } else {
                final reports =
                    await _databaseService.getAllWorkReportsOnce();
                final filtered = reports.where(_matchesFilters).toList();
                if (filtered.isEmpty) {
                  messenger.showSnackBar(const SnackBar(
                    content: Text('No tasks match the current filters.'),
                  ));
                  return;
                }
                await _printTasks(filtered);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadUsers,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'About',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Logout',
            onPressed: authProvider.signOut,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Users'),
            Tab(text: 'Tasks'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUsersTable(),
          Column(
            children: [
              _buildFilters(),
              Expanded(child: _buildTasksTable()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButton<String>(
              value: _selectedDepartment,
              isExpanded: true,
              hint: const Text('Select Department'),
              items: _departmentFilters
                  .map((d) => DropdownMenuItem(
                        value: d,
                        child: Text(d, overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedDepartment = v ?? 'All'),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _selectDateRange,
            icon: const Icon(Icons.date_range),
            label: Text(
              '${DateFormat('dd/MM/yyyy').format(_selectedDateRange.start)} – '
              '${DateFormat('dd/MM/yyyy').format(_selectedDateRange.end)}',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTable() {
    return StreamBuilder<List<UserModel>>(
      stream: _databaseService.getAllUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final users = snapshot.data ?? const [];
        if (users.isEmpty) {
          return const Center(child: Text('No users available.'));
        }
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DataTable(
                headingRowColor:
                    WidgetStateProperty.all(const Color(0xFFF5F5F5)),
                columnSpacing: 32,
                horizontalMargin: 16,
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Department')),
                  DataColumn(label: Text('Sub-County')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Phone Number')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: users.map((u) {
                  return DataRow(
                    cells: [
                      DataCell(Text(
                        '${u.firstName} ${u.middleName} ${u.surname}',
                      )),
                      DataCell(Text(u.department)),
                      DataCell(Text(u.subCounty)),
                      DataCell(Text(u.email)),
                      DataCell(Text(u.phoneNumber)),
                      DataCell(IconButton(
                        icon: const Icon(
                          Icons.visibility,
                          color: AppColors.accentBlue,
                        ),
                        tooltip: 'View Details',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  UserDetailsScreen(userId: u.id),
                            ),
                          );
                        },
                      )),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTasksTable() {
    return StreamBuilder<List<WorkReportModel>>(
      stream: _databaseService.getAllWorkReports(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final filtered =
            (snapshot.data ?? const <WorkReportModel>[]).where(_matchesFilters).toList();
        if (filtered.isEmpty) {
          return const Center(
            child: Text('No tasks available for the selected criteria.'),
          );
        }
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DataTable(
                headingRowColor:
                    WidgetStateProperty.all(const Color(0xFFF5F5F5)),
                columnSpacing: 32,
                horizontalMargin: 16,
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
                columns: const [
                  DataColumn(label: Text('User Name')),
                  DataColumn(label: Text('Department')),
                  DataColumn(label: Text('Task')),
                  DataColumn(label: Text('Location')),
                  DataColumn(label: Text('M')),
                  DataColumn(label: Text('F')),
                  DataColumn(label: Text('Total')),
                  DataColumn(label: Text('Description')),
                  DataColumn(label: Text('Remarks')),
                  DataColumn(label: Text('Date & Time')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: filtered.map((r) {
                  final user = _userMap[r.userId];
                  final name = user == null
                      ? 'Unknown User'
                      : '${user.firstName} ${user.middleName} ${user.surname}';
                  return DataRow(
                    cells: [
                      DataCell(Text(name)),
                      DataCell(Text(r.department)),
                      DataCell(Text(r.task)),
                      DataCell(Text(r.location)),
                      DataCell(Text(r.maleAttendance.toString())),
                      DataCell(Text(r.femaleAttendance.toString())),
                      DataCell(Text(r.totalAttendance.toString())),
                      DataCell(SizedBox(
                        width: 200,
                        child: Text(
                          r.description,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )),
                      DataCell(SizedBox(
                        width: 200,
                        child: Text(
                          r.remarks,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )),
                      DataCell(Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(r.date),
                      )),
                      DataCell(Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.visibility,
                              color: AppColors.accentBlue,
                            ),
                            tooltip: 'View Details',
                            onPressed: () => _showTaskDetails(r),
                          ),
                          if (r.geoLocation != null)
                            IconButton(
                              icon: const Icon(
                                Icons.map,
                                color: AppColors.primaryGreen,
                              ),
                              tooltip: 'View on Map',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        MapViewScreen(report: r),
                                  ),
                                );
                              },
                            ),
                        ],
                      )),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showTaskDetails(WorkReportModel report) {
    final user = _userMap[report.userId];
    final userName = user == null
        ? 'Unknown User'
        : '${user.firstName} ${user.middleName} ${user.surname}';

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 500,
            maxHeight: MediaQuery.of(ctx).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16)),
                  color: AppColors.primaryGreen,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Task Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _section('User Information', [
                          _detail('Name', userName),
                          _detail('Department', report.department),
                        ]),
                        const SizedBox(height: 12),
                        _section('Task Information', [
                          _detail('Task', report.task),
                          _detail('Location', report.location),
                          _detail(
                            'Date & Time',
                            DateFormat('dd/MM/yyyy HH:mm').format(report.date),
                          ),
                        ]),
                        const SizedBox(height: 12),
                        _section('Attendance', [
                          _detail('Male', report.maleAttendance.toString()),
                          _detail('Female', report.femaleAttendance.toString()),
                          _detail('Youth', report.youthAttendance.toString()),
                          _detail('Total', report.totalAttendance.toString()),
                        ]),
                        const SizedBox(height: 12),
                        _section('Additional Information', [
                          _detail('Description', report.description),
                          _detail('Remarks', report.remarks),
                        ]),
                        if (report.geoLocation != null) ...[
                          const SizedBox(height: 12),
                          _section('Location Details', [
                            _detail(
                              'Coordinates',
                              '${report.geoLocation!.latitude}, '
                                  '${report.geoLocation!.longitude}',
                            ),
                            _detail('IP Address', report.ip),
                            _detail('Country', report.country),
                            _detail('City', report.city),
                          ]),
                        ],
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (report.geoLocation != null)
                              ElevatedButton.icon(
                                icon: const Icon(Icons.map),
                                label: const Text('View on Map'),
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          MapViewScreen(report: report),
                                    ),
                                  );
                                },
                              ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryGreen,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _detail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
