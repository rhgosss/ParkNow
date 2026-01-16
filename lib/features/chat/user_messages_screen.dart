import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/data/chat_service.dart';
import '../../core/state/app_state_scope.dart';

/// Messages screen for DRIVER/USER mode - shows only conversations where user is the driver
class UserMessagesScreen extends StatefulWidget {
  const UserMessagesScreen({super.key});

  @override
  State<UserMessagesScreen> createState() => _UserMessagesScreenState();
}

class _UserMessagesScreenState extends State<UserMessagesScreen> {
  List<Map<String, dynamic>> _conversations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }
  
  @override
  void didChangeDependencies() {
     super.didChangeDependencies();
     _loadConversations(); 
  }

  Future<void> _loadConversations() async {
    final currentUser = AppStateScope.of(context).currentUser;
    if (currentUser == null) return;
    
    await ChatService().init();

    // USER/DRIVER MODE: Only show conversations where user is the DRIVER
    final convs = await ChatService().getConversationsForDriver(currentUser.id);
    if (mounted) {
      setState(() {
        _conversations = convs;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AppStateScope.of(context).currentUser;
    if (currentUser == null) return const Scaffold(body: Center(child: Text('Error: Not logged in')));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Μηνύματα'),
        automaticallyImplyLeading: true,
      ),
      body: _loading 
          ? const Center(child: CircularProgressIndicator())
          : _conversations.isEmpty 
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text('Δεν υπάρχουν μηνύματα', style: TextStyle(color: Colors.grey, fontSize: 16)),
                      const SizedBox(height: 8),
                      const Text('Τα μηνύματα θα εμφανιστούν εδώ όταν κάνετε κράτηση', 
                        style: TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _conversations.length,
                  itemBuilder: (context, index) {
                    final convo = _conversations[index];
                    final String convId = convo['id'];
                    final String hostName = convo['hostName'] ?? 'Host';
                    final String spotTitle = convo['spotTitle'] ?? 'Parking Spot';
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: InkWell(
                        onTap: () {
                           context.push(Uri(path: '/chat', queryParameters: {'id': convId, 'name': hostName}).toString());
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: const Color(0xFFEFF4FF),
                                child: Text(hostName.isNotEmpty ? hostName[0].toUpperCase() : '?', 
                                    style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(hostName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(spotTitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
