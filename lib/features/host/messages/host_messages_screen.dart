import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/data/chat_service.dart';
import '../../../../core/state/app_state_scope.dart';

class HostMessagesScreen extends StatefulWidget {
  const HostMessagesScreen({super.key});

  @override
  State<HostMessagesScreen> createState() => _HostMessagesScreenState();
}

class _HostMessagesScreenState extends State<HostMessagesScreen> {
  List<Map<String, dynamic>> _conversations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }
  
  // Reload when returning (in case new messages) - basic implementation
  @override
  void didChangeDependencies() {
     super.didChangeDependencies();
     _loadConversations(); 
  }

  Future<void> _loadConversations() async {
    final currentUser = AppStateScope.of(context).currentUser;
    if (currentUser == null) return;
    
    // Also init chat service just in case
    await ChatService().init();

    final convs = await ChatService().getConversationsForUserAsync(currentUser.id);
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
        // leading: const BackButton(), // Default back button is fine if pushed
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
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _conversations.length,
                  itemBuilder: (context, index) {
                    final convo = _conversations[index];
                    final String convId = convo['id'];
                    final String driverId = convo['driverId'] ?? '';
                    final String driverName = convo['driverName'] ?? 'Driver';
                    final String hostId = convo['hostId'] ?? '';
                    final String hostName = convo['hostName'] ?? 'Host';
                    final String spotTitle = convo['spotTitle'] ?? 'Parking Spot';
                    
                    // Identify other user
                    final bool isMeDriver = currentUser.id == driverId;
                    final String otherName = isMeDriver ? hostName : driverName;
                    final String myRoleLabel = isMeDriver ? 'Οδηγός' : 'Host';
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: InkWell(
                        onTap: () {
                           context.push(Uri(path: '/chat', queryParameters: {'id': convId, 'name': otherName}).toString());
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: const Color(0xFFEFF4FF),
                                child: Text(otherName.isNotEmpty ? otherName[0].toUpperCase() : '?', 
                                    style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(otherName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
