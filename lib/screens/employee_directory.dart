import 'package:flutter/material.dart';

// Model class to represent an employee
class Employee {
  final String name;
  final String position;
  final String email;
  final double salary;
  final List<String> benefits;
  final double performanceRating;
  final int leavesTaken; // Additional performance metric
  final int projectsCompleted; // Additional performance metric

  Employee({
    required this.name,
    required this.position,
    required this.email,
    required this.salary,
    required this.benefits,
    required this.performanceRating,
    required this.leavesTaken,
    required this.projectsCompleted,
  });
}

// Employee directory screen with dashboard analytics
class EmployeeDirectoryScreen extends StatelessWidget {
  // Dummy list of employees (replace with actual data fetching)
  final List<Employee> employees = [
    Employee(
      name: 'John Doe',
      position: 'Software Engineer',
      email: 'john@example.com',
      salary: 80000.0,
      benefits: ['Health Insurance', '401(k)'],
      performanceRating: 4.5,
      leavesTaken: 5,
      projectsCompleted: 8,
    ),
    Employee(
      name: 'Jane Smith',
      position: 'HR Manager',
      email: 'jane@example.com',
      salary: 100000.0,
      benefits: ['Health Insurance', 'Dental Insurance', 'Paid Time Off'],
      performanceRating: 4.8,
      leavesTaken: 3,
      projectsCompleted: 10,
    ),
    // Add more employees as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Directory'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Salary and Benefits Overview section
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Card(
              elevation: 4.0,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Salary and Benefits Overview',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    // Display average salary
                    Text(
                      'Average Salary: ₹${_calculateAverageSalary().toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(height: 8.0),
                    // Display benefits distribution
                    Text(
                      'Benefits Distribution:',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    Column(
                      children: _buildBenefitsDistribution(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 16.0),
          // Performance Overview section
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Card(
              elevation: 4.0,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Performance Overview',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    // Display average performance rating
                    Text(
                      'Average Performance Rating: ${_calculateAveragePerformanceRating().toStringAsFixed(1)}',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(height: 8.0),
                    // Display additional performance metrics
                    Text(
                      'Average Leaves Taken: ${_calculateAverageLeavesTaken().toStringAsFixed(1)}',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    Text(
                      'Average Projects Completed: ${_calculateAverageProjectsCompleted().toStringAsFixed(1)}',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 16.0),
          // Employee directory list
          Expanded(
            child: ListView.builder(
              itemCount: employees.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(employees[index].name),
                  subtitle: Text(employees[index].position),
                  onTap: () {
                    // Navigate to employee details screen when tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EmployeeDetailsScreen(employee: employees[index]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Method to calculate the average salary
  double _calculateAverageSalary() {
    double totalSalary = 0.0;
    for (var employee in employees) {
      totalSalary += employee.salary;
    }
    return totalSalary / employees.length;
  }

  // Method to build benefits distribution widgets
  List<Widget> _buildBenefitsDistribution() {
    List<Widget> benefitWidgets = [];
    Map<String, int> benefitCounts = {};

    // Count benefits occurrence
    for (var employee in employees) {
      for (var benefit in employee.benefits) {
        if (benefitCounts.containsKey(benefit)) {
          benefitCounts[benefit] = benefitCounts[benefit]! + 1;
        } else {
          benefitCounts[benefit] = 1;
        }
      }
    }

    // Build widgets
    benefitCounts.forEach((benefit, count) {
      benefitWidgets.add(
        Text('$benefit: $count employees'),
      );
    });

    return benefitWidgets;
  }

  // Method to calculate the average performance rating
  double _calculateAveragePerformanceRating() {
    double totalRating = 0.0;
    for (var employee in employees) {
      totalRating += employee.performanceRating;
    }
    return totalRating / employees.length;
  }

  // Method to calculate the average leaves taken
  double _calculateAverageLeavesTaken() {
    double totalLeaves = 0.0;
    for (var employee in employees) {
      totalLeaves += employee.leavesTaken;
    }
    return totalLeaves / employees.length;
  }

  // Method to calculate the average projects completed
  double _calculateAverageProjectsCompleted() {
    double totalProjects = 0.0;
    for (var employee in employees) {
      totalProjects += employee.projectsCompleted;
    }
    return totalProjects / employees.length;
  }
}

// Employee details screen
class EmployeeDetailsScreen extends StatelessWidget {
  final Employee employee;

  EmployeeDetailsScreen({required this.employee});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${employee.name}'),
            Text('Position: ${employee.position}'),
            Text('Email: ${employee.email}'),
            Text('Salary: ₹${employee.salary.toStringAsFixed(2)}'),
            Text('Benefits: ${employee.benefits.join(", ")}'),
            Text(
                'Performance Rating: ${employee.performanceRating.toStringAsFixed(1)}'),
            Text('Leaves Taken: ${employee.leavesTaken}'),
            Text('Projects Completed: ${employee.projectsCompleted}'),
            // Add more details as needed
          ],
        ),
      ),
    );
  }
}
