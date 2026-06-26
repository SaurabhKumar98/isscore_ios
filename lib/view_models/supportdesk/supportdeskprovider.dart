import 'package:firstedu/core/localstorage/localstorage.dart';
import 'package:firstedu/core/network/api_endpoint.dart';
import 'package:firstedu/data/models/api_models/supportdesk/messagefetch_models.dart';
import 'package:firstedu/data/models/api_models/supportdesk/ticketlist_models.dart';
import 'package:firstedu/data/repo/supportdesk/supportdesk_repo.dart';
import 'package:firstedu/data/repo/supportdesk/supportdesk_websocket.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:flutter/widgets.dart';

class SupportDeskProvider extends ChangeNotifier {
  final SupportDeskRepository _repo;
  final SupportDeskSocketService _socket = SupportDeskSocketService.instance;

  SupportDeskProvider(this._repo);

  // ── Ticket list ────────────────────────────────────────────────────────────
  List<Ticket> _tickets = [];
  List<Ticket> get tickets => _tickets;

  bool _isLoadingTickets = false;
  bool get isLoadingTickets => _isLoadingTickets;

  bool _isCreatingTicket = false;
  bool get isCreatingTicket => _isCreatingTicket;

  String _ticketsError = '';
  String get ticketsError => _ticketsError;

  // ── Messages (keyed by ticketId) ───────────────────────────────────────────
  final Map<String, List<MessageData>> _messages = {};
  List<MessageData> messagesFor(String ticketId) => _messages[ticketId] ?? [];

  final Map<String, bool> _isLoadingMessages = {};
  bool isLoadingMessagesFor(String ticketId) =>
      _isLoadingMessages[ticketId] ?? false;

  final Map<String, bool> _isSendingMessage = {};
  bool isSendingMessageFor(String ticketId) =>
      _isSendingMessage[ticketId] ?? false;

  String _messageError = '';
  String get messageError => _messageError;

  // ── Typing indicator ───────────────────────────────────────────────────────
  String? _agentTypingTicketId;
  bool isAgentTyping(String ticketId) => _agentTypingTicketId == ticketId;

  // ── Active socket room ─────────────────────────────────────────────────────
  String? _activeTicketId;

