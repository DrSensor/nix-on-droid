# Copyright (c) 2019-2023, see AUTHORS. Licensed under MIT License, see LICENSE.
{
  lib,
  stdenv,
  fetchFromGitHub,
  talloc,
  static ? true,
  outputBinaryName ? "proot-static",
}:
stdenv.mkDerivation {
  pname = "proot-termux";
  version = "unstable-2023-11-11";

  src = fetchFromGitHub {
    repo = "proot";
    owner = "termux";
    rev = "4af79603dae7a12d8767b61937d9e7e41e517701";
    hash = lib.fakeHash;
  };

  # ashmem.h is rather small, our needs are even smaller, so just define these:
  preConfigure = ''
    mkdir -p fake-ashmem/linux; cat > fake-ashmem/linux/ashmem.h << EOF
    #include <linux/limits.h>
    #include <linux/ioctl.h>
    #define __ASHMEMIOC 0x77
    #define ASHMEM_NAME_LEN 256
    #define ASHMEM_SET_NAME _IOW(__ASHMEMIOC, 1, char[ASHMEM_NAME_LEN])
    #define ASHMEM_SET_SIZE _IOW(__ASHMEMIOC, 3, size_t)
    #define ASHMEM_GET_SIZE _IO(__ASHMEMIOC, 4)
    EOF
  '';

  buildInputs = [talloc];
  patches = [./detranslate-empty.patch];
  makeFlags = ["-Csrc" "V=1"];
  CFLAGS =
    ["-O3" "-I../fake-ashmem"]
    ++ (
      if static
      then ["-static"]
      else []
    );
  LDFLAGS =
    if static
    then ["-static"]
    else [];
  preInstall = "${stdenv.cc.targetPrefix}strip src/proot";
  installPhase = "install -D -m 0755 src/proot $out/bin/${outputBinaryName}";
}
