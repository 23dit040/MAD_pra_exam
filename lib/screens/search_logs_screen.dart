import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/event.dart';
import 'package:flutter_application_1/models/checkin.dart';
import 'package:flutter_application_1/services/local_storage_service.dart';

class SearchAndLogsScreen extends StatefulWidget {
  final Event event;

  const SearchAndLogsScreen({Key? key, required this.event}) : super(key: key);

  @override
  State<SearchAndLogsScreen> createState() => _SearchAndLogsScreenState();
}

class _SearchAndLogsScreenState extends State<SearchAndLogsScreen> {
  final _searchController = TextEditingController();
  List<CheckIn> _searchResults = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_performSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() => _searchQuery = query);

    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    final eventCheckIns = LocalStorageService.getEventCheckIns(widget.event.id);

    final results = eventCheckIns
        .where((checkIn) =>
            checkIn.participantId.toLowerCase().contains(query) ||
            checkIn.id.toLowerCase().contains(query))
        .toList();

    setState(() => _searchResults = results);
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'success':
        return 'Checked In';
      case 'duplicate':
        return 'Duplicate';
      case 'full':
        return 'Event Full';
      case 'failed':
        return 'Failed';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'success':
        return Colors.green;
      case 'duplicate':
        return Colors.orange;
      case 'full':
        return Colors.red;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventCheckIns = LocalStorageService.getEventCheckIns(widget.event.id);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        title: const Text('Search & Logs'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Participant ID',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          // Results Summary
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _searchQuery.isEmpty
                      ? 'Total Check-ins: ${eventCheckIns.length}'
                      : 'Found: ${_searchResults.length}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                if (_searchQuery.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      _searchController.clear();
                    },
                    child: const Text('Clear'),
                  ),
              ],
            ),
          ),

          // List of Results
          Expanded(
            child: _searchQuery.isEmpty
                ? ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: eventCheckIns.length,
                    itemBuilder: (context, index) {
                      final checkIn = eventCheckIns[eventCheckIns.length - 1 - index];
                      return _buildCheckInCard(checkIn);
                    },
                  )
                : _searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No results found',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final checkIn = _searchResults[index];
                          return _buildCheckInCard(checkIn);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInCard(CheckIn checkIn) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  checkIn.participantId,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(checkIn.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusLabel(checkIn.status),
                    style: TextStyle(
                      color: _getStatusColor(checkIn.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  checkIn.checkedInAt.toString().split('.')[0],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  checkIn.synced ? Icons.cloud_done : Icons.cloud_upload,
                  size: 16,
                  color: checkIn.synced ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  checkIn.synced ? 'Synced' : 'Pending sync',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: checkIn.synced ? Colors.green : Colors.orange,
                      ),
                ),
              ],
            ),
            if (checkIn.errorMessage != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  checkIn.errorMessage!,
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
