import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HRDashboardScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HR Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add),
            onPressed: () {
              _showAddEmployeeDialog(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Handle updating an employee
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _deleteEmployeeDialog(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Employee List',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 20.0),
            _buildEmployeeList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('employees').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text('No employees found');
        }
        var employees = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          itemCount: employees.length,
          itemBuilder: (context, index) {
            var employeeData = employees[index].data();
            return _buildHRCard(context, employeeData as Map<String, dynamic>);
          },
        );
      },
    );
  }

  Widget _buildHRCard(BuildContext context, Map<String, dynamic> employeeData) {
    return Card(
      elevation: 3.0,
      child: ListTile(
        title: Text(employeeData['name'] ?? ''),
        subtitle: Text(
          'Employee ID: ${employeeData['id']}\nJob Info: ${employeeData['jobinfo']}\nEmail: ${employeeData['email']}',
          style: TextStyle(color: Colors.grey[700]),
        ),
        trailing: PopupMenuButton<String>(
          itemBuilder: (BuildContext context) {
            return {'Attendance', 'Salary', 'Performance', 'Benefits', 'Delete'}
                .map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(choice),
              );
            }).toList();
          },
          onSelected: (String choice) {
            switch (choice) {
              case 'Attendance':
                _showAttendanceAnalytics(context);
                break;
              case 'Delete':
                _deleteEmployeeDialog(context);
                break;
              // Handle other choices
            }
          },
        ),
      ),
    );
  }

  void _showAttendanceAnalytics(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        bool showGraphs = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Attendance Analytics'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<QuerySnapshot>(
                    future: _firestore.collection('attendance').get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Text('No attendance records found');
                      }

                      // Calculate attendance analytics
                      int totalRecords = snapshot.data!.docs.length;
                      double totalWorkHours = 0;
                      double totalOvertime = 0;

                      snapshot.data!.docs.forEach((doc) {
                        var data = doc.data() as Map<String, dynamic>;
                        // Handle both int and string types for 'workinghours' and 'overtime' fields
                        totalWorkHours += (data['workinghours'] is int
                            ? (data['workinghours'] as int).toDouble()
                            : double.parse(data['workinghours'] ?? '0'));
                        totalOvertime += (data['overtime'] is int
                            ? (data['overtime'] as int).toDouble()
                            : double.parse(data['overtime'] ?? '0'));
                      });

                      double averageWorkHours = totalWorkHours / totalRecords;
                      double averageOvertime = totalOvertime / totalRecords;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Total Records: $totalRecords',
                              style: TextStyle(color: Colors.black87)),
                          Text('Total Work Hours: $totalWorkHours',
                              style: TextStyle(color: Colors.black87)),
                          Text('Total Overtime: $totalOvertime',
                              style: TextStyle(color: Colors.black87)),
                          Text('Average Work Hours: $averageWorkHours',
                              style: TextStyle(color: Colors.black87)),
                          Text('Average Overtime: $averageOvertime',
                              style: TextStyle(color: Colors.black87)),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showGraphs = true;
                      });
                    },
                    child: Text('Graphs'),
                  ),
                  if (showGraphs) ...[
                    SizedBox(height: 20),
                    _buildDummyGraph(),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDummyGraph() {
    // Dummy graph widget
    return Container(
      height: 200,
      width: double.infinity,
      color: Colors.grey[200],
      child: Center(
        child: Text(
          'Fetch Graph',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  void _showAddEmployeeDialog(BuildContext context) {
    String name = '';
    String id = '';
    String jobInfo = '';
    String email = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Employee'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Name'),
                  onChanged: (value) {
                    name = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Employee ID'),
                  onChanged: (value) {
                    id = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Job Info'),
                  onChanged: (value) {
                    jobInfo = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Email'),
                  onChanged: (value) {
                    email = value;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addEmployee(name, id, jobInfo, email);
                Navigator.of(context).pop();
              },
              child: Text('Done'),
            ),
          ],
        );
      },
    );
  }

  void _addEmployee(String name, String id, String jobInfo, String email) {
    // Add employee to Firestore
    _firestore.collection('employees').add({
      'name': name,
      'id': id,
      'jobinfo': jobInfo,
      'email': email,
    });
  }

  void _deleteEmployeeDialog(BuildContext context) {
    String name = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Employee'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Employee Name'),
                onChanged: (value) {
                  name = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteEmployee(name);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteEmployee(String name) {
    _firestore
        .collection('employees')
        .where('name', isEqualTo: name)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
  }
}
