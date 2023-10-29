{pkgs, ...}: {
  programs.chromium = {
    enable = true;
    package = pkgs.ungoogled-chromium;

    extensions = [
      # 1Password Beta – Password Manager
      {id = "khgocmkkpikpnmmkgmdnfckapcdkgfaf";}
      # 7TV Nightly
      # { id = "fphegifdehlodcepfkgofelcenelpedj"; }
      # Dark Mode - Night Eye
      # { id = "alncdjedloppbablonallfbkeiknmkdi"; }
      # Decentraleyes
      {id = "ldpochfccmkkmhdbclfhpagapcfdljkj";}
      # React Developer Tools
      # { id = "fmkadmapgofadopljbjfkapdkoienihi"; }
      # uBlock Origin
      {id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";}
      # Vue.js devtools
      # { id = "nhdogjmejiglipccpnnnanhbledajbpd"; }
    ];
  };
}
