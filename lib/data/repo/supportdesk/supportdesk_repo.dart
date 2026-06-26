import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/core/network/api_client.dart';
import 'package:firstedu/core/network/api_endpoint.dart';
import 'package:firstedu/data/models/api_models/supportdesk/createticket_models.dart';
import 'package:firstedu/data/models/api_models/supportdesk/messagefetch_models.dart';
import 'package:firstedu/data/models/api_models/supportdesk/sendmessage_models.dart';
import 'package:firstedu/data/models/api_models/supportdesk/ticketlist_models.dart';

class SupportDeskRepository {
  final ApiClient _apiClient;
  SupportDeskRepository(this._apiClient);

  static const _base = '${ApiEndpoint.appBaseUrl}/support/tickets';

  // ── 1. Create ticket ───────────────────────────────────────────────────────
  Future<CreateTicketModels> createTicket({
    required String subject,
    required String description,
    String? category,
  }) async {
    try {
      final res = await _apiClient.post(
        _base,
        data: {
          'subject': subject,
          'description': description,
          if (category != null && category.isNotEmpty) 'category': category,
        },
      );
      _checkSuccess(res.data);
      return CreateTicketModels.fromJson(res.data as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException('Failed to create ticket. Please try again.');
    }
  }

  // ── 2. Get ticket list ─────────────────────────────────────────────────────
  Future<TicketListModel> getTickets({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final query = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (status != null && status.isNotEmpty) 'status': status,
      };
      final uri = Uri.parse(_base).replace(queryParameters: query).toString();
      final res = await _apiClient.get(uri);
      _checkSuccess(res.data);
      return TicketListModel.fromJson(res.data as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException('Failed to fetch tickets.');
    }
  }

  // ── 3. Get messages for a ticket ───────────────────────────────────────────
  Future<MessageFetchModels> getMessages({
    required String ticketId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final query = {'page': page.toString(), 'limit': limit.toString()};
      final uri = Uri.parse(
        '$_base/$ticketId/messages',
      ).replace(queryParameters: query).toString();
      final res = await _apiClient.get(uri);
      _checkSuccess(res.data);
      return MessageFetchModels.fromJson(res.data as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException('Failed to fetch messages.');
    }
  }

  // ── 4. Send message ────────────────────────────────────────────────────────
  Future<SendMessageModels> sendMessage({
    required String ticketId,
    required String message,
    List<Map<String, String>>? attachments,
  }) async {
    try {
      final res = await _apiClient.post(
        '$_base/$ticketId/messages',
        data: {
          'message': message,
          if (attachments != null && attachments.isNotEmpty)
            'attachments': attachments,
        },
      );
      _checkSuccess(res.data);
      return SendMessageModels.fromJson(res.data as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException('Failed to send message.');
    }
  }

  // ── Helper ─────────────────────────────────────────────────────────────────
  void _checkSuccess(dynamic data) {
    final map = data as Map<String, dynamic>?;
    if (map?['success'] != true) {
      throw AppException(
        map?['message']?.toString().isNotEmpty == true
            ? map!['message']
            : 'Something went wrong.',
      );
    }
  }
}
