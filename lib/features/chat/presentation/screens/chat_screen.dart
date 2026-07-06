// lib/features/chat/presentation/screens/chat_screen.dart

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/cache/hive_cache.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/permissions/permission_manager.dart';

import '../../../../core/theme/app_colors.dart';

import '../cubit/chat_cubit.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final int collegeId;

  const ChatScreen({super.key, required this.collegeId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl = TextEditingController();

  final _scrollCtrl = ScrollController();

  late final ChatCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<ChatCubit>()..openChat(collegeId: widget.collegeId);
  }

  @override
  void dispose() {
    _cubit.closeChat();
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

  void _sendMessage(BuildContext ctx) {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    _msgCtrl.clear();

    final pm = PermissionManager(sl<HiveCache>());
    int? receiverId;
    if (pm.isManager) {
      receiverId = 38;
    }

    ctx
        .read<ChatCubit>()
        .sendMessage(text, widget.collegeId, receiverId: receiverId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isManager = PermissionManager(sl<HiveCache>()).isManager;

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 1,
          scrolledUnderElevation: 1,
          shadowColor: Colors.black12,
          titleSpacing: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
          ),
          title: Row(
            children: [
              Hero(
                tag: isManager
                    ? 'avatar_employee'
                    : 'avatar_${widget.collegeId}',
                child: CircleAvatar(
                  radius: 20.r,
                  backgroundColor: AppColors.navyBlue.withOpacity(0.1),
                  child: Icon(
                      isManager ? Icons.support_agent : Icons.account_balance,
                      color: AppColors.navyBlue,
                      size: 20.sp),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isManager ? 'موظف الجودة' : 'ممثل الجودة (الكلية)',
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Container(
                            width: 6.r,
                            height: 6.r,
                            decoration: const BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle)),
                        SizedBox(width: 4.w),
                        Text('متصل الآن',
                            style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11.sp,
                                color: AppColors.success,
                                height: 1)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: BlocConsumer<ChatCubit, ChatState>(
          listener: (ctx, state) {
            if (state is MessagesLoaded) _scrollToBottom();
          },
          builder: (ctx, state) {
            final messages =
                state is MessagesLoaded ? state.messages : <dynamic>[];
            final cache = sl<HiveCache>();
            final myData = cache.getUserData();
            final myEmail = myData?['email'] ?? '';

            return Column(
              children: [
                Expanded(
                  child: state is MessagesLoading
                      ? const Center(child: CircularProgressIndicator())
                      : messages.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(24.w),
                                    decoration: BoxDecoration(
                                        color: theme.primaryColor
                                            .withOpacity(0.05),
                                        shape: BoxShape.circle),
                                    child: Icon(Icons.waving_hand_outlined,
                                        size: 48.sp,
                                        color: theme.primaryColor
                                            .withOpacity(0.5)),
                                  ),
                                  SizedBox(height: 12.h),
                                  Text('قل مرحباً! 👋',
                                      style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollCtrl,
                              padding:
                                  EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 20.h),
                              itemCount: messages.length,
                              itemBuilder: (_, i) {
                                final msg =
                                    messages[i] as Map<String, dynamic>? ?? {};
                                final senderType = msg['senderType']
                                        ?.toString()
                                        .toLowerCase() ??
                                    '';
                                final pm = PermissionManager(sl<HiveCache>());
                                bool isMe = false;

                                if (pm.isManager) {
                                  isMe = (senderType == 'manager') ||
                                      msg['__temp'] == true;
                                } else {
                                  final senderEmail = msg['senderEmail'] ??
                                      msg['sender']?['email'] ??
                                      '';
                                  isMe = (senderType == 'employee') ||
                                      senderEmail == myEmail ||
                                      senderEmail == '__me__' ||
                                      msg['__temp'] == true;
                                }

                                return MessageBubble(
                                  content: msg['content'] ?? '',
                                  isMe: isMe,
                                  time: msg['sentAt'] ?? msg['createdAt'] ?? '',
                                  senderName: isMe
                                      ? 'أنت'
                                      : (msg['senderName'] ?? 'المرسل'),
                                );
                              },
                            ),
                ),
                if (state is ChatError)
                  Container(
                    color: AppColors.error.withOpacity(0.1),
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline,
                            size: 14.sp, color: AppColors.error),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(state.message,
                              style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12.sp,
                                  color: AppColors.error)),
                        ),
                      ],
                    ),
                  ),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    border: Border(
                        top: BorderSide(
                            color: Theme.of(context).dividerColor, width: 0.5)),
                  ),
                  padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 16.h),
                  child: Row(
                    children: [
                      Icon(Icons.attach_file_outlined,
                          size: 22.sp, color: Theme.of(context).disabledColor),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 14.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color,
                            borderRadius: BorderRadius.circular(24.r),
                            border: Border.all(
                                color: Theme.of(context).dividerColor,
                                width: 0.5),
                          ),
                          child: TextField(
                            controller: _msgCtrl,
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            maxLines: 4,
                            minLines: 1,
                            style:
                                TextStyle(fontFamily: 'Cairo', fontSize: 14.sp),
                            decoration: InputDecoration.collapsed(
                              hintText: 'اكتب رسالة...',
                              hintStyle: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 14.sp,
                                  color: Theme.of(context).disabledColor),
                            ),
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendMessage(ctx),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      GestureDetector(
                        onTap: () => _sendMessage(ctx),
                        child: Container(
                          width: 44.w,
                          height: 44.w,
                          decoration: const BoxDecoration(
                              color: AppColors.navyBlue,
                              shape: BoxShape.circle),
                          child: const Icon(Icons.send,
                              color: Colors.white, size: 18),
                        ),
                      ),
                      SizedBox(width: 8.w),
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
