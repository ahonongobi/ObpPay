import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:obppay/providers/user_provider.dart';
import 'package:obppay/themes/app_colors.dart';
import 'package:provider/provider.dart';
import '../services/api.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List notifications = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    final token = context.read<UserProvider>().token;

    final res = await http.get(
      Uri.parse("${Api.baseUrl}/notifications"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json"
      },
    );

    final data = jsonDecode(res.body);

    setState(() {
      if (data is List) {
        notifications = data;
      }
      else if (data is Map && data.containsKey("notifications")) {
        notifications = data["notifications"];
      }
      else if (data is Map && data.containsKey("data")) {
        notifications = data["data"];
      }
      else {
        notifications = [];
      }

      loading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Notifications"),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (_, i) {
          final n = notifications[i];

          return Card(
            color: theme.colorScheme.surface,
            child: ListTile(
              leading: Icon(
                _iconForType(n["type"]),
                color: AppColors.primaryIndigo,
              ),
              title: Text(n["title"],
                  style: TextStyle(color: theme.colorScheme.onBackground)),
              subtitle: Text(n["message"],
                  style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.7))),
              trailing: Text(
                n["created_at"].substring(0, 10),
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case "KYC_APPROVED":
        return Icons.verified;
      case "KYC_REJECTED":
        return Icons.error;
      case "TRANSFER_RECEIVED":
        return Icons.call_received;
      default:
        return Icons.notifications;
    }
  }
}
