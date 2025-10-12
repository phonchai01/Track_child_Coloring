class Session {
  final int? id;
  final DateTime createdAt;
  final String templateKey; // fish / pencil / ice_cream ...
  final double h;           // entropy (0..1)
  final double dstar;       // complexity D* (0..1)
  final double cotl;        // นอกเส้น (0..1)
  final double blank;       // ในเส้นที่ว่าง (0..1)

  Session({
    this.id,
    required this.createdAt,
    required this.templateKey,
    required this.h,
    required this.dstar,
    required this.cotl,
    required this.blank,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'created_at': createdAt.toIso8601String(),
        'template_key': templateKey,
        'h': h,
        'dstar': dstar,
        'cotl': cotl,
        'blank': blank,
      };

  static Session fromMap(Map<String, Object?> m) => Session(
        id: m['id'] as int?,
        createdAt: DateTime.parse(m['created_at'] as String),
        templateKey: m['template_key'] as String,
        h: (m['h'] as num).toDouble(),
        dstar: (m['dstar'] as num).toDouble(),
        cotl: (m['cotl'] as num).toDouble(),
        blank: (m['blank'] as num).toDouble(),
      );
}
