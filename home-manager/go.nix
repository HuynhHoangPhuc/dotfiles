{
  pkgs,
  username,
  ...
}:

let

  homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
in
{
  programs.go = {
    enable = true;
    env.GOPATH = "${homeDirectory}/Developer/Go";
  };
}
