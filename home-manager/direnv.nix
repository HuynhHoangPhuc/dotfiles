{ ... }:

{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    silent = true;
    enableZshIntegration = true;
    config = {
      global = {
        load_dotenv = true;
      };
    };
  };
}
