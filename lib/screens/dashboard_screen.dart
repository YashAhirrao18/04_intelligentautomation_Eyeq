import 'package:cashmate/screens/employee_directory.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cashmate/screens/hr_dashboard_screen.dart';
import 'dart:math';

class DashboardScreen extends StatefulWidget {
  final String employeeName;

  const DashboardScreen({Key? key, required this.employeeName})
      : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late User? _user;
  TextEditingController _messageController = TextEditingController();
  List<Widget> _messages = []; // List to store messages and widgets
  final List<String> leaveTypes = [
    "Vacation",
    "Sick",
    "Maternity",
    "Unpaid",
  ];
  // Define performance criteria
  final List<String> performanceCriteria = [
    "Feedback",
    "Goals",
    "Rating",
    // Add more criteria as needed
  ];

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  Future<void> _getUserInfo() async {
    _user = FirebaseAuth.instance.currentUser;

    if (_user != null) {
      await _user!.reload();
      setState(() {
        _user = FirebaseAuth.instance.currentUser;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Management Chatbot'),
        backgroundColor: Colors.deepPurple,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('HR Dashboard'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HRDashboardScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Employee Directory'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EmployeeDirectoryScreen()),
                );
                // Navigate to employee directory screen
              },
            ),
            ListTile(
              title: Text('Notifications'),
              onTap: () {
                // Navigate to notifications screen
              },
            ),
            ListTile(
              title: Text('Settings'),
              onTap: () {
                // Navigate to settings screen
              },
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Image.asset(
                  'assets/jobmate_logo.png',
                  width: 200,
                  height: 150,
                ),
                SizedBox(height: 15),
                Text(
                  'Welcome to the Employee Management Chatbot, ${widget.employeeName}!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _messages[index];
              },
              reverse: true,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              IconButton(
                onPressed: () {
                  _sendMessage();
                },
                icon: Icon(Icons.send),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatBubble(String message) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  void _sendMessage() {
    String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      setState(() {
        _messages.insert(0, _buildChatBubble(message));
        _messageController.clear();
      });

      _processUserInput(message);
    }
  }

  void _processUserInput(String userInput) {
    // Tokenize the user input
    List<String> tokens = userInput.toLowerCase().split(' ');

    // Process recognized text
    if (_containsAny(tokens, [
      'hi',
      'hey',
      'hello',
      'menu',
      'options',
      'help',
      'assistance',
      'greetings',
      'hello there',
      'howdy'
    ])) {
      _displayMenu();
    } else if (_containsAll(tokens, [
      'attendance',
      'check',
      'track',
      'record',
      'monitor',
      'time',
      'punch',
      'log',
      'shift',
      'hours'
    ])) {
      _startConversationForOption("Attendance Tracking");
    } else if (_containsAny(tokens, [
      'leave',
      'vacation',
      'sick',
      'maternity',
      'unpaid',
      'absence',
      'off',
      'pto',
      'holiday'
    ])) {
      _startConversationForOption("Leave Management");
    } else if (_containsAny(tokens, [
      'performance',
      'evaluate',
      'appraisal',
      'review',
      'progress',
      'goals',
      'feedback'
    ])) {
      _startConversationForOption("Performance Evaluation");
    } else if (_containsAny(tokens, [
      'salary',
      'benefits',
      'compensation',
      'pay',
      'wages',
      'insurance',
      'perks'
    ])) {
      _startConversationForOption("Salary and Benefits Management");
    } else {
      displayMessage("Sorry, I didn't understand that.");
    }
  }

  bool _containsAll(List<String> tokens, List<String> keywords) {
    return keywords.every((keyword) => tokens.contains(keyword));
  }

  bool _containsAny(List<String> tokens, List<String> keywords) {
    return keywords.any((keyword) => tokens.contains(keyword));
  }

  void _displayMenu() {
    displayMessage("Hi! How can I help you? Please select an option:");

    for (String option in menuOptions) {
      _messages.insert(
        0,
        ElevatedButton(
          onPressed: () {
            _startConversationForOption(option);
          },
          child: Text(option),
        ),
      );
    }
  }

  void _startConversationForOption(String option) {
    switch (option) {
      case "Attendance Tracking":
        _startAttendanceManagementFlow();
        break;
      case "Leave Management":
        _startLeaveManagementFlow();
        break;
      case "Performance Evaluation":
        _startPerformanceEvaluationFlow();
        break;
      case "Salary and Benefits Management":
        _startSalaryBenefitsFlow();
        break;
      default:
        break;
    }
  }

  void displayMessage(String message) {
    setState(() {
      _messages.insert(0, _buildChatBubble(message));
    });
  }

  void _startAttendanceManagementFlow() {
    displayMessage("Let's manage attendance. Please select an option:");

    for (String option in attendanceManagementOptions) {
      _messages.insert(
        0,
        ElevatedButton(
          onPressed: () {
            _processAttendanceManagementOption(option);
          },
          child: Text(option),
        ),
      );
    }
  }

  void _processAttendanceManagementOption(String option) {
    switch (option) {
      case "Clock In":
        // Get current timestamp
        DateTime now = DateTime.now();
        Timestamp timestamp = Timestamp.fromDate(now);

        // Get current user's location (dummy location for demonstration)
        GeoPoint userLocation = GeoPoint(
            29.0, 30.0); // Replace with actual user location retrieval logic

        // Store clock in time and location to Firestore
        _storeAttendance("clockintime", timestamp, userLocation);

        displayMessage("You've clocked in.");
        break;
      case "Clock Out":
        // Get current timestamp
        DateTime now = DateTime.now();
        Timestamp timestamp = Timestamp.fromDate(now);

        // Get current user's location (dummy location for demonstration)
        GeoPoint userLocation = GeoPoint(
            72.0, 82.0); // Replace with actual user location retrieval logic

        // Store clock out time and location to Firestore
        _storeAttendance("clockouttime", timestamp, userLocation);

        displayMessage("You've clocked out.");
        break;
      default:
        break;
    }
  }

  void _storeAttendance(
      String field, Timestamp timestamp, GeoPoint currentLocation) async {
    try {
      // Get current user's ID
      String? userId;
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        userId = currentUser.uid;
      } else {
        print("Current user is null.");
        return;
      }

      // Get Firestore reference to the attendance document for the current user
      DocumentReference docRef =
          FirebaseFirestore.instance.collection("attendance").doc(userId);

      // Update the attendance document with clock in/out time and location
      await docRef.update({
        field: FieldValue.arrayUnion([timestamp, currentLocation]),
        "geopoint":
            currentLocation // Store currentLocation in the "geopoint" field
      });

      // Display message asking for further assistance
      displayMessage("Do you need further assistance?");

      // Add buttons for user to choose from
      _messages.insert(
        0,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                // Handle "Yes" button press
                _handleFurtherAssistance(true);
              },
              child: Text("Yes"),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle "No" button press
                _handleFurtherAssistance(false);
              },
              child: Text("No"),
            ),
          ],
        ),
      );
    } catch (e) {
      print("Error storing attendance: $e");
    }
  }

  void _handleFurtherAssistance(bool needAssistance) {
    if (needAssistance) {
      // If user needs assistance, display the main menu
      _displayMenu();
    } else {
      // If user doesn't need assistance, display a thank you message
      displayMessage("Thank you! Have a great day.");
    }
  }

  final List<String> attendanceManagementOptions = [
    "Clock In",
    "Clock Out",
  ];

  void _startLeaveManagementFlow() {
    displayMessage("Let's start managing leave. Kindly select start date");

    for (String option in leaveManagementOptions) {
      _messages.insert(
        0,
        ElevatedButton(
          onPressed: () {
            _processLeaveManagementOption(option);
          },
          child: Text(option),
        ),
      );
    }
  }

  void _processLeaveManagementOption(String option) {
    switch (option) {
      case "Select Date":
        _selectDate(context, 'start');
        break;
    }
  }

  Future<void> _addEndDateAndLeaveTypeToFirestore(String formattedDate) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot<Map<String, dynamic>> leaveDocument =
          await FirebaseFirestore.instance
              .collection('leave')
              .doc(userId)
              .get();

      if (leaveDocument.exists) {
        await FirebaseFirestore.instance
            .collection('leave')
            .doc(userId)
            .update({'endDate': formattedDate});
      } else {
        print('Document does not exist');
      }
    } catch (error) {
      print("Error adding end date to Firestore: $error");
    }
  }

  Future<void> _selectDate(BuildContext context, String dateType) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      if (dateType == 'start') {
        await _addStartDateToFirestore(formattedDate);
        displayMessage("Selected start date: $formattedDate");
        displayMessage("Enter the End Date");
        _messages.insert(
          0,
          ElevatedButton(
            onPressed: () {
              _selectDate(context, 'end');
            },
            child: Text("Select Date"),
          ),
        );
      } else if (dateType == 'end') {
        await _addEndDateAndLeaveTypeToFirestore(formattedDate);
        displayMessage("Selected end date: $formattedDate");
        displayMessage("Select the type of leave");
        _showLeaveTypeButtons();
      }
    }
  }

  Future<void> _addStartDateToFirestore(String formattedDate) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection('leave')
          .doc(userId)
          .set({'startDate': formattedDate});
    } catch (error) {
      print("Error adding start date to Firestore: $error");
    }
  }

  final List<String> leaveManagementOptions = [
    "Select Date",
  ];

  void _startPerformanceEvaluationFlow() {
    displayMessage(
        "Let's start evaluating performance. Please select criteria:");

    // Display buttons for performance evaluation criteria
    for (String criterion in performanceCriteria) {
      _messages.insert(
        0,
        ElevatedButton(
          onPressed: () {
            _processPerformanceCriterionSelection(criterion);
          },
          child: Text(criterion),
        ),
      );
    }
  }

  void _processPerformanceCriterionSelection(String criterion) async {
    try {
      String message = '';

      switch (criterion) {
        case 'Feedback':
          message =
              "Throughout this evaluation period, struggled with meeting project deadlines and managing her workload effectively";
          break;
        case 'Goals':
          message =
              "During this performance evaluation period, primary goal was to increase customer satisfaction scores by 10% through proactive communication and timely resolution of customer inquiries.";
          break;
        case 'Rating':
          message = "4";
          break;
        default:
          message = "No data available for $criterion";
          break;
      }
      void _askForFurtherAssistance() {
        // Display message asking for further assistance
        displayMessage("Do you need further assistance?");

        // Add buttons for user to choose from
        _messages.insert(
          0,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Handle "Yes" button press
                  _displayMenu();
                },
                child: Text("Yes"),
              ),
              ElevatedButton(
                onPressed: () {
                  // Handle "No" button press
                  displayMessage("Thank you! Have a great day.");
                },
                child: Text("No"),
              ),
            ],
          ),
        );
      }

      displayMessage(message);
      _askForFurtherAssistance(); // Ask for further assistance after displaying the message
    } catch (error) {
      print("Error fetching performance data: $error");
    }
  }

  void _startSalaryBenefitsFlow() {
    displayMessage(
        "Let's start managing salary and benefits. Please select an option:");

    for (String option in salaryBenefitsOptions) {
      _messages.insert(
        0,
        ElevatedButton(
          onPressed: () {
            _processSalaryBenefitsOption(option);
          },
          child: Text(option),
        ),
      );
    }
  }

  void _processSalaryBenefitsOption(String option) async {
    try {
      switch (option) {
        case "Salary":
          await _fetchAndDisplaySalary();
          break;
        case "Deductions":
          await _fetchAndDisplayDeductions();
          break;
        case "Benefits":
          await _fetchAndDisplayBenefits();
          break;
      }
    } catch (error) {
      print("Error processing salary and benefits option: $error");
    }
  }

  Future<void> _fetchAndDisplaySalary() async {
    // Simulate fetching salary data
    int salary = 75000;
    // Display sample message
    displayMessage("Your salary: $salary");
    _askForFurtherAssistance();
  }

  Future<void> _fetchAndDisplayDeductions() async {
    // Simulate fetching deductions data
    List<String> deductions = ["6000 on tax", "5000 on insurance"];
    // Display sample message
    displayMessage("Your deductions:");
    for (int i = 0; i < deductions.length; i++) {
      displayMessage("Deduction ${i + 1}: ${deductions[i]}");
    }
    _askForFurtherAssistance();
  }

  Future<void> _fetchAndDisplayBenefits() async {
    // Simulate fetching benefits data
    List<String> benefits = ["pension plan", "transportation allowance"];
    // Display sample message
    displayMessage("Your benefits:");
    for (int i = 0; i < benefits.length; i++) {
      displayMessage("Benefit ${i + 1}: ${benefits[i]}");
    }
    _askForFurtherAssistance();
  }

  void _showLeaveTypeButtons() {
    for (String leaveType in leaveTypes) {
      _messages.insert(
        0,
        ElevatedButton(
          onPressed: () {
            _processLeaveTypeSelection(leaveType);
          },
          child: Text(leaveType),
        ),
      );
    }
  }

  void _processLeaveTypeSelection(String leaveType) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection('leave')
          .doc(userId)
          .update({'leaveType': leaveType});
      displayMessage("Leave type selected: $leaveType");
      displayMessage("Your leave has been approved");
      _askForFurtherAssistance();
    } catch (error) {
      print("Error updating leave type to Firestore: $error");
      // Handle the error as needed
    }
  }

  void _askForFurtherAssistance() {
    // Display message asking for further assistance
    displayMessage("Do you need further assistance?");

    // Add buttons for user to choose from
    _messages.insert(
      0,
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () {
              // Handle "Yes" button press
              _displayMenu();
            },
            child: Text("Yes"),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle "No" button press
              displayMessage("Thank you! Have a great day.");
            },
            child: Text("No"),
          ),
        ],
      ),
    );
  }

  final List<String> menuOptions = [
    "Attendance Tracking",
    "Leave Management",
    "Performance Evaluation",
    "Salary and Benefits Management"
  ];

  final List<String> salaryBenefitsOptions = [
    "Salary",
    "Deductions",
    "Benefits",
  ];
}
