import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import '../../app/game_audio.dart';
import '../../app/language.dart';
import '../../game/model/sounds.dart';
import '../../l10n/l10n.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

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
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                context.l10n.settings,
                maxLines: 1,
                style: context.koType.headingLarge.copyWith(
                  color: context.koColors.ink,
                ),
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
    return KoCard(
      padding: EdgeInsets.symmetric(horizontal: space.s12, vertical: space.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SwitchRow(
            key: const ValueKey('sound-music'),
            label: l.music,
            on: music,
            onChanged: onMusic,
          ),
          _SwitchRow(
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
class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    super.key,
    required this.label,
    required this.on,
    required this.onChanged,
  });

  final String label;
  final bool on;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final s = context.koSize;
    final space = context.koSpace;
    // Bunyi sesudah sakelar berubah: sakelar Efek suara senyap saat
    // dimatikan dan berbunyi saat dinyalakan.
    void tap() {
      onChanged(!on);
      AudioScope.maybeRead(context)?.play(GameSound.tap);
    }

    return Semantics(
      toggled: on,
      label: label,
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
    return KoCard(
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
    return KoCard(
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
  });

  final VoidCallback onPolicy;
  final VoidCallback? onConsent;
  final String? message;

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
      icon: KoIcon(icon, size: context.koSize.iconCompact, color: c.ink),
      color: c.surface,
      line: c.line,
      edge: c.lineDeep,
      onPressed: on,
    );
    return KoCard(
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
    return KoCard(
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
class ResetSheet extends StatelessWidget {
  const ResetSheet({super.key, required this.onClose, required this.onConfirm});

  final VoidCallback onClose;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final space = context.koSpace;
    final s = context.koSize;
    final l = context.l10n;
    return KoSheet(
      label: l.resetConfirmTitle,
      onClose: onClose,
      header: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(l.resetConfirmTitle, style: t.title),
            ),
          ),
          SizedBox(width: space.s10),
          KoIconButton(
            icon: KoIcons.close,
            semanticLabel: l.close,
            tone: KoIconButtonTone.flat,
            iconSize: s.iconSmall,
            onPressed: onClose,
          ),
        ],
      ),
      children: [
        Text(l.resetConfirmBody, style: t.bodySmall.copyWith(color: c.inkSoft)),
        SizedBox(height: space.s16),
        Row(
          children: [
            Expanded(
              child: SheetButton(
                label: l.cancel,
                icon: KoIcon(KoIcons.close, size: s.iconCompact, color: c.ink),
                color: c.surface,
                line: c.line,
                edge: c.lineDeep,
                onPressed: onClose,
              ),
            ),
            SizedBox(width: space.s8),
            Expanded(
              child: SheetButton(
                label: l.resetConfirm,
                icon: KoIcon(
                  KoIcons.reset,
                  size: s.iconCompact,
                  color: c.onBrick,
                ),
                color: c.brick,
                line: c.brick,
                edge: c.brickEdge,
                labelColor: c.onBrick,
                onPressed: onConfirm,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
