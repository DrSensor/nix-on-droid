# Licensed under GNU Lesser General Public License v3 or later, see COPYING.
# Copyright (c) 2019 Alexander Sosedkin and other contributors, see AUTHORS.

{ arch, buildPkgs, bootstrap }:

buildPkgs.runCommand "bootstrap-zip" { } ''
  mkdir $out
  cd ${bootstrap}
  ${buildPkgs.zip}/bin/zip -q -9 -r $out/bootstrap-${arch} ./* ./.l2s
''