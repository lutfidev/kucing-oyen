import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import '../../app/game_audio.dart';
import '../../app/language.dart';
import '../../game/model/sounds.dart';
import '../../l10n/l10n.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../../widgets/v2/ui_panel.dart';
import '../../widgets/v2/ui_button.dart';
import '../../theme/ko_ui.dart';

/// Bar atas Pengaturan: tombol kembali dan judul, seperti bar Toko tanpa
/// chip koin.
class SettingsBar extends StatelessWidget {
  const SettingsBar({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        KoIconButton(
          icon: KoIcons.back,
          semanticLabel: context.l10n.backToHome,
          onPressed: onBack,
        ),
        SizedBox(width: context.koSpace.s10),
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              context.l10n.settings,
              style: context.koType.headingLarge.copyWith(
                color: context.koColors.ink,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Satu bagian Pengaturan: judul kecil kapital ("BAHASA") di atas kartunya.
class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final space = context.koSpace;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(start: space.s4),
          child: Semantics(
            header: true,
            child: Text(
              title.toUpperCase(),
              style: context.koType.overline.copyWith(
                color: context.koColors.inkSoft,
              ),
            ),
          ),
        ),
        SizedBox(height: space.s8),
        child,
      ],
    );
  }
}

/// Sakelar Musik dan Efek suara.
class SoundCard extends StatelessWidget {
  const SoundCard({
    super.key,
    required this.music,
    required this.effects,
    required this.onMusic,
    required this.onEffects,
  });

  final bool music;
  final bool effects;
  final ValueChanged<bool> onMusic;
  final ValueChanged<bool> onEffects;

  @override
  Widget build(BuildContext context) {
    final space = context.koSpace;
    final l = context.l10n;
    return UiPanel(
      padding: EdgeInsets.symmetric(horizontal: space.s12, vertical: space.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SettingsSwitchRow(
            key: const ValueKey('sound-music'),
            label: l.music,
            on: music,
            onChanged: onMusic,
          ),
          SettingsSwitchRow(
            key: const ValueKey('sound-effects'),
            label: l.soundEffects,
            on: effects,
            onChanged: onEffects,
          ),
        ],
      ),
    );
  }
}

/// Baris berlabel dengan sakelar pil di kanan: hijau dengan bulatan di
/// kanan saat menyala, abu-abu dengan bulatan di kiri saat mati. Seluruh
/// baris bisa diketuk.
class SettingsSwitchRow extends StatelessWidget {
  const SettingsSwitchRow({
    super.key,
    required this.label,
    required this.on,
    required this.onChanged,
  });

  final String label;
  final bool on;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final s = context.koSize;
    final space = context.koSpace;
    // Bunyi sesudah sakelar berubah: sakelar Efek suara senyap saat
    // dimatikan dan berbunyi saat dinyalakan.
    void tap() {
      onChanged?.call(!on);
      AudioScope.maybeRead(context)?.play(GameSound.tap);
    }

