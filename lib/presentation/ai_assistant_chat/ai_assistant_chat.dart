import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/chat_message.dart';
import '../../services/openai_service.dart';
import './widgets/message_bubble_widget.dart';
import './widgets/message_input_widget.dart';

class AiAssistantChatScreen extends StatefulWidget {
  const AiAssistantChatScreen({super.key});

  @override
  State<AiAssistantChatScreen> createState() => _AiAssistantChatScreenState();
}

class _AiAssistantChatScreenState extends State<AiAssistantChatScreen> {
  final _openAIClient = OpenAIClient(OpenAIService().dio);
  final _messages = <ChatMessage>[];
  final _scrollController = ScrollController();

  bool _isLoading = false;
  StreamSubscription<String>? _streamSubscription;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().toString(),
        role: 'assistant',
        content:
            'Hello! I\'m your FhoneOS AI assistant. How can I help you today?',
        timestamp: DateTime.now(),
      ));
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      id: DateTime.now().toString(),
      role: 'user',
      content: text,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final conversationHistory = _messages
          .map((msg) => Message(
                role: msg.role,
                content: [
                  {'type': 'text', 'text': msg.content}
                ],
              ))
          .toList();

      final assistantMessageId = DateTime.now().toString();
      final assistantMessage = ChatMessage(
        id: assistantMessageId,
        role: 'assistant',
        content: '',
        timestamp: DateTime.now(),
        isStreaming: true,
      );

      setState(() {
        _messages.add(assistantMessage);
      });

      _scrollToBottom();

      final stream = _openAIClient.streamContentOnly(
        messages: conversationHistory,
        model: 'gpt-5-mini',
        reasoningEffort: 'minimal',
      );

      _streamSubscription = stream.listen(
        (chunk) {
          final index = _messages.indexWhere((m) => m.id == assistantMessageId);
          if (index != -1) {
            setState(() {
              _messages[index] = _messages[index].copyWith(
                content: _messages[index].content + chunk,
              );
            });
            _scrollToBottom();
          }
        },
        onDone: () {
          final index = _messages.indexWhere((m) => m.id == assistantMessageId);
          if (index != -1) {
            setState(() {
              _messages[index] = _messages[index].copyWith(
                isStreaming: false,
              );
              _isLoading = false;
            });
          }
        },
        onError: (error) {
          setState(() {
            _messages.removeWhere((m) => m.id == assistantMessageId);
            _messages.add(ChatMessage(
              id: DateTime.now().toString(),
              role: 'assistant',
              content: 'Sorry, I encountered an error: ${error.toString()}',
              timestamp: DateTime.now(),
            ));
            _isLoading = false;
          });
          _scrollToBottom();
        },
      );
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          id: DateTime.now().toString(),
          role: 'assistant',
          content: 'Sorry, I encountered an error: ${e.toString()}',
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _clearConversation() {
    setState(() {
      _messages.clear();
      _addWelcomeMessage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _clearConversation,
            tooltip: 'Clear conversation',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Start a conversation',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return MessageBubbleWidget(
                        message: message,
                        isUser: message.role == 'user',
                      );
                    },
                  ),
          ),
          MessageInputWidget(
            onSend: _sendMessage,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}
