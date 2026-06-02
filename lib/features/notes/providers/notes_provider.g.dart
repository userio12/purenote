// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notes_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allLabelsHash() => r'20568c7b7f451c62bbe5157d33a8dd488a717841';

/// See also [allLabels].
@ProviderFor(allLabels)
final allLabelsProvider = AutoDisposeFutureProvider<List<Label>>.internal(
  allLabels,
  name: r'allLabelsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allLabelsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllLabelsRef = AutoDisposeFutureProviderRef<List<Label>>;
String _$notesByLabelHash() => r'651ebdd9638ca93bb76024c09d33761860f414c3';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [notesByLabel].
@ProviderFor(notesByLabel)
const notesByLabelProvider = NotesByLabelFamily();

/// See also [notesByLabel].
class NotesByLabelFamily extends Family<AsyncValue<List<Note>>> {
  /// See also [notesByLabel].
  const NotesByLabelFamily();

  /// See also [notesByLabel].
  NotesByLabelProvider call(String labelId) {
    return NotesByLabelProvider(labelId);
  }

  @override
  NotesByLabelProvider getProviderOverride(
    covariant NotesByLabelProvider provider,
  ) {
    return call(provider.labelId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'notesByLabelProvider';
}

/// See also [notesByLabel].
class NotesByLabelProvider extends AutoDisposeStreamProvider<List<Note>> {
  /// See also [notesByLabel].
  NotesByLabelProvider(String labelId)
    : this._internal(
        (ref) => notesByLabel(ref as NotesByLabelRef, labelId),
        from: notesByLabelProvider,
        name: r'notesByLabelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$notesByLabelHash,
        dependencies: NotesByLabelFamily._dependencies,
        allTransitiveDependencies:
            NotesByLabelFamily._allTransitiveDependencies,
        labelId: labelId,
      );

  NotesByLabelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.labelId,
  }) : super.internal();

  final String labelId;

  @override
  Override overrideWith(
    Stream<List<Note>> Function(NotesByLabelRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: NotesByLabelProvider._internal(
        (ref) => create(ref as NotesByLabelRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        labelId: labelId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Note>> createElement() {
    return _NotesByLabelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NotesByLabelProvider && other.labelId == labelId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, labelId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin NotesByLabelRef on AutoDisposeStreamProviderRef<List<Note>> {
  /// The parameter `labelId` of this provider.
  String get labelId;
}

class _NotesByLabelProviderElement
    extends AutoDisposeStreamProviderElement<List<Note>>
    with NotesByLabelRef {
  _NotesByLabelProviderElement(super.provider);

  @override
  String get labelId => (origin as NotesByLabelProvider).labelId;
}

String _$noteByIdHash() => r'27b3d7013421126d4f6c51cda45f2b6e2ffda882';

/// See also [noteById].
@ProviderFor(noteById)
const noteByIdProvider = NoteByIdFamily();

/// See also [noteById].
class NoteByIdFamily extends Family<AsyncValue<Note?>> {
  /// See also [noteById].
  const NoteByIdFamily();

  /// See also [noteById].
  NoteByIdProvider call(String id) {
    return NoteByIdProvider(id);
  }

  @override
  NoteByIdProvider getProviderOverride(covariant NoteByIdProvider provider) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'noteByIdProvider';
}

/// See also [noteById].
class NoteByIdProvider extends AutoDisposeStreamProvider<Note?> {
  /// See also [noteById].
  NoteByIdProvider(String id)
    : this._internal(
        (ref) => noteById(ref as NoteByIdRef, id),
        from: noteByIdProvider,
        name: r'noteByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$noteByIdHash,
        dependencies: NoteByIdFamily._dependencies,
        allTransitiveDependencies: NoteByIdFamily._allTransitiveDependencies,
        id: id,
      );

  NoteByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(Stream<Note?> Function(NoteByIdRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: NoteByIdProvider._internal(
        (ref) => create(ref as NoteByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<Note?> createElement() {
    return _NoteByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NoteByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin NoteByIdRef on AutoDisposeStreamProviderRef<Note?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _NoteByIdProviderElement extends AutoDisposeStreamProviderElement<Note?>
    with NoteByIdRef {
  _NoteByIdProviderElement(super.provider);

  @override
  String get id => (origin as NoteByIdProvider).id;
}

String _$labelsForNoteHash() => r'f71f7c1ccb355382bd86af0a3e8fa71177b25e8f';

/// See also [labelsForNote].
@ProviderFor(labelsForNote)
const labelsForNoteProvider = LabelsForNoteFamily();

/// See also [labelsForNote].
class LabelsForNoteFamily extends Family<AsyncValue<List<Label>>> {
  /// See also [labelsForNote].
  const LabelsForNoteFamily();

  /// See also [labelsForNote].
  LabelsForNoteProvider call(String noteId) {
    return LabelsForNoteProvider(noteId);
  }

  @override
  LabelsForNoteProvider getProviderOverride(
    covariant LabelsForNoteProvider provider,
  ) {
    return call(provider.noteId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'labelsForNoteProvider';
}

/// See also [labelsForNote].
class LabelsForNoteProvider extends AutoDisposeFutureProvider<List<Label>> {
  /// See also [labelsForNote].
  LabelsForNoteProvider(String noteId)
    : this._internal(
        (ref) => labelsForNote(ref as LabelsForNoteRef, noteId),
        from: labelsForNoteProvider,
        name: r'labelsForNoteProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$labelsForNoteHash,
        dependencies: LabelsForNoteFamily._dependencies,
        allTransitiveDependencies:
            LabelsForNoteFamily._allTransitiveDependencies,
        noteId: noteId,
      );

  LabelsForNoteProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.noteId,
  }) : super.internal();

  final String noteId;

  @override
  Override overrideWith(
    FutureOr<List<Label>> Function(LabelsForNoteRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LabelsForNoteProvider._internal(
        (ref) => create(ref as LabelsForNoteRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        noteId: noteId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Label>> createElement() {
    return _LabelsForNoteProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LabelsForNoteProvider && other.noteId == noteId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, noteId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LabelsForNoteRef on AutoDisposeFutureProviderRef<List<Label>> {
  /// The parameter `noteId` of this provider.
  String get noteId;
}

class _LabelsForNoteProviderElement
    extends AutoDisposeFutureProviderElement<List<Label>>
    with LabelsForNoteRef {
  _LabelsForNoteProviderElement(super.provider);

  @override
  String get noteId => (origin as LabelsForNoteProvider).noteId;
}

String _$attachmentsForNoteHash() =>
    r'f26adc300317b357ea4913ad3a9cb0d2e473bdc3';

/// See also [attachmentsForNote].
@ProviderFor(attachmentsForNote)
const attachmentsForNoteProvider = AttachmentsForNoteFamily();

/// See also [attachmentsForNote].
class AttachmentsForNoteFamily extends Family<AsyncValue<List<Attachment>>> {
  /// See also [attachmentsForNote].
  const AttachmentsForNoteFamily();

  /// See also [attachmentsForNote].
  AttachmentsForNoteProvider call(String noteId) {
    return AttachmentsForNoteProvider(noteId);
  }

  @override
  AttachmentsForNoteProvider getProviderOverride(
    covariant AttachmentsForNoteProvider provider,
  ) {
    return call(provider.noteId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'attachmentsForNoteProvider';
}

/// See also [attachmentsForNote].
class AttachmentsForNoteProvider
    extends AutoDisposeFutureProvider<List<Attachment>> {
  /// See also [attachmentsForNote].
  AttachmentsForNoteProvider(String noteId)
    : this._internal(
        (ref) => attachmentsForNote(ref as AttachmentsForNoteRef, noteId),
        from: attachmentsForNoteProvider,
        name: r'attachmentsForNoteProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$attachmentsForNoteHash,
        dependencies: AttachmentsForNoteFamily._dependencies,
        allTransitiveDependencies:
            AttachmentsForNoteFamily._allTransitiveDependencies,
        noteId: noteId,
      );

  AttachmentsForNoteProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.noteId,
  }) : super.internal();

  final String noteId;

  @override
  Override overrideWith(
    FutureOr<List<Attachment>> Function(AttachmentsForNoteRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AttachmentsForNoteProvider._internal(
        (ref) => create(ref as AttachmentsForNoteRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        noteId: noteId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Attachment>> createElement() {
    return _AttachmentsForNoteProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AttachmentsForNoteProvider && other.noteId == noteId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, noteId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AttachmentsForNoteRef on AutoDisposeFutureProviderRef<List<Attachment>> {
  /// The parameter `noteId` of this provider.
  String get noteId;
}

class _AttachmentsForNoteProviderElement
    extends AutoDisposeFutureProviderElement<List<Attachment>>
    with AttachmentsForNoteRef {
  _AttachmentsForNoteProviderElement(super.provider);

  @override
  String get noteId => (origin as AttachmentsForNoteProvider).noteId;
}

String _$noteDocumentHash() => r'2dd0683b190a1274cbc511a148ef13f30d3c961c';

/// See also [noteDocument].
@ProviderFor(noteDocument)
const noteDocumentProvider = NoteDocumentFamily();

/// See also [noteDocument].
class NoteDocumentFamily extends Family<Document?> {
  /// See also [noteDocument].
  const NoteDocumentFamily();

  /// See also [noteDocument].
  NoteDocumentProvider call(String content) {
    return NoteDocumentProvider(content);
  }

  @override
  NoteDocumentProvider getProviderOverride(
    covariant NoteDocumentProvider provider,
  ) {
    return call(provider.content);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'noteDocumentProvider';
}

/// See also [noteDocument].
class NoteDocumentProvider extends AutoDisposeProvider<Document?> {
  /// See also [noteDocument].
  NoteDocumentProvider(String content)
    : this._internal(
        (ref) => noteDocument(ref as NoteDocumentRef, content),
        from: noteDocumentProvider,
        name: r'noteDocumentProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$noteDocumentHash,
        dependencies: NoteDocumentFamily._dependencies,
        allTransitiveDependencies:
            NoteDocumentFamily._allTransitiveDependencies,
        content: content,
      );

  NoteDocumentProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.content,
  }) : super.internal();

  final String content;

  @override
  Override overrideWith(Document? Function(NoteDocumentRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: NoteDocumentProvider._internal(
        (ref) => create(ref as NoteDocumentRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        content: content,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<Document?> createElement() {
    return _NoteDocumentProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NoteDocumentProvider && other.content == content;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, content.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin NoteDocumentRef on AutoDisposeProviderRef<Document?> {
  /// The parameter `content` of this provider.
  String get content;
}

class _NoteDocumentProviderElement extends AutoDisposeProviderElement<Document?>
    with NoteDocumentRef {
  _NoteDocumentProviderElement(super.provider);

  @override
  String get content => (origin as NoteDocumentProvider).content;
}

String _$notesStreamHash() => r'3de0f0f91c06377d154d4deb2b27c6d4b4f561a8';

/// See also [NotesStream].
@ProviderFor(NotesStream)
final notesStreamProvider =
    StreamNotifierProvider<NotesStream, List<Note>>.internal(
      NotesStream.new,
      name: r'notesStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notesStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NotesStream = StreamNotifier<List<Note>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