    return Semantics(
      toggled: on,
      label: label,
      onTap: onChanged == null ? null : tap,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onChanged == null ? null : tap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: s.iconButton),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: space.s6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: context.koType.cardLabel.copyWith(color: c.ink),
                  ),
                ),
                SizedBox(width: space.s10),
                Container(
                  width: s.iconButton,
                  height: s.checkBadge,
                  padding: EdgeInsets.all(space.s4),
                  alignment: on
                      ? AlignmentDirectional.centerEnd
                      : AlignmentDirectional.centerStart,
                  decoration: BoxDecoration(
                    color: on ? c.success : c.line,
                    borderRadius: BorderRadius.circular(context.koRadius.pill),
                  ),
                  child: Container(
                    width: s.iconCompact,
                    height: s.iconCompact,
                    decoration: BoxDecoration(
                      color: c.surface,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Lima pilihan bahasa: ikuti HP lalu bahasa yang didukung, masing-masing
/// ditulis dalam bahasanya sendiri. Pilihan yang aktif bercentang hijau
/// seperti kartu petunjuk yang terbuka.
class LanguageCard extends StatelessWidget {
  const LanguageCard({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final AppLanguage selected;
  final ValueChanged<AppLanguage> onSelect;

  @override
  Widget build(BuildContext context) {
    final space = context.koSpace;
    return UiPanel(
      padding: EdgeInsets.symmetric(horizontal: space.s12, vertical: space.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final language in AppLanguage.values)
            _LanguageRow(
              key: ValueKey('language-${language.name}'),
              name: language.nativeName ?? context.l10n.languageSystem,
              locale: language == AppLanguage.system
                  ? null
                  : Locale(language.name),
              selected: language == selected,
              onTap: () => onSelect(language),
            ),
        ],
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    super.key,
    required this.name,
    required this.selected,
    required this.onTap,
    this.locale,
  });

  final String name;
  final bool selected;
  final VoidCallback onTap;

  /// Bahasa [name], supaya pembaca layar membacanya dengan suara bahasa itu
  /// ("Русский" tidak dibaca dengan suara Inggris); null = bahasa aplikasi.
  final Locale? locale;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final s = context.koSize;
    final space = context.koSpace;
    final tap = tapSound(context, onTap);
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      attributedLabel: AttributedString(
        name,
        attributes: [
          if (locale case final locale?)
            LocaleStringAttribute(
              range: TextRange(start: 0, end: name.length),
              locale: locale,
            ),
        ],
      ),
      onTap: tap,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: tap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: s.iconButton),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: space.s6),
            child: Row(
              children: [
                Container(
                  width: s.chipSmall,
                  height: s.chipSmall,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? c.success : c.surface,
                    shape: BoxShape.circle,
                    border: selected
                        ? null
                        : Border.all(color: c.line, width: s.border),
                  ),
                  child: selected
                      ? KoIcon(
                          KoIcons.check,
                          size: s.iconCompact,
                          color: c.onSuccess,
                        )
                      : null,
                ),
                SizedBox(width: space.s10),
                Expanded(
                  child: Text(
                    name,
                    style: context.koType.cardLabel.copyWith(color: c.ink),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Kartu berisi penjelasan, tombol, dan pesan hijau sesudah tombol
/// ditekan ([message]).
class ActionCard extends StatelessWidget {
  const ActionCard({
    super.key,
    required this.text,
    required this.button,
    this.message,
  });

  final String text;
  final Widget button;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final space = context.koSpace;
    final message = this.message;
    return UiPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(text, style: t.bodySmall.copyWith(color: c.inkSoft)),
          SizedBox(height: space.s10),
          button,
          if (message != null) ...[
            SizedBox(height: space.s8),
            Semantics(
              liveRegion: true,
              child: Text(
                message,
                style: t.controlLabel.copyWith(color: c.successText),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Privasi: penjelasan singkat, tombol kebijakan privasi, tombol formulir
/// persetujuan iklan (hanya kalau [onConsent] ada), dan pesan kalau browser
/// gagal dibuka ([message]).
class PrivacyCard extends StatelessWidget {
  const PrivacyCard({
    super.key,
    required this.onPolicy,
    this.onConsent,
    this.message,
    this.waiting = false,
  });

  final VoidCallback onPolicy;
  final VoidCallback? onConsent;
  final String? message;
  final bool waiting;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final space = context.koSpace;
    final l = context.l10n;
    final onConsent = this.onConsent;
    final message = this.message;
    Widget button(
      String name,
      String label,
      KoIconData icon,
      VoidCallback on,
    ) => SheetButton(
      key: ValueKey('privacy-$name'),
      label: label,
      loading: name == 'consent' && waiting,
      icon: KoIcon(icon, size: context.koSize.iconCompact, color: c.ink),
      color: c.surface,
      line: c.line,
      edge: c.lineDeep,
      onPressed: on,
    );
    return UiPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.privacyInfo, style: t.bodySmall.copyWith(color: c.inkSoft)),
          SizedBox(height: space.s10),
          button('policy', l.privacyPolicy, KoIcons.rules, onPolicy),
          if (onConsent != null) ...[
            SizedBox(height: space.s8),
            button('consent', l.adConsent, KoIcons.ad, onConsent),
          ],
          if (message != null) ...[
            SizedBox(height: space.s8),
            Semantics(
              liveRegion: true,
              child: Text(
                message,
                style: t.controlLabel.copyWith(color: c.brickDeep),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Tentang: nama game, versi, kredit font dan suara, dan tombol halaman
/// lisensi.
class AboutCard extends StatelessWidget {
  const AboutCard({super.key, required this.version, required this.onLicenses});

  /// Null = belum atau tidak bisa dibaca; barisnya tidak ditampilkan.
  final String? version;
  final VoidCallback onLicenses;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final space = context.koSpace;
    final l = context.l10n;
    final version = this.version;
    return UiPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(appName, style: t.cardTitle),
          if (version != null)
            Text(
              l.version(version),
              style: t.controlLabel.copyWith(color: c.inkSoft),
            ),
          SizedBox(height: space.s6),
          Text(l.fontCredits, style: t.bodySmall.copyWith(color: c.inkSoft)),
          SizedBox(height: space.s4),
          Text(l.soundCredits, style: t.bodySmall.copyWith(color: c.inkSoft)),
          SizedBox(height: space.s10),
          SheetButton(
            label: l.licenses,
            icon: KoIcon(
              KoIcons.rules,
              size: context.koSize.iconCompact,
              color: c.ink,
            ),
            color: c.surface,
            line: c.line,
            edge: c.lineDeep,
            onPressed: onLicenses,
          ),
        ],
      ),
    );
  }
}

/// Sheet konfirmasi reset progres (gaya sheet Petunjuk): judul, tombol
/// tutup, penjelasan apa yang dihapus, lalu Batal dan Hapus.
class ResetSheet extends StatefulWidget {
  const ResetSheet({
    super.key,
    required this.onClose,
    this.onConfirm,
    this.onReset,
  });
  final VoidCallback onClose;
  final VoidCallback? onConfirm;
  final Future<bool> Function()? onReset;
  @override
  State<ResetSheet> createState() => _ResetSheetState();
}

class _ResetSheetState extends State<ResetSheet> {
  bool busy = false, failed = false;
  Future<void> confirm() async {
    if (busy) return;
    if (widget.onReset == null) {
      widget.onConfirm?.call();
      return;
    }
    setState(() {
      busy = true;
      failed = false;
    });
    final ok = await widget.onReset!();
    if (!mounted) return;
    if (ok) {
      widget.onClose();
      return;
    }
    setState(() {
      busy = false;
      failed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return PopScope(
      canPop: !busy,
      child: KoSheet(
        label: l.resetConfirmTitle,
        onClose: busy ? () {} : widget.onClose,
        header: UiSheetHeader(
          title: l.resetConfirmTitle,
          onClose: busy ? null : widget.onClose,
        ),
        footer: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (failed) UiSaveNotice(onRetry: confirm),
            UiButton(
              label: l.cancel,
              kind: UiButtonKind.secondary,
              onPressed: busy ? null : widget.onClose,
            ),
            const SizedBox(height: KoUi.s8),
            UiButton(
              label: l.resetConfirm,
              kind: UiButtonKind.danger,
              loading: busy,
              onPressed: busy ? null : confirm,
            ),
          ],
        ),
        children: [
          Text(l.resetConfirmBody, style: KoUi.body),
          const SizedBox(height: KoUi.s12),
          Text(l.guidanceResetAreas, style: KoUi.small),
        ],
      ),
    );
  }
}
