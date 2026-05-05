/// Reference data for the County Government of Baringo, Kenya.
///
/// Source material:
/// - https://www.baringo.go.ke (departments, CECMs, contact)
/// - https://www.baringo.go.ke/459/electoral-wards-and-area-by-sub-county-and-wards/
/// - Baringo County Symbols Act, 2014 (flag colors / motto)
/// - IEBC ward boundaries (2022) for the constituency view.
library;

class BaringoData {
  BaringoData._();

  // ---------------------------------------------------------------------------
  // County identity
  // ---------------------------------------------------------------------------

  static const String county = 'Baringo';
  static const String headquarters = 'Kabarnet';
  static const String motto = 'Deliver as One';
  static const String tagline =
      'From Vision to Impact: A Unified Path to Progress';
  static const String governor = 'Hon. Benjamin Cheboi, EGH, EBS';

  static const Map<String, String> contact = {
    'Toll-free': '1554',
    'Email': 'info@baringo.go.ke',
    'Website': 'https://www.baringo.go.ke',
    'Postal address': 'P.O. Box 53-30400, Kabarnet, Kenya',
  };

  /// Official meaning of each color on the County flag, per the Baringo
  /// County Symbols Act, 2014.
  static const Map<String, String> flagSymbolism = {
    'Green': 'A pristine environment conserved for generations.',
    'Golden Yellow':
        'The riches of the natural resources found within the County.',
    'Golden Brown':
        'The fertile, arable soils and the agricultural potential of Baringo.',
    'White': 'Peace — a prerequisite for meaningful progress.',
    'Lake Blue':
        'Lakes Baringo and Bogoria, and the shield carried in the County coat of arms.',
  };

  // ---------------------------------------------------------------------------
  // Administrative geography (County Government view: 7 sub-counties, 30 wards)
  // ---------------------------------------------------------------------------

  static const List<String> subCounties = [
    'Baringo Central',
    'Baringo North',
    'Baringo South',
    'Eldama Ravine',
    'Mogotio',
    'Tiaty East',
    'Tiaty West',
  ];

  static const Map<String, List<String>> subCountyWards = {
    'Baringo Central': [
      'Kabarnet',
      'Sacho',
      'Tenges',
      'Kapropita',
      'Ewalel Chapchap',
    ],
    'Baringo North': [
      'Barwessa',
      'Saimo Kipsaraman',
      'Saimo Soi',
      'Kabartonjo',
      'Bartabwa',
    ],
    'Baringo South': [
      'Mukutani',
      'Marigat',
      'Mochongoi',
      'Ilchamus',
    ],
    'Eldama Ravine': [
      'Lembus',
      'Ravine',
      'Lembus Kwen',
      'Koibatek',
      'Lembus Perkerra',
      'Mumberes/Majimazuri',
    ],
    'Mogotio': [
      'Mogotio',
      'Emining',
      'Kisanana',
    ],
    'Tiaty East': [
      'Silale',
      'Tangulbei',
      'Loiyamorok',
      'Churo/Amaya',
    ],
    'Tiaty West': [
      'Tirioko',
      'Kolowa',
      'Ribkwo',
    ],
  };

  // ---------------------------------------------------------------------------
  // IEBC constituency view (6 constituencies, 30 wards)
  // ---------------------------------------------------------------------------

  static const List<String> constituencies = [
    'Baringo Central',
    'Baringo North',
    'Baringo South',
    'Eldama Ravine',
    'Mogotio',
    'Tiaty',
  ];

  static const Map<String, List<String>> constituencyWards = {
    'Baringo Central': [
      'Kabarnet',
      'Sacho',
      'Tenges',
      'Kapropita',
      'Ewalel Chapchap',
    ],
    'Baringo North': [
      'Barwessa',
      'Saimo Kipsaraman',
      'Saimo Soi',
      'Kabartonjo',
      'Bartabwa',
    ],
    'Baringo South': [
      'Mukutani',
      'Marigat',
      'Mochongoi',
      'Ilchamus',
    ],
    'Eldama Ravine': [
      'Lembus',
      'Ravine',
      'Lembus Kwen',
      'Koibatek',
      'Lembus Perkerra',
      'Mumberes/Majimazuri',
    ],
    'Mogotio': [
      'Mogotio',
      'Emining',
      'Kisanana',
    ],
    'Tiaty': [
      'Tirioko',
      'Kolowa',
      'Ribkwo',
      'Silale',
      'Tangulbei',
      'Loiyamorok',
      'Churo/Amaya',
    ],
  };

  // ---------------------------------------------------------------------------
  // Departments (current, per baringo.go.ke/county-executive-committee)
  // ---------------------------------------------------------------------------

  /// Names match the canonical County Government department titles.
  static const List<String> departments = [
    'Agriculture, Livestock and Fisheries',
    'Devolution, Public Service, Administration and e-Government',
    'Education, Vocational Training and Library Services',
    'Finance and Economic Planning',
    'Health Services',
    'Industry, Commerce, Tourism, Enterprise and Cooperative Development',
    'Lands, Housing and Urban Development',
    'Transport, Roads, Infrastructure and Public Works',
    'Water, Irrigation, Environment, Natural Resources and Climate Change',
    'Youth, Sports, Gender and Cultural Services',
  ];

