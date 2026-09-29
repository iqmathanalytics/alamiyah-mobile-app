import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/alamiyah_colors.dart';
import '../../../data/models/models.dart';
import '../../../data/services/service_providers.dart';
import '../providers/admin_providers.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  final _email = TextEditingController();
  final _name = TextEditingController();
  var _role = AdminRole.contributor;
  var _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _invite() async {
    setState(() => _busy = true);
    try {
      await ref.read(adminAuthServiceProvider).inviteAdmin(
            email: _email.text,
            name: _name.text,
            role: _role,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Invite saved. They can register via Admin → Accept invite.',
            ),
          ),
        );
        _email.clear();
        _name.clear();
      }
      ref.invalidate(adminUsersProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.alamiyahColors;
    final session = ref.watch(adminSessionProvider);
    final async = ref.watch(adminUsersProvider);

    if (session == null || !session.profile.isOwner) {
      return const Center(child: Text('Owner access required'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Invite admin',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: colors.brandPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _name,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _email,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<AdminRole>(
          // ignore: deprecated_member_use
          value: _role,
          decoration: const InputDecoration(
            labelText: 'Role',
            border: OutlineInputBorder(),
          ),
          items: AdminRole.values
              .map(
                (r) => DropdownMenuItem(value: r, child: Text(r.name)),
              )
              .toList(),
          onChanged: (v) => setState(() => _role = v ?? AdminRole.contributor),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _busy ? null : _invite,
          child: const Text('Create invite'),
        ),
        const SizedBox(height: 24),
        Text(
          'Admins',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: colors.brandPrimary,
          ),
        ),
        const SizedBox(height: 8),
        async.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Text('$e'),
          data: (admins) {
            return Column(
              children: admins.map((admin) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(admin.name),
                  subtitle: Text(
                    '${admin.email} · ${admin.role.name}'
                    '${admin.isActive ? '' : ' · deactivated'}',
                  ),
                  trailing: admin.id == session.uid
                      ? const Text('You')
                      : TextButton(
                          onPressed: () async {
                            await ref
                                .read(adminAuthServiceProvider)
                                .setAdminActive(admin.id, !admin.isActive);
                            ref.invalidate(adminUsersProvider);
                          },
                          child: Text(admin.isActive ? 'Deactivate' : 'Reactivate'),
                        ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
