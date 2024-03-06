{
  description = "nix-command-utils";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        cmd = description: script: { inherit description script; };

        command = { name, script, description ? "<No description given>" }:
          {
            inherit name description;

            package =
              pkgs.writeScriptBin name ''
              #!${pkgs.bash}/bin/bash
              echo "⚙️  Running ${name}..."
              ${script}
            '';
          };

        commands = defs:
          let
            names =
              builtins.attrNames defs;

            helper =
              let
                lengths = map builtins.stringLength names;
                maxLen = builtins.foldl' (acc: x: if x > acc then x else acc) 0 lengths;
                maxPad =
                  let
                    go = acc:
                      if builtins.stringLength acc >= maxLen
                      then acc
                      else go (" " + acc);
                  in
                    go "";

                folder = acc: name:
                  let
                    nameLen = builtins.stringLength name;
                    padLen = maxLen - nameLen;
                    padding = builtins.substring 0 padLen maxPad;
                  in
                    acc + " && echo '${name} ${padding}| ${(builtins.getAttr name defs).description}'";

                lines =
                  builtins.foldl' folder "echo ''" names;

              in
                pkgs.writeScriptBin "menu" ''
                  #!${pkgs.stdenv.shell}
                  ${pkgs.figlet}/bin/figlet "Commands" | ${pkgs.lolcat}/bin/lolcat
                  ${toString lines}
                '';

            mapper = name:
              let
                element =
                  builtins.getAttr name defs;

                task = command {
                  inherit name;
                  description = element.description;
                  script = element.script;
                };
              in
                task.package;

            packages =
              map mapper names;

          in
            [ helper ] ++ packages;
      in
        { inherit cmd command commands; }
    );
}

