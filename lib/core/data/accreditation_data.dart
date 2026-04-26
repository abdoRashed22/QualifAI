/// Mock data for all accreditation types, standards, and indicators
const Map<int, Map<String, dynamic>> accreditationData = {
  // 1 = Academic Accreditation (الاعتماد الأكاديمي)
  1: {
    'id': 1,
    'name': 'الاعتماد الأكاديمي',
    'description': 'اعتماد مؤسسي — المعايير الشاملة للكلية',
    'icon': '🏛️',
    'standards': [
      {
        'id': 1,
        'sectionId': 1,
        'name': 'التخطيط الاستراتيجي',
        'indicators': 7,
        'completedDocs': 0,
        'totalDocs': 7,
        'documents': [
          {
            'requiredDocumentId': 101,
            'documentName': 'الرؤية والرسالة المعتمدة',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 102,
            'documentName': 'الخطة الاستراتيجية',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 103,
            'documentName': 'التحليل البيئي',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 104,
            'documentName': 'الأهداف الاستراتيجية',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 105,
            'documentName': 'الخطط التنفيذية',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 106,
            'documentName': 'التقارير الدورية',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 107,
            'documentName': 'مؤشرات الأداء',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
        ],
      },
      {
        'id': 2,
        'sectionId': 2,
        'name': 'القيادة والحوكمة',
        'indicators': 6,
        'completedDocs': 0,
        'totalDocs': 6,
        'documents': [
          {
            'requiredDocumentId': 201,
            'documentName': 'معايير اختيار القيادات',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 202,
            'documentName': 'برامج تنمية القيادات',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 203,
            'documentName': 'نتائج تقييم الأداء',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 204,
            'documentName': 'القيم الجوهرية والأخلاقيات',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 205,
            'documentName': 'المعلومات المعلنة',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 206,
            'documentName': 'الهيكل التنظيمي',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
        ],
      },
      {
        'id': 3,
        'sectionId': 3,
        'name': 'إدارة الجودة والتطوير',
        'indicators': 4,
        'completedDocs': 0,
        'totalDocs': 4,
        'documents': [
          {
            'requiredDocumentId': 301,
            'documentName': 'وحدة ضمان الجودة',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 302,
            'documentName': 'الالئحة الداخلية للوحدة',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 303,
            'documentName': 'مؤشرات الأداء',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 304,
            'documentName': 'نتائج التقييم',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
        ],
      },
    ],
  },

  // 2 = Programmatic Accreditation (الاعتماد البرامجي)
  2: {
    'id': 2,
    'name': 'الاعتماد البرامجي',
    'description': 'اعتماد البرنامج / التخصص الأكاديمي',
    'icon': '📚',
    'standards': [
      {
        'id': 1,
        'sectionId': 1,
        'name': 'المعايير الأكاديمية والبرامج',
        'indicators': 2,
        'completedDocs': 0,
        'totalDocs': 2,
        'documents': [
          {
            'requiredDocumentId': 501,
            'documentName': 'المعايير المرجعية',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 502,
            'documentName': 'البرامج التعليمية',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
        ],
      },
      {
        'id': 2,
        'sectionId': 2,
        'name': 'التدريس والتعلم',
        'indicators': 2,
        'completedDocs': 0,
        'totalDocs': 2,
        'documents': [
          {
            'requiredDocumentId': 601,
            'documentName': 'استراتيجية التدريس والتعلم',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 602,
            'documentName': 'نتائج التقييم',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
        ],
      },
      {
        'id': 3,
        'sectionId': 3,
        'name': 'الطالب والخريجون',
        'indicators': 6,
        'completedDocs': 0,
        'totalDocs': 6,
        'documents': [
          {
            'requiredDocumentId': 701,
            'documentName': 'قواعد القبول والتحويل',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 702,
            'documentName': 'نظام دعم الطالب',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 703,
            'documentName': 'رعاية ذوي الاحتياجات الخاصة',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 704,
            'documentName': 'تمثيل الطالب في اللجان',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 705,
            'documentName': 'الأنشطة الطالبية',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 706,
            'documentName': 'متابعة الخريجين',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
        ],
      },
    ],
  },

  // 3 = Institutional Accreditation (الاعتماد المؤسسي)
  3: {
    'id': 3,
    'name': 'الاعتماد المؤسسي',
    'description': 'اعتماد المؤسسة التعليمية كاملة',
    'icon': '🏫',
    'standards': [
      {
        'id': 1,
        'sectionId': 1,
        'name': 'التخطيط الاستراتيجي',
        'indicators': 7,
        'completedDocs': 0,
        'totalDocs': 7,
        'documents': [
          {
            'requiredDocumentId': 1001,
            'documentName': 'رسالة ورؤية المؤسسة',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 1002,
            'documentName': 'الخطة الاستراتيجية',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 1003,
            'documentName': 'التحليل البيئي',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 1004,
            'documentName': 'الأهداف الاستراتيجية',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 1005,
            'documentName': 'الخطط التنفيذية',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 1006,
            'documentName': 'التقارير الدورية',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 1007,
            'documentName': 'متابعة الخطط',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
        ],
      },
      {
        'id': 2,
        'sectionId': 2,
        'name': 'القيادة والحوكمة',
        'indicators': 6,
        'completedDocs': 0,
        'totalDocs': 6,
        'documents': [
          {
            'requiredDocumentId': 1101,
            'documentName': 'اختيار القيادات',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 1102,
            'documentName': 'تنمية القيادات',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 1103,
            'documentName': 'تقييم الأداء',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 1104,
            'documentName': 'القيم والأخلاقيات',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 1105,
            'documentName': 'الشفافية والمعلومات',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 1106,
            'documentName': 'الهيكل التنظيمي',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
        ],
      },
      {
        'id': 3,
        'sectionId': 3,
        'name': 'إدارة الجودة والتطوير',
        'indicators': 4,
        'completedDocs': 0,
        'totalDocs': 4,
        'documents': [
          {
            'requiredDocumentId': 1201,
            'documentName': 'وحدة ضمان الجودة',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 1202,
            'documentName': 'الالئحة الداخلية',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 1203,
            'documentName': 'مؤشرات الأداء',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 1204,
            'documentName': 'نتائج التقييم',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
        ],
      },
      {
        'id': 4,
        'sectionId': 4,
        'name': 'الموارد المالية والمادية',
        'indicators': 6,
        'completedDocs': 0,
        'totalDocs': 6,
        'documents': [
          {
            'requiredDocumentId': 1301,
            'documentName': 'الموارد المالية',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 1302,
            'documentName': 'مصادر التمويل',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 1303,
            'documentName': 'المباني والقاعات',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 1304,
            'documentName': 'الصيانة الدورية',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 1305,
            'documentName': 'وسائل التكنولوجيا',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 1306,
            'documentName': 'المكتبة',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
        ],
      },
      {
        'id': 5,
        'sectionId': 5,
        'name': 'البحث العلمي والأنشطة العلمية',
        'indicators': 6,
        'completedDocs': 0,
        'totalDocs': 6,
        'documents': [
          {
            'requiredDocumentId': 1401,
            'documentName': 'خطة البحث العلمي',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 1402,
            'documentName': 'أخالقيات البحث',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 1403,
            'documentName': 'الموارد البحثية',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 1404,
            'documentName': 'دعم البحث العلمي',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 1405,
            'documentName': 'الإنتاج البحثي',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 1406,
            'documentName': 'المشاركة العلمية',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
        ],
      },
      {
        'id': 6,
        'sectionId': 6,
        'name': 'المشاركة المجتمعية وتنمية البيئة',
        'indicators': 4,
        'completedDocs': 0,
        'totalDocs': 4,
        'documents': [
          {
            'requiredDocumentId': 1501,
            'documentName': 'كيانات خدمة المجتمع',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 1502,
            'documentName': 'الأنشطة المجتمعية',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 1503,
            'documentName': 'تمثيل المجتمع',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
          {
            'requiredDocumentId': 1504,
            'documentName': 'قياس آراء المجتمع',
            'hasFile': false,
            'statusLabel': 'لم يتم التحميل',
            'statusColor': 'gray',
          },
        ],
      },
    ],
  },
};

/// Function to get all accreditation types
List<Map<String, dynamic>> getAllAccreditationTypes() {
  return accreditationData.entries.map((e) {
    final data = e.value;
    final standards = data['standards'] as List;
    final totalDocs = standards.fold<int>(
      0,
      (sum, standard) => sum + (standard['totalDocs'] as int),
    );
    final completedDocs = standards.fold<int>(
      0,
      (sum, standard) => sum + (standard['completedDocs'] as int),
    );

    return {
      'id': e.key,
      'accreditationType': e.key, // Add this for filtering
      'name': data['name'],
      'description': data['description'],
      'icon': data['icon'],
      'uploadedDocuments': completedDocs,
      'requiredDocumentsCount': totalDocs,
      'completionPercentage':
          totalDocs > 0 ? (completedDocs / totalDocs).clamp(0.0, 1.0) : 0.0,
    };
  }).toList();
}

/// Function to get standards for a specific accreditation type
Map<String, dynamic>? getSectionById(int accreditationType, int sectionId) {
  final data = accreditationData[accreditationType];
  if (data == null) return null;

  final standards = data['standards'] as List;
  final standard = standards.firstWhere(
    (s) => s['sectionId'] == sectionId,
    orElse: () => null,
  );

  if (standard == null) return null;

  return {
    'id': standard['id'],
    'sectionId': standard['sectionId'],
    'name': standard['name'],
    'uploadedDocuments': standard['completedDocs'],
    'requiredDocumentsCount': standard['totalDocs'],
    'completionPercentage': standard['totalDocs'] > 0
        ? (standard['completedDocs'] / standard['totalDocs']).clamp(0.0, 1.0)
        : 0.0,
    'requiredDocuments': standard['documents'] ?? [],
  };
}

/// Function to get all sections/standards for a specific accreditation type
List<Map<String, dynamic>> getStandardsByType(int accreditationType) {
  final data = accreditationData[accreditationType];
  if (data == null) return [];

  final standards = data['standards'] as List;
  return standards.map((s) {
    return {
      'id': s['id'],
      'sectionId': s['sectionId'],
      'name': s['name'],
      'uploadedDocuments': s['completedDocs'] as int,
      'requiredDocumentsCount': s['totalDocs'] as int,
      'completionPercentage': (s['totalDocs'] as int) > 0
          ? ((s['completedDocs'] as int) / (s['totalDocs'] as int))
              .clamp(0.0, 1.0)
          : 0.0,
    };
  }).toList();
}
