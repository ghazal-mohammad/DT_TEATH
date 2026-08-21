// Real image-loading performance check.
//
// This test loads the app's actual bundled PNG assets (as declared under
// `flutter: assets:` in pubspec.yaml) through a real `Image.asset` widget
// tree, using Flutter's real `ImageCache` (via `PaintingBinding.instance
// .imageCache`) to distinguish a genuine cold (cache-miss) load from a
// genuine warm (cache-hit) load of the SAME asset within the same test.
//
// Unlike the deleted "Image Loading Test" this replaces, there are no
// invented numbers here (no fake `cacheHits = 40` / `totalImages = 50`).
// Every millisecond printed comes from a real `Stopwatch` wrapped around a
// real `tester.pumpAndSettle()` that had to actually decode image bytes.
//
// Asset list below was taken from a real directory listing of the folders
// declared in pubspec.yaml's `flutter: assets:` section (`assets/images/
// logo/`, `assets/images/auth/`, `assets/images/empty_states/`,
// `assets/images/onboarding/`, `assets/icons/`) as of the time this test
// was written. Only `logo/` and `auth/` currently contain real PNG files;
// `empty_states/`, `onboarding/`, and `icons/` only contain `.gitkeep`
// placeholders and have no real images to load yet.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Real bundled image assets that exist on disk today, taken from a live
/// directory listing (not assumed/invented). Update this list if real image
/// files are added to or removed from the declared asset folders.
const _realImageAssets = <String>[
  'assets/images/logo/logo_dark_no_text.png',
  'assets/images/logo/logo_dark_with_text.png',
  'assets/images/logo/logo_light_no_text.png',
  'assets/images/logo/logo_light_with_text.png',
  'assets/images/auth/auth_form_pattern.png',
];

