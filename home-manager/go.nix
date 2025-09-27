{ ... }:

{
  programs.go = {
    enable = true;
    env.GOPATH = "Developer/Go";
  };
}
