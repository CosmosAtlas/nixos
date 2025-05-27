{ config, pkgs, ... }:

{
  home.stateVersion = "24.11";

  home.username = "cosmos";
  home.homeDirectory = "/Users/cosmos";

  home.sessionVariables.EDITOR = "vim";

  home.packages = with pkgs; [
    bat
    btop
    delta
    devenv
    duf
    fd
    fzf
    helix
    htop
    neovim
    pfetch
    pandoc
    ranger
    ripgrep
    rust-analyzer
    texlive.combined.scheme-full
    universal-ctags
    uv
    zellij
  ];

  programs.home-manager.enable = true;

  programs.htop.enable = true;
  programs.htop.settings.show_program_path = true;

  programs.tmux = {
    enable = true;
    keyMode = "vi";
    mouse = true;
    sensibleOnTop = true;
    terminal = "tmux-256color";
    shell = "${pkgs.zsh}/bin/zsh";
    plugins = with pkgs; [
      tmuxPlugins.yank
      tmuxPlugins.pain-control
      {
        plugin=tmuxPlugins.rose-pine;
        extraConfig = "set -g @rose_pine_variant 'moon' # Options are 'main', 'moon' or 'dawn'";
      }
      {
        plugin=tmuxPlugins.fuzzback;
        extraConfig = "set -g @fuzzback-bind s";
      }
    ];
    extraConfig = ''
      set-option -g default-command "$SHELL -l"

      set -ga terminal-overrides ",xterm-256color:RGB,screen-256color,screen"

      bind-key -T copy-mode-vi 'v' send -X begin-selection
      bind -T copy-mode-vi 'y' send-keys -X copy-pipe 'xclip -in -selection clipboard'
      bind-key -T copy-mode-vi MouseDragEnd1Pane send -X copy-pipe "xclip -selection clipboard -i" \; send -X clear-selection

      set-option -g renumber-windows on
    '';
  };


  programs.zsh = {
    enable = true;
    enableCompletion = false;  # completion is dealt with plugin below
    antidote = {
      enable = true;
      plugins = [
        "rupa/z"

        "zsh-users/zsh-completions kind:fpath path:src"

        "getantidote/use-omz"
        "ohmyzsh/ohmyzsh path:lib"
        "ohmyzsh/ohmyzsh path:plugins/colored-man-pages"
        "ohmyzsh/ohmyzsh path:plugins/magic-enter"
        "ohmyzsh/ohmyzsh path:plugins/docker"

        "belak/zsh-utils path:editor"
        "belak/zsh-utils path:history"
        "belak/zsh-utils path:prompt"
        "belak/zsh-utils path:utility"

        "zsh-users/zsh-autosuggestions"
        "zdharma-continuum/fast-syntax-highlighting kind:defer"
        "zsh-users/zsh-history-substring-search"
      ];
    };
    initContent = ''
      colorlist() {
        for i in {0..255}; do print -Pn "%K{''$i}  %k%F{''$i}''${(l:3::0:)i}%f " ''${''${(M)$((i%6)):#3}:+''$'\n'}; done
      }

      truecolortest() {
        awk 'BEGIN{
          s="/\\/\\/\\/\\/\\"; s=s s s s s s s s;
          for (colnum = 0; colnum<77; colnum++) {
            r = 255-(colnum*255/76);
            g = (colnum*510/76);
            b = (colnum*255/76);
            if (g>255) g = 510-g;
            printf "\033[48;2;%d;%d;%dm", r,g,b;
            printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
            printf "%s\033[0m", substr(s,colnum+1,1);
          }
          printf "\n";
        }'
      }

      # uv setup
      eval "$(uv generate-shell-completion zsh)"
      eval "$(uvx --generate-shell-completion zsh)"

      pyenv() {
        if [ "$1" = "version-name" ]; then
          uv run python --version | sed 's/Python //g'
        else
          echo "pyenv: command not found"
        fi
      }

      # load local configs
      [[ ! -f $HOME/.zsh_local ]] || source $HOME/.zsh_local

      if [[ -n "$ZSH_DEBUGRC" ]]; then
        zprof
      fi
    '';
  };

  programs.starship.enable = true;
  programs.starship.enableZshIntegration = true;

  programs.direnv.enable = true;
  programs.direnv.enableZshIntegration = true;
  programs.direnv.nix-direnv.enable = true;
}