  /// Aliases for older department titles that may still be present in
  /// existing Firestore user documents. Map: legacy name → current name.
  static const Map<String, String> legacyDepartmentAliases = {
    'Agriculture, Livestock, and Fisheries Development':
        'Agriculture, Livestock and Fisheries',
    'Education and Vocational Training':
        'Education, Vocational Training and Library Services',
    'Finance, Economic Planning, and ICT':
        'Finance and Economic Planning',
    'Industry, Commerce, Tourism, Cooperatives, and Enterprise Development':
        'Industry, Commerce, Tourism, Enterprise and Cooperative Development',
    'Lands, Housing, Urban Development, and Municipalities':
        'Lands, Housing and Urban Development',
    'Lands, Housing, and Urban Development':
        'Lands, Housing and Urban Development',
    'Roads, Transport, Public Works, and Infrastructure Development':
        'Transport, Roads, Infrastructure and Public Works',
    'Water, Environment, Natural Resources, and Climate Change':
        'Water, Irrigation, Environment, Natural Resources and Climate Change',
    'Water, Irrigation, Environment, Natural Resources, and Mining':
        'Water, Irrigation, Environment, Natural Resources and Climate Change',
    'Youth Affairs, Sports, Gender, Culture, and Social Services':
        'Youth, Sports, Gender and Cultural Services',
    'Youth Affairs, Sports, Gender, and Special Programmes':
        'Youth, Sports, Gender and Cultural Services',
    'Devolution, Public Service, and Administration':
        'Devolution, Public Service, Administration and e-Government',
  };

  /// Resolves either a current department name or a legacy alias to the
  /// canonical current name.
  static String canonicalDepartment(String name) =>
      legacyDepartmentAliases[name] ?? name;

  // ---------------------------------------------------------------------------
  // Cabinet (CECMs) per department, current as of the latest reshuffle.
  // ---------------------------------------------------------------------------

  static const Map<String, String> cabinet = {
    'Agriculture, Livestock and Fisheries': 'Risper K. Chepkonga',
    'Devolution, Public Service, Administration and e-Government':
        'Maurine Karelo Limashep',
    'Education, Vocational Training and Library Services':
        'Peninah Jepkorir Bartuin',
    'Finance and Economic Planning': 'Wilson Cheserek Ruto',
    'Health Services': 'Dr. Solomon Kibet Sirma',
    'Industry, Commerce, Tourism, Enterprise and Cooperative Development':
        'Zachary Kipsang Kiprotich-Kobetbet',
    'Lands, Housing and Urban Development': 'Eng. Lekonaya K. Kibwalei',
    'Transport, Roads, Infrastructure and Public Works':
        'Rev. Symon Kiuta Lonyayo, PhD',
    'Water, Irrigation, Environment, Natural Resources and Climate Change':
        'Arch. Reuben Cheruiyot Rutto',
    'Youth, Sports, Gender and Cultural Services': 'Richard Naaman Tamar',
  };

  // ---------------------------------------------------------------------------
  // Sub-departments / directorates / units
  // ---------------------------------------------------------------------------

  static const Map<String, List<String>> subDepartments = {
    'Agriculture, Livestock and Fisheries': [
      'Directorate of Crop Production',
      'Directorate of Livestock Production',
      'Directorate of Fisheries Development',
      'Directorate of Veterinary Services',
    ],
    'Devolution, Public Service, Administration and e-Government': [
      'Directorate of Human Resource',
      'Directorate of Communication',
      'Directorate of Disaster Management',
      'ICT and e-Government Directorate',
      'County Administration',
    ],
    'Education, Vocational Training and Library Services': [
      'Early Childhood Development Education (ECDE)',
      'Vocational Training Centres',
      'Library Services',
      'Bursaries and Scholarships',
    ],
    'Finance and Economic Planning': [
      'Directorate of Finance and Accounting',
      'Directorate of Economic Planning',
      'Directorate of Revenue',
      'Directorate of Procurement',
      'Internal Audit',
    ],
    'Health Services': [
      'Preventive and Promotive Health Directorate',
      'Health Planning and Administration Directorate',
      'Medical Services Directorate',
    ],
    'Industry, Commerce, Tourism, Enterprise and Cooperative Development': [
      'Directorate of Trade',
      'Directorate of Industry',
      'Directorate of Tourism',
      'Directorate of Cooperatives',
      'Enterprise Development',
    ],
    'Lands, Housing and Urban Development': [
      'Directorate of Lands and Survey',
      'Directorate of Physical Planning',
      'Directorate of Housing',
      'Directorate of Urban Development',
      'County Municipalities',
    ],
    'Transport, Roads, Infrastructure and Public Works': [
      'Roads Unit',
      'Transport Unit',
      'Public Works and Infrastructure Directorate',
    ],
    'Water, Irrigation, Environment, Natural Resources and Climate Change': [
      'Water and Sanitation',
      'County Irrigation Development Unit (CIDU)',
      'County Water Boards',
      'Environment and Natural Resources',
      'Climate Change Directorate',
    ],
    'Youth, Sports, Gender and Cultural Services': [
      'Directorate of Youth Affairs',
      'Directorate of Sports',
      'Directorate of Gender and Social Services',
      'Directorate of Culture and Heritage',
    ],
  };

  // ---------------------------------------------------------------------------
  // Activity vocabularies
  // ---------------------------------------------------------------------------

  static const List<String> agricultureActivityTypes = [
    'Individual farm visits',
    'Group visits',
    'Trainings',
    'Barazas',
    'Input distribution',
    'Field days/Exhibitions',
    'Demonstration',
    'Crop damage assessment',
    'Information desk',
    'Market survey',
    'Plant clinics',
    'Staff meeting',
    'Farm business planning',
    'Soil sampling',
    'Project site visits',
    'Soil conservation structures',
  ];
}
