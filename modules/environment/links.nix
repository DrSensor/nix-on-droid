# Copyright (c) 2019-2022, see AUTHORS. Licensed under MIT License, see LICENSE.
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.environment;
in {
  ###### interface

  options = {
    environment = {
      binSh = mkOption {
        type = types.str;
        readOnly = true;
        description = "Path to <filename>/bin/sh</filename> executable.";
      };

      usrBinEnv = mkOption {
        type = types.str;
        readOnly = true;
        description = "Path to <filename>/usr/bin/env</filename> executable.";
      };
    };
  };

  ###### implementation

  config = {
    build.activationBefore = {
      linkBinSh = ''
        $DRY_RUN_CMD mkdir $VERBOSE_ARG --parents /bin
        $DRY_RUN_CMD ln $VERBOSE_ARG --symbolic --force ${cfg.binSh} /bin/.sh.tmp
        $DRY_RUN_CMD mv $VERBOSE_ARG /bin/.sh.tmp /bin/sh
      '';

      linkUsrBinEnv = ''
        $DRY_RUN_CMD mkdir $VERBOSE_ARG --parents /usr/bin
        $DRY_RUN_CMD ln $VERBOSE_ARG --symbolic --force ${cfg.usrBinEnv} /usr/bin/.env.tmp
        $DRY_RUN_CMD mv $VERBOSE_ARG /usr/bin/.env.tmp /usr/bin/env
      '';
    };

    environment = {
      binSh = "${pkgs.bashInteractive}/bin/sh";
      usrBinEnv = "${pkgs.coreutils}/bin/env";
    };
  };
}
