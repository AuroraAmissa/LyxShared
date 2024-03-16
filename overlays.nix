self: super: 

{
    lyx = super.lyx.overrideAttrs (oldAttrs: rec {
        version = "2.4.0~RC3";
        src = super.fetchurl {
            url = "https://ftp.lip6.fr/pub/lyx/devel/lyx-2.4/lyx-${version}.tar.xz";
            sha256 = "sha256-wwDG/ptMGo3c0v0w7GNvo7zTxCzzxP0bqs9WlTJJuPc=";
        };
    });
}
