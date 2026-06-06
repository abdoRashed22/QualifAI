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

class ChatScreen extends StatefulWidget {
  final int collegeId;

  const ChatScreen({super.key, required this.collegeId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl = TextEditingController();

  final _scrollCtrl = ScrollController();

  // ✅ FIX: store cubit reference so we can call it after dispose check

  late final ChatCubit _cubit;

  @override
  void initState() {
    super.initState();

    print('Chat Screen CollegeId => ${widget.collegeId}');

    _cubit = sl<ChatCubit>()..openChat(widget.collegeId);
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

    // ✅ FIX: clear immediately for better UX, then send

    _msgCtrl.clear();

    // ✅ إضافة logic مدير الجودة لإرسال الرسالة إلى موظف الجودة مباشرة
    final pm = PermissionManager(sl<HiveCache>());
    int? receiverId;
    if (pm.isManager) {
      receiverId = 38; // المعرّف الخاص بموظف الجودة
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
            // ✅ FIX: scroll to bottom on every MessagesLoaded (including after send)

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
                // Messages list

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
                                  // إبقاء المنطق القديم لموظف الجودة كخيار احتياطي لضمان عدم كسره
                                  final senderEmail = msg['senderEmail'] ??
                                      msg['sender']?['email'] ??
                                      '';
                                  isMe = (senderType == 'employee') ||
                                      senderEmail == myEmail ||
                                      senderEmail == '__me__' ||
                                      msg['__temp'] == true;
                                }

                                return _MessageBubble(
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

                // ✅ FIX: show error snackbar if send fails

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

                // Input bar

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
                      // Send button

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

                      // Text input

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

                            // ✅ FIX: send on done keyboard action

                            textInputAction: TextInputAction.send,

                            onSubmitted: (_) => _sendMessage(ctx),
                          ),
                        ),
                      ),

                      SizedBox(width: 8.w),

                      Icon(Icons.attach_file_outlined,
                          size: 22.sp, color: Theme.of(context).disabledColor),
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

  Widget _buildComposer(BuildContext ctx) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
          16.w, 10.h, 16.w, MediaQuery.of(context).padding.bottom + 10.h),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, -2),
              blurRadius: 10),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Attachments
          IconButton(
            icon: Icon(Icons.add_circle_outline,
                color: theme.disabledColor, size: 26.sp),
            onPressed: () {}, // Action for attachments
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          SizedBox(width: 12.w),

          // Text Field
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
              ),
              child: TextField(
                controller: _msgCtrl,
                maxLines: 5,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                style: TextStyle(fontFamily: 'Cairo', fontSize: 14.sp),
                onChanged: (val) =>
                    setState(() {}), // Refresh to toggle send button
                decoration: InputDecoration(
                  hintText: 'اكتب رسالة...',
                  hintStyle: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13.sp,
                      color: theme.disabledColor),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),

          // Send Button
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _msgCtrl.text.trim().isNotEmpty
                ? GestureDetector(
                    onTap: () => _sendMessage(ctx),
                    child: CircleAvatar(
                      radius: 22.r,
                      backgroundColor: AppColors.navyBlue,
                      child: Icon(Icons.send, color: Colors.white, size: 20.sp),
                    ),
                  )
                : CircleAvatar(
                    radius: 22.r,
                    backgroundColor: theme.scaffoldBackgroundColor,
                    child: Icon(Icons.mic_none,
                        color: theme.disabledColor, size: 24.sp),
                  ),
          ),
        ],
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
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Container(
                  padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 6.h),
                  decoration: BoxDecoration(
                    color: isMe
                        ? AppColors.navyBlue
                        : (theme.brightness == Brightness.dark
                            ? Colors.grey[800]
                            : const Color(0xFFF2F4F8)),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                      bottomRight:
                          isMe ? Radius.circular(2.r) : Radius.circular(16.r),
                      bottomLeft:
                          isMe ? Radius.circular(16.r) : Radius.circular(2.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          offset: const Offset(0, 1),
                          blurRadius: 2),
                    ],
                  ),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.end,
                    alignment: WrapAlignment.end,
                    children: [
                      Text(
                        content,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14.sp,
                          color: isMe
                              ? Colors.white
                              : (theme.brightness == Brightness.dark
                                  ? Colors.white
                                  : AppColors.textDark),
                          height: 1.4,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(time),
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 10.sp,
                              color:
                                  isMe ? Colors.white70 : theme.disabledColor,
                            ),
                          ),
                          if (isMe) ...[
                            SizedBox(width: 4.w),
                            Icon(Icons.done_all,
                                size: 14.sp, color: Colors.white70),
                          ]
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
    } catch (_) {
      return iso;
    }
  }
}
