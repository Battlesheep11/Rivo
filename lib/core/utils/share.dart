import 'package:supabase_flutter/supabase_flutter.dart';

/// Build the base URL for invoking Supabase Edge Functions for this project.
/// Example produced: https://xyzcompany.supabase.co/functions/v1
String _functionsBaseUrl(SupabaseClient client) {
  // rest.url is like: https://xyzcompany.supabase.co/rest/v1
  final restUri = Uri.parse(client.rest.url);
  final base = '${restUri.scheme}://${restUri.authority}';
  return '$base/functions/v1';
}

/// Returns a sharable URL for a product that hits the `share` Edge Function.
/// The function responds with an HTML page (OG tags + redirect to app/store).
String shareProductUrl(SupabaseClient client, String productId) {
  final uri = Uri.parse('${_functionsBaseUrl(client)}/share').replace(
    queryParameters: <String, String>{
      'type': 'product',
      'id': productId,
    },
  );
  return uri.toString();
}

/// Returns a sharable URL for a user profile using the user id.
String shareUserUrlById(SupabaseClient client, String userId) {
  final uri = Uri.parse('${_functionsBaseUrl(client)}/share').replace(
    queryParameters: <String, String>{
      'type': 'user',
      'id': userId,
    },
  );
  return uri.toString();
}

/// Returns a sharable URL for a user profile using the username.
String shareUserUrlByUsername(SupabaseClient client, String username) {
  final uri = Uri.parse('${_functionsBaseUrl(client)}/share').replace(
    queryParameters: <String, String>{
      'type': 'user',
      'username': username,
    },
  );
  return uri.toString();
}