void main() {
  group('image loading (real bundled assets)', () {
    testWidgets('every declared image asset loads, cold then warm', (
      tester,
    ) async {
      final imageCache = PaintingBinding.instance.imageCache;

      // Sanity-check the assumption the whole test relies on: each fresh
      // testWidgets run starts with an empty image cache, so the FIRST
      // load of an asset below is a real cache-miss (cold) load and the
      // SECOND load of the same asset is a real cache-hit (warm) load.
      expect(
        imageCache.currentSize,
        0,
        reason:
            'expected a clean ImageCache at the start of the test so the '
            'first load of each asset below is a real cold/cache-miss load',
      );

      // NOTE on why this uses `tester.runAsync` + `precacheImage`, not a
      // bare `pumpWidget` + `pumpAndSettle`: `testWidgets` runs inside a
      // fake-async test zone. `Image.asset` ultimately reads real bytes
      // off disk through `rootBundle` (real `dart:io` I/O under
      // `flutter test`), and that real I/O never completes inside the
      // fake-async zone — verified empirically: a plain
      // `pumpWidget`+`pumpAndSettle` leaves `imageCache.pendingImageCount`
      // stuck at 1 forever (the frame is never delivered). Wrapping the
      // wait in `tester.runAsync` escapes to the real event loop so the
      // real file read + decode can actually finish, exactly as Flutter's
      // own docs prescribe for `precacheImage` in widget tests. We still
      // build the real widget tree with `pumpWidget`/`Image.asset` and
      // still call `pumpAndSettle` — `precacheImage` is what makes the
      // wait for the real decode observable and timeable.
      final coldMsByAsset = <String, int>{};
      final warmMsByAsset = <String, int>{};

      for (final assetPath in _realImageAssets) {
        // --- Cold load: first time this asset is requested. -------------
        final sizeBeforeCold = imageCache.currentSize;
        late BuildContext coldContext;

        final coldStopwatch = Stopwatch()..start();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  coldContext = context;
                  return Center(
                    child: Image.asset(assetPath, key: UniqueKey()),
                  );
                },
              ),
            ),
          ),
        );
        await tester.runAsync(() async {
          await precacheImage(AssetImage(assetPath), coldContext);
        });
        await tester.pumpAndSettle();
        coldStopwatch.stop();

        // No decode/asset-loading exception should have been thrown.
        expect(
          tester.takeException(),
          isNull,
          reason: 'loading real asset $assetPath should not throw',
        );

        // The real decode must have fully finished (no partial/error
        // entries left pending) and actually inserted a new entry in the
        // real ImageCache — this is what proves the asset genuinely
        // resolved to real, non-empty image bytes rather than silently
        // no-op'ing.
        expect(
          imageCache.pendingImageCount,
          0,
          reason: 'expected $assetPath to finish decoding, not stay pending',
        );
        expect(
          imageCache.currentSize,
          greaterThan(sizeBeforeCold),
          reason:
              'expected $assetPath to be decoded and inserted into the '
              'real ImageCache — a missing/corrupt asset would fail here',
        );

        final coldMs = coldStopwatch.elapsedMilliseconds;
        coldMsByAsset[assetPath] = coldMs;
        debugPrint('image_cold_load_ms=$coldMs asset=$assetPath');

        // --- Warm load: same asset, same running test, cache populated. -
        final sizeBeforeWarm = imageCache.currentSize;
        late BuildContext warmContext;

        final warmStopwatch = Stopwatch()..start();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  warmContext = context;
                  return Center(
                    child: Image.asset(assetPath, key: UniqueKey()),
                  );
                },
              ),
            ),
          ),
        );
        await tester.runAsync(() async {
          await precacheImage(AssetImage(assetPath), warmContext);
        });
        await tester.pumpAndSettle();
        warmStopwatch.stop();

        expect(
          tester.takeException(),
          isNull,
          reason: 're-loading real asset $assetPath should not throw',
        );

        // Flutter's ImageCache dedupes by asset key (AssetBundleImageKey),
        // so decoding the same asset a second time must not grow the
        // cache again — this is the real signal that the second load hit
        // the cache instead of decoding the bytes a second time.
        expect(
          imageCache.currentSize,
          sizeBeforeWarm,
          reason:
              'expected the second load of $assetPath to be served from '
              'the ImageCache (same key, no new cache entry)',
        );

        final warmMs = warmStopwatch.elapsedMilliseconds;
        warmMsByAsset[assetPath] = warmMs;
        debugPrint('image_warm_load_ms=$warmMs asset=$assetPath');
      }

      // Directionally sound, evidence-based assertion: warm (cache-hit)
      // loads should not be meaningfully slower than cold (cache-miss)
      // loads. We don't assert warm < cold per-asset (both can legitimately
      // land at 0-1ms on a fast test machine, and scheduler/GC jitter can
      // flip a single sample), so instead we compare the real totals with
      // a noise margin generous enough to absorb that jitter while still
      // catching an actual regression (e.g. caching being broken and every
      // "warm" load silently re-decoding from bytes).
      final totalColdMs = coldMsByAsset.values.fold(0, (a, b) => a + b);
      final totalWarmMs = warmMsByAsset.values.fold(0, (a, b) => a + b);
      debugPrint(
        'image_cold_load_total_ms=$totalColdMs '
        'image_warm_load_total_ms=$totalWarmMs '
        'assets_tested=${_realImageAssets.length}',
      );

      const noiseMarginMs = 50;
      expect(
        totalWarmMs,
        lessThanOrEqualTo(totalColdMs + noiseMarginMs),
        reason:
            'warm (cache-hit) total load time ($totalWarmMs ms) should not '
            'exceed cold (cache-miss) total load time ($totalColdMs ms) by '
            'more than a $noiseMarginMs ms noise margin — a bigger gap '
            'would suggest the image cache is not actually being hit',
      );

      // Every declared asset that was tested must have produced a
      // measurement — i.e. it genuinely resolved to a real, loadable file.
      expect(coldMsByAsset.length, _realImageAssets.length);
      expect(warmMsByAsset.length, _realImageAssets.length);
    });
  });
}
