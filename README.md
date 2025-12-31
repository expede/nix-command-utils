> [!WARNING]
> Permanently moved to https://codeberg.org/expede/nix-command-utils

# Nix Command Utils

Helpers for defining commands for Nix shells under Flakes.

## Quickstart

``` nix
{
  inputs = {
    command-utils.url = "github:expede/nix-command-utils";
    flake-utils.url = "github:numtide/flake-utils";
    # ...
  };

  outputs = {self, flake-utils, command-utils}:
    flake-utils.lib.eachDefaultSystem (system: 
      let
        # Cargo just for example
        cargo = "${pkgs.cargo}/bin/cargo";
      
        cmd = command-utils.cmd.${system};
        command_menu = command-utils.commands.${system} {
          hello = cmd "Print a hello world message" "echo 'Hello, world!'";

          bench = cmd "Run benchmarks, including test utils"
            "${cargo} bench --features test_utils";

          "bench:host" = cmd "Run host Criterion benchmarks"
            "${cargo} criterion";
        };
        #...
      in
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs;
            [
              command_menu
              # ...
            ];
            
            #...
        };
      }
    );
}
```

``` console
$ menu
  ____                                          _
 / ___|___  _ __ ___  _ __ ___   __ _ _ __   __| |___
| |   / _ \| '_ ` _ \| '_ ` _ \ / _` | '_ \ / _` / __|
| |__| (_) | | | | | | | | | | | (_| | | | | (_| \__ \
 \____\___/|_| |_| |_|_| |_| |_|\__,_|_| |_|\__,_|___/


bench      | Run benchmarks, including test utils
bench:host | Run host Criterion benchmarks
hello      | Print a hello world message

$ hello
Hello, world!
```

