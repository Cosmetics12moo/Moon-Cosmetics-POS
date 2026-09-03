# Reverse-engineering findings

The supplied package is a stripped x64 Windows Flutter AOT application. Key evidence observed in `data/app.so` includes:
- `_kDartVmSnapshotData` / `_kDartIsolateSnapshotData` and `dart.vm.product`
- Windows executable `msms_app.exe`
- Windows Flutter runtime and plugins
- SQL migration assets 001 through 052
- strings for mobile/IMEI, used-mobile, repair, accessory and retail workflows

Because the AOT snapshot is stripped, the original Dart identifiers, source files and exact widget tree are not recoverable as source text. This project therefore implements a new clean-room source model from the observable schema and business behavior rather than claiming byte-for-byte source recovery.
