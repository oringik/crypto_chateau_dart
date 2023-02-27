import 'dart:collection';
import 'dart:typed_data';

import 'package:crypto_chateau_dart/aes_256/aes_256.dart' as aes;

class BytesBuffer {
  final _properties = List<Property>.empty(growable: true);

  BytesBuffer();

  UnmodifiableListView<Property> get properties => UnmodifiableListView(_properties);

  void add(Property property) => _properties.add(property);

  Uint8List toBytes() {
    final builder = BytesBuilder();

    for (var property in _properties) {
      property.apply(builder);
    }

    return builder.toBytes();
  }

  @override
  String toString() => toBytes().toString();
}

abstract class Property {
  void apply(BytesBuilder builder);
}

class RequestId implements Property {
  final int id;

  const RequestId(this.id);

  @override
  void apply(BytesBuilder builder) {}
}

class Data implements Property {
  final Uint8List data;

  const Data(this.data);

  @override
  void apply(BytesBuilder builder) => builder.add(data);
}

class Length implements Property {
  const Length();

  @override
  void apply(BytesBuilder builder) {
    final length = builder.length;
    final bytes = Uint8List(2)
      ..[0] = length & 0xff
      ..[1] = (length & 0xff00) >> 8;
    builder.add(bytes);
  }
}

class Multiplex implements Property {
  final int requestId;

  const Multiplex(this.requestId);

  @override
  void apply(BytesBuilder builder) {
    final bytes = Uint8List(2)
      ..[0] = (requestId >> 0) & 0xFF
      ..[1] = (requestId >> 8) & 0xFF;
    builder.add(bytes);
  }
}

class Encrypt implements Property {
  final Uint8List sharedKey;

  const Encrypt(this.sharedKey);

  @override
  void apply(BytesBuilder builder) {
    final bytes = builder.takeBytes();
    builder.add(aes.Encrypt(bytes, sharedKey));
  }
}
