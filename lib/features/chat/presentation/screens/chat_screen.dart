// lib/features/chat/presentation/screens/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/cache/hive_cache.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/chat_cubit.dart';

class ChatScreen extends StatefulWidget {
  final int collegeId;
  const ChatScreen({super.key, required this.collegeId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ChatCubit>()..openChat(widget.collegeId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ø§Ù„Ù…Ø±Ø§Ø¬Ø¹'),
          actions: [
            Padding(
              padding: EdgeInsets.only(left: 16.w),
              child: Row(
                children: [
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                  ),
                  SizedBox(width: 4.w),
                  Text('Ù…ØªØµÙ„', style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp, color: AppColors.success)),
                ],
              ),
            ),
          ],
        ),
        body: BlocConsumer<ChatCubit, ChatState>(
          listener: (ctx, state) {
            if (state is MessagesLoaded) _scrollToBottom();
          },
          builder: (ctx, state) {
            final messages = state is MessagesLoaded ? state.messages : <dynamic>[];
            final cache = sl<HiveCache>();
            final myData = cache.getUserData();
            final myEmail = myData?['email'] ?? '';

            return Column(
              children: [
                // Messages
                Expanded(
                  child: state is MessagesLoading
                      ? const Center(child: CircularProgressIndicator())
                      : messages.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('ðŸ’¬', style: TextStyle(fontSize: 48.sp)),
                                  SizedBox(height: 12.h),
                                  const Text('Ø§Ø¨Ø¯Ø£ Ø§Ù„Ù…Ø­Ø§Ø¯Ø«Ø©', style: TextStyle(fontFamily: 'Cairo')),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollCtrl,
                              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
                              itemCount: messages.length,
                              itemBuilder: (_, i) {
                                final msg = messages[i] as Map<String, dynamic>? ?? {};
                                final senderEmail = msg['senderEmail'] ?? msg['sender']?['email'] ?? '';
                                final isMe = senderEmail == myEmail;
                                return _MessageBubble(
                                  content: msg['content'] ?? '',
                                  isMe: isMe,
                                  time: msg['sentAt'] ?? msg['createdAt'] ?? '',
                                  senderName: isMe ? 'Ø£Ù†Øª' : (msg['senderName'] ?? 'Ø§Ù„Ù…Ø±Ø§Ø¬Ø¹'),
                                );
                              },
                            ),
                ),
                // Input bar
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    border: Border(top: BorderSide(color: Theme.of(context).dividerColor, width: 0.5)),
                  ),
                  padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 16.h),
                  child: Row(
                    children: [
                      // Send button
                      GestureDetector(
                        onTap: () {
                          final text = _msgCtrl.text.trim();
                          if (text.isEmpty) return;
                          ctx.read<ChatCubit>().sendMessage(text, widget.collegeId);
                          _msgCtrl.clear();
                        },
                        child: Container(
                          width: 44.w,
                          height: 44.w,
                          decoration: const BoxDecoration(color: AppColors.navyBlue, shape: BoxShape.circle),
                          child: const Icon(Icons.send, color: Colors.white, size: 18),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      // Text input
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color,
                            borderRadius: BorderRadius.circular(24.r),
                            border: Border.all(color: Theme.of(context).dividerColor, width: 0.5),
                          ),
                          child: TextField(
                            controller: _msgCtrl,
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            maxLines: 4,
                            minLines: 1,
                            style: TextStyle(fontFamily: 'Cairo', fontSize: 14.sp),
                            decoration: InputDecoration.collapsed(
                              hintText: 'Ø§ÙƒØªØ¨ Ø±Ø³Ø§Ù„Ø©...',
                              hintStyle: TextStyle(fontFamily: 'Cairo', fontSize: 14.sp, color: Theme.of(context).disabledColor),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.attach_file_outlined, size: 22.sp, color: Theme.of(context).disabledColor),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String content;
  final bool isMe;
  final String time;
  final String senderName;

  const _MessageBubble({
    required this.content,
    required this.isMe,
    required this.time,
    required this.senderName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            Text(senderName, style: TextStyle(fontFamily: 'Cairo', fontSize: 11.sp, color: Theme.of(context).disabledColor)),
            SizedBox(height: 4.h),
          ],
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) ...[
                CircleAvatar(
                  radius: 16.r,
                  backgroundColor: AppColors.blue.withOpacity(0.15),
                  child: Icon(Icons.person_outline, size: 16.sp, color: AppColors.blue),
                ),
                SizedBox(width: 8.w),
              ],
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.navyBlue : Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                      bottomLeft: isMe ? Radius.circular(16.r) : Radius.circular(4.r),
                      bottomRight: isMe ? Radius.circular(4.r) : Radius.circular(16.r),
                    ),
                    border: isMe ? null : Border.all(color: Theme.of(context).dividerColor, width: 0.5),
                  ),
                  child: Text(
                    content,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14.sp,
                      color: isMe ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ),
              if (isMe) ...[
                SizedBox(width: 8.w),
                CircleAvatar(
                  radius: 16.r,
                  backgroundColor: AppColors.navyBlue.withOpacity(0.15),
                  child: Icon(Icons.person, size: 16.sp, color: AppColors.navyBlue),
                ),
              ],
            ],
          ),
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              _formatTime(time),
              style: TextStyle(fontFamily: 'Cairo', fontSize: 10.sp, color: Theme.of(context).disabledColor),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } catch (_) { return iso; }
  }
}
