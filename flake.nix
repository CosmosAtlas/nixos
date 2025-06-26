{
  description = "WZ's nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, darwin, home-manager, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
      [
        pkgs.git
        pkgs.home-manager
        pkgs.vim
        pkgs.just
      ];

      users = {
        users.cosmos = {
          home = "/Users/cosmos";
          name = "cosmos";
        };
      };

      fonts.packages = with pkgs; [
        iosevka
        libertinus
        maple-mono.NF-CN-unhinted
        nerd-fonts._0xproto
        nerd-fonts.agave
        nerd-fonts.iosevka-term
        sarasa-gothic
      ];

      homebrew = {
        enable = true;
        onActivation = {
          autoUpdate = true;
          cleanup = "uninstall";
          upgrade = true;
        };
        casks = [
          "docker-desktop"
          "emacs-app"
          "espanso"
          "ghostty"
          "google-chrome"
          "hammerspoon"
          "iterm2"
          "jordanbaird-ice"
          "karabiner-elements"
          "kitty"
          "readest"
          "skim"
          "slack"
          "squirrel-app"
          "syncthing-app"
          "tailscale-app"
          "visual-studio-code"
          "wechat"
          "xbar"
          "zoom"
        ];
      };

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      system.primaryUser = "cosmos";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Wenhans-MacBook-Pro
    darwinConfigurations."Wenhans-MacBook-Pro" = darwin.lib.darwinSystem {
      specialArgs = inputs;
      modules = [
        configuration 
      ];
    };

    homeConfigurations = {
      "cosmos@Wenhans-MacBook-Pro" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        extraSpecialArgs = {inherit inputs;};
        modules = [./home-manager/home.nix];
      };
    };
  };
}
