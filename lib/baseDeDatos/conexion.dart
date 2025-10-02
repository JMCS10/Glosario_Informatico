import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConexion {
  static Future<void> init() async {
    await Supabase.initialize(
      url: 'https://xfbfagnmnreqojznbyow.supabase.co', 
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhmYmZhZ25tbnJlcW9qem5ieW93Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgxNjgwNTgsImV4cCI6MjA3Mzc0NDA1OH0.fCMkzpRbShRPLxdYCp7vveWtL0anqoHLu9ZgeRqS_n8', 
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
