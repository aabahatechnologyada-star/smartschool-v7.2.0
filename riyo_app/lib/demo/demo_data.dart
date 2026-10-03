class DemoData {
  static const Map<String, dynamic> student = {
    'firstname': 'Test',
    'lastname': 'Student',
    'admission_no': 'TEST001',
    'class': 'Grade 10',
    'section': 'A',
    'gender': 'Male',
    'dob': '2008-05-15',
    'father_name': 'Robert Student',
    'mother_name': 'Jane Student',
    'phone': '+1234567890',
    'email': 'test.student@riyo.edu',
    'address': '123 Education St, Campus City',
  };

  static const List<Map<String, dynamic>> notices = [
    {
      'title': 'Mid-term Exams Schedule',
      'message':
          'Mid-term examinations will commence on October 15. Please review the timetable and prepare accordingly.',
      'date': '2026-10-01',
    },
    {
      'title': 'Parents-Teachers Association Meeting',
      'message':
          'Annual PTA meeting is scheduled for October 20 at 4:00 PM in the main auditorium.',
      'date': '2026-09-28',
    },
    {
      'title': 'Science Fair Registration Open',
      'message':
          'Students interested in entering the Annual Science Fair should register with their science teachers by Friday.',
      'date': '2026-09-20',
    },
  ];

  static const List<Map<String, dynamic>> examResults = [
    {
      'session': '2025-2026',
      'class': 'Grade 10 – A',
      'exam_group': 'Mid Term',
      'percentage': 88.5,
      'grade': 'A',
      'rank': '2',
      'total_students': 35,
      'total_get': 354,
      'total_max': 400,
      'teacher_remarks':
          'Excellent performance across all subjects. Keep up the great work!',
      'subjects': [
        {
          'subject': 'Mathematics',
          'get_marks': 92,
          'max_marks': 100,
          'grade': 'A+',
        },
        {
          'subject': 'Science',
          'get_marks': 88,
          'max_marks': 100,
          'grade': 'A',
        },
        {
          'subject': 'English',
          'get_marks': 89,
          'max_marks': 100,
          'grade': 'A',
        },
        {
          'subject': 'Social Studies',
          'get_marks': 85,
          'max_marks': 100,
          'grade': 'A',
        },
      ],
    },
    {
      'session': '2025-2026',
      'class': 'Grade 10 – A',
      'exam_group': 'First Quarterly',
      'percentage': 91.2,
      'grade': 'A+',
      'rank': '1',
      'total_students': 35,
      'total_get': 365,
      'total_max': 400,
      'teacher_remarks': 'Outstanding results! Ranked #1 in class.',
      'subjects': [
        {
          'subject': 'Mathematics',
          'get_marks': 95,
          'max_marks': 100,
          'grade': 'A+',
        },
        {
          'subject': 'Science',
          'get_marks': 92,
          'max_marks': 100,
          'grade': 'A+',
        },
        {
          'subject': 'English',
          'get_marks': 90,
          'max_marks': 100,
          'grade': 'A+',
        },
        {
          'subject': 'Social Studies',
          'get_marks': 88,
          'max_marks': 100,
          'grade': 'A',
        },
      ],
    },
  ];

  static const Map<String, dynamic> fees = {
    'status': 'success',
    'total_due': 0,
    'paid_amount': 45000,
    'transactions': [
      {
        'date': '2026-01-15',
        'amount': 15000,
        'description': 'Tuition Fee - Term 1',
        'status': 'Paid',
      },
      {
        'date': '2026-02-15',
        'amount': 15000,
        'description': 'Tuition Fee - Term 2',
        'status': 'Paid',
      },
      {
        'date': '2026-03-15',
        'amount': 15000,
        'description': 'Tuition Fee - Term 3',
        'status': 'Paid',
      },
    ],
  };

  static Map<String, dynamic> attendance = {
    'status': 'success',
    'month': '2026-10',
    'records': List.generate(
      30,
      (i) => {
        'date': '2026-10-${(i + 1).toString().padLeft(2, '0')}',
        'status': ['P', 'P', 'P', 'P', 'A', 'P', 'L'][i % 5],
      },
    ),
  };

  static const List<Map<String, dynamic>> incidents = [
    {
      'title': 'Good Conduct Commendation',
      'date': '2026-09-12',
      'type': 'Positive',
      'description': 'Helped organize the library book donation drive.',
    },
  ];

  static const Map<String, dynamic> dashboard = {
    'status': 'success',
    'attendance_percentage': 96.0,
    'fee_status': 'Paid',
    'next_exam': 'Final Exam - Nov 15',
    'pending_homework': 2,
    'recent_notices': 3,
  };
}
