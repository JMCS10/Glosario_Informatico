import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConexion {
  static Future<void> init() async {
    await Supabase.initialize(
      url: 'https://kpuizfxupmtktuevckkz.supabase.co', 
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtwdWl6Znh1cG10a3R1ZXZja2t6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg3NTkyNjUsImV4cCI6MjA3NDMzNTI2NX0.iWepnEbZl5Ma9O-wmcoH32-tsRQEWW69QxM2mvnv3LU', 
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
