import 'file_handle_stub.dart'
    if (dart.library.io) 'file_handle_mobile.dart'
    if (dart.library.html) 'file_handle_web.dart';

export 'file_handle_stub.dart'
    if (dart.library.io) 'file_handle_mobile.dart'
    if (dart.library.html) 'file_handle_web.dart';
