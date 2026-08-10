import 'package:flutter/material.dart';

import '../../features/auth/services/auth_services_instance.dart';
import '../../features/profile/services/profile_avatar_service.dart';

class MarketHeader extends StatelessWidget {
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;
  final String searchHint;
  final TextEditingController? searchController;
  final bool autofocus;
  final bool showBackButton;
  final VoidCallback? onProfileTap;
  final List<MarketNotification> notifications;

  const MarketHeader({
    super.key,
    required this.onSearchChanged,
    this.onSearchSubmitted,
    this.searchHint = 'Buscar productos',
    this.searchController,
    this.autofocus = false,
    this.showBackButton = false,
    this.onProfileTap,
    this.notifications = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff2D006B),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          InkWell(
            onTap: showBackButton
                ? () => Navigator.maybePop(context)
                : onProfileTap,
            customBorder: const CircleBorder(),
            child: showBackButton
                ? const CircleAvatar(child: Icon(Icons.arrow_back))
                : const _HeaderProfileAvatar(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: searchController,
              autofocus: autofocus,
              onChanged: onSearchChanged,
              onSubmitted: onSearchSubmitted,
              textInputAction: onSearchSubmitted == null
                  ? TextInputAction.done
                  : TextInputAction.search,
              decoration: InputDecoration(
                hintText: searchHint,
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: () => _showNotifications(context),
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                    size: 30,
                  ),
                  if (notifications.any((notification) => !notification.isRead))
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: const Color(0xffFF7A00),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xff2D006B),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NotificationsSheet(notifications: notifications),
    );
  }
}

class _HeaderProfileAvatar extends StatefulWidget {
  const _HeaderProfileAvatar();

  @override
  State<_HeaderProfileAvatar> createState() => _HeaderProfileAvatarState();
}

class _HeaderProfileAvatarState extends State<_HeaderProfileAvatar> {
  String get _userId {
    final user = authServices.user;
    if (user?.id.trim().isNotEmpty == true) return user!.id.trim();
    if (user?.email.trim().isNotEmpty == true) return user!.email.trim();
    return 'current-user';
  }

  @override
  void initState() {
    super.initState();
    profileAvatarService.load(_userId);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: profileAvatarService,
      builder: (context, child) {
        final bytes = profileAvatarService.isLoadedFor(_userId)
            ? profileAvatarService.photoBytes
            : null;
        return CircleAvatar(
          backgroundImage: bytes == null ? null : MemoryImage(bytes),
          child: bytes == null ? const Icon(Icons.person) : null,
        );
      },
    );
  }
}

class MarketNotification {
  final String title;
  final String message;
  final String timeLabel;
  final IconData icon;
  final bool isRead;

  const MarketNotification({
    required this.title,
    required this.message,
    required this.timeLabel,
    this.icon = Icons.notifications_outlined,
    this.isRead = false,
  });
}

class _NotificationsSheet extends StatelessWidget {
  final List<MarketNotification> notifications;

  const _NotificationsSheet({required this.notifications});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          minHeight: 300,
          maxHeight: MediaQuery.sizeOf(context).height * 0.68,
        ),
        decoration: const BoxDecoration(
          color: Color(0xffFFFCFF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Notificaciones',
                      style: TextStyle(
                        color: Color(0xff2D006B),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Cerrar',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            if (notifications.isEmpty)
              const Expanded(child: _EmptyNotifications())
            else
              Flexible(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: notifications.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) =>
                      _NotificationTile(notification: notifications[index]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: const BoxDecoration(
                color: Color(0xffEEE6FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_off_outlined,
                color: Color(0xff5E2CA5),
                size: 42,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No tienes notificaciones',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xff2D006B),
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Cuando haya novedades sobre tus compras, ventas u ofertas, aparecerán aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, height: 1.35),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final MarketNotification notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : const Color(0xffF1F8FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification.isRead
              ? const Color(0xffECEEF3)
              : const Color(0xffBDE4FF),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xffEEE6FF),
            foregroundColor: const Color(0xff5E2CA5),
            child: Icon(notification.icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 3),
                Text(
                  notification.message,
                  style: const TextStyle(color: Colors.black54, height: 1.3),
                ),
                const SizedBox(height: 6),
                Text(
                  notification.timeLabel,
                  style: const TextStyle(
                    color: Color(0xff168BEE),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (!notification.isRead) ...[
            const SizedBox(width: 8),
            const CircleAvatar(radius: 4, backgroundColor: Color(0xffFF7A00)),
          ],
        ],
      ),
    );
  }
}