  // ─────────────────────────────────────────────────────────────────────────
  // FETCH TICKETS
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> fetchTickets() async {
    _isLoadingTickets = true;
    _ticketsError = '';
    notifyListeners();

    try {
      final res = await _repo.getTickets();
      _tickets = res.data ?? [];
    } catch (e) {
      _ticketsError = e.toString();
      AppToast.errorGlobal(
        title: 'Failed to load tickets',
        message: e.toString(),
      );
    } finally {
      _isLoadingTickets = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CREATE TICKET
  // ─────────────────────────────────────────────────────────────────────────
  Future<String?> createTicket({
    required String subject,
    required String description,
    String? category,
  }) async {
    _isCreatingTicket = true;
    _ticketsError = '';
    notifyListeners();

    try {
      final res = await _repo.createTicket(
        subject: subject,
        description: description,
        category: category,
      );
      final td = res.ticketData;
      if (res.success == true && td != null) {
        _tickets.insert(
          0,
          Ticket(
            id: td.id,
            ticketNumber: td.ticketNumber,
            subject: td.subject,
            description: td.description,
            category: td.category,
            priority: td.priority,
            status: td.status,
            openedAt: td.openedAt,
            createdAt: td.createdAt,
            updatedAt: td.updatedAt,
            lastMessageAt: td.lastMessageAt,
          ),
        );
        AppToast.successGlobal(
          title: 'Ticket Created',
          message: 'Your support ticket has been submitted successfully.',
        );
        notifyListeners();
        return td.id;
      }
      return null;
    } catch (e) {
      _ticketsError = e.toString();
      AppToast.errorGlobal(
        title: 'Failed to Create Ticket',
        message: e.toString(),
      );
      notifyListeners();
      return null;
    } finally {
      _isCreatingTicket = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FETCH MESSAGES
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> fetchMessages(String ticketId) async {
    _isLoadingMessages[ticketId] = true;
    _messageError = '';
    notifyListeners();

    try {
      final res = await _repo.getMessages(ticketId: ticketId);
      // ✅ MERGE — never wipe cached messages, just add new ones
      final fresh = res.data ?? [];
      final existing = _messages[ticketId] ?? [];
      final existingIds = existing.map((m) => m.id).toSet();
      final newMsgs = fresh.where((m) => !existingIds.contains(m.id)).toList();
      _messages[ticketId] = [...existing, ...newMsgs]
        ..sort((a, b) => (a.createdAt ?? "").compareTo(b.createdAt ?? ""));
    } catch (e) {
      _messageError = e.toString();
      AppToast.errorGlobal(
        title: 'Failed to load messages',
        message: e.toString(),
      );
    } finally {
      _isLoadingMessages[ticketId] = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SEND MESSAGE  (optimistic insert)
  // ─────────────────────────────────────────────────────────────────────────
  Future<bool> sendMessage(String ticketId, String text) async {
    if (text.trim().isEmpty) return false;

    // ✅ Show message immediately
    final optimisticId = 'optimistic_${DateTime.now().millisecondsSinceEpoch}';
    final optimisticMsg = MessageData(
      id: optimisticId,
      ticket: ticketId,
      senderType: 'User',
      message: text.trim(),
      attachments: [],
      isRead: false,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
    _messages[ticketId] ??= [];
    _messages[ticketId]!.add(optimisticMsg);
    _isSendingMessage[ticketId] = true;
    _messageError = '';
    notifyListeners();

    try {
      final res = await _repo.sendMessage(ticketId: ticketId, message: text);
      final raw = res.data;

      if (res.success == true && raw != null) {
        // Replace optimistic with real server message
        final realMsg = MessageData(
          id: raw.id,
          ticket: ticketId,
          senderType: raw.senderType,
          message: raw.message,
          attachments: [],
          isRead: raw.isRead,
          readAt: raw.readAt?.toString(),
          createdAt: raw.createdAt,
          updatedAt: raw.updatedAt,
        );
        final idx = _messages[ticketId]!.indexWhere(
          (m) => m.id == optimisticId,
        );
        if (idx != -1) {
          _messages[ticketId]![idx] = realMsg;
        } else {
          _messages[ticketId]!.add(realMsg);
        }
        notifyListeners();
        return true;
      } else {
        _messages[ticketId]!.removeWhere((m) => m.id == optimisticId);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _messages[ticketId]!.removeWhere((m) => m.id == optimisticId);
      _messageError = e.toString();
      AppToast.errorGlobal(
        title: 'Failed to Send Message',
        message: e.toString(),
      );
      notifyListeners();
      return false;
    } finally {
      _isSendingMessage[ticketId] = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // WEBSOCKET
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> connectSocket() async {
    try {
      final token = await UserLocalStorage.getAccessToken();
      if (token == null || token.isEmpty) return;

      await _socket.connect(token, ApiEndpoint.socketurl);

      // ✅ Extract ticketId robustly — ticket field can be:
      //    - plain string:        "69b25d9c..."
      //    - nested object:       {_id: "69b25d9c...", ticketNumber: ..., subject: ...}
      _socket.onNewMessage = (data) {
        debugPrint('🎧 onNewMessage raw: $data');

        final ticketId = _extractTicketId(data);
        if (ticketId == null) {
          debugPrint('⚠️ onNewMessage: could not extract ticketId from $data');
          return;
        }

        // Only process messages for the active open ticket
        if (ticketId != _activeTicketId) {
          debugPrint(
            '⚠️ onNewMessage: ticketId $ticketId != active $_activeTicketId — skipping UI update',
          );
          // Still store so it's ready when user opens that ticket
          final msg = MessageData.fromJson(data);
          _messages[ticketId] ??= [];
          if (!_messages[ticketId]!.any((m) => m.id == msg.id)) {
            _messages[ticketId]!.add(msg);
          }
          return;
        }

        final msg = MessageData.fromJson(data);
        _messages[ticketId] ??= [];

        // ✅ If it's our own message echoed back from socket,
        //    replace the optimistic entry instead of duplicating
        final optimisticIdx = _messages[ticketId]!.indexWhere(
          (m) => m.id?.startsWith('optimistic_') == true,
        );

        final alreadyExists = _messages[ticketId]!.any((m) => m.id == msg.id);

        if (alreadyExists) {
          debugPrint('🎧 onNewMessage: duplicate skipped ${msg.id}');
          return;
        }

        if (msg.senderType == 'User' && optimisticIdx != -1) {
          // Replace optimistic with socket-confirmed message
          _messages[ticketId]![optimisticIdx] = msg;
          debugPrint('🎧 onNewMessage: replaced optimistic with ${msg.id}');
        } else {
          // ✅ Agent message — add directly → shows in real time
          _messages[ticketId]!.add(msg);
          debugPrint(
            '🎧 onNewMessage: added ${msg.senderType} message ${msg.id}',
          );
        }
        notifyListeners();
      };

      _socket.onTicketUpdated = (data) {
        final ticketId = data['_id']?.toString();
        if (ticketId == null) return;
        final idx = _tickets.indexWhere((t) => t.id == ticketId);
        if (idx == -1) return;
        final old = _tickets[idx];
        _tickets[idx] = Ticket(
          id: old.id,
          ticketNumber: old.ticketNumber,
          subject: old.subject,
          description: old.description,
          category: old.category,
          priority: old.priority,
          status: data['status']?.toString() ?? old.status,
          assignedTo: old.assignedTo,
          openedAt: old.openedAt,
          resolvedAt: old.resolvedAt,
          closedAt: old.closedAt,
          lastMessageAt: data['lastMessageAt']?.toString() ?? old.lastMessageAt,
          createdAt: old.createdAt,
          updatedAt: old.updatedAt,
        );
        notifyListeners();
      };

      _socket.onTyping = (ticketId, isStopped) {
        if (isStopped) {
          // ✅ typing_stop received — clear immediately
          if (_agentTypingTicketId == ticketId) {
            _agentTypingTicketId = null;
            notifyListeners();
          }
        } else {
          // ✅ typing_start received — show indicator, auto-clear after 3s
          _agentTypingTicketId = ticketId;
          notifyListeners();
          Future.delayed(const Duration(seconds: 3), () {
            if (_agentTypingTicketId == ticketId) {
              _agentTypingTicketId = null;
              notifyListeners();
            }
          });
        }
      };

      _socket.onError = (msg) => debugPrint('⚠️ SupportSocket error: $msg');

      // ✅ Join room NOW if already in a ticket screen
      if (_activeTicketId != null) {
        _socket.joinTicket(_activeTicketId!);
      }

      debugPrint('🎧 SupportSocket ready');
    } catch (e) {
      debugPrint('⚠️ SupportSocket connect failed: $e');
    }
  }

  // ── Extract ticketId from any socket message shape ─────────────────────────
  String? _extractTicketId(Map<String, dynamic> data) {
    final raw = data['ticket'];
    if (raw == null) return null;
    if (raw is String && raw.isNotEmpty) return raw;
    if (raw is Map) {
      return raw['_id']?.toString() ?? raw['id']?.toString();
    }
    return null;
  }

  // ── Room management ────────────────────────────────────────────────────────
  void enterTicket(String ticketId) {
    _activeTicketId = ticketId;
    // ✅ Join room whether socket is connected now or will connect shortly
    if (_socket.isConnected) {
      _socket.joinTicket(ticketId);
    }
    // Also try joining after a short delay in case socket is still connecting
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_activeTicketId == ticketId && _socket.isConnected) {
        _socket.joinTicket(ticketId);
      }
    });
  }

  void exitTicket(String ticketId) {
    if (_socket.isConnected) _socket.leaveTicket(ticketId);
    _activeTicketId = null;
  }

  void emitTyping(String ticketId) => _socket.emitTyping(ticketId);

  void disconnectSocket() => _socket.disconnect();

  void clearErrors() {
    _ticketsError = '';
    _messageError = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _socket.disconnect();
    super.dispose();
  }
}
