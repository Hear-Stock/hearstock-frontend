import 'dart:ffi';
import 'dart:io';

final DynamicLibrary soloudLib =
    Platform.isAndroid
        ? DynamicLibrary.open("libsoloud.so")
        : DynamicLibrary.process();

final void Function() initSoloud =
    soloudLib
        .lookup<NativeFunction<Void Function()>>("init_soloud")
        .asFunction();

final void Function(double, double, double) play3d =
    soloudLib
        .lookup<NativeFunction<Void Function(Float, Float, Float)>>("play3d")
        .asFunction();

final void Function() stopSoloud =
    soloudLib
        .lookup<NativeFunction<Void Function()>>("stop_soloud")
        .asFunction();
