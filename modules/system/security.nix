{
  config,
  lib,
  ...
}: {
  # Auditing
  security.audit.enable = lib.mkDefault true;
  security.auditd.enable = lib.mkDefault true;

  # Blacklist kernel modules
  boot.blacklistedKernelModules = [
    # Obscure network protocols
    "ax25"
    "netrom"
    "rose"

    # Old or rare or insufficiently audited filesystems
    "adfs"
    "affs"
    "bfs"
    "befs"
    "cramfs"
    "efs"
    "erofs"
    "exofs"
    "freevxfs"
    "f2fs"
    "hfs"
    "hpfs"
    "jfs"
    "minix"
    "nilfs2"
    "ntfs"
    "omfs"
    "qnx4"
    "qnx6"
    "sysv"
    "ufs"

    # Fedora
    "appletalk"
    "atm"
    "ax25"
    "batman-adv"
    "floppy"
    "l2tp_eth"
    "l2tp_ip"
    "l2tp_netlink"
    "l2tp_ppp"
    "netrom"
    "nfc"
    "rds"
    "rose"
    "sctp"
  ];

  # Disable kernel module loading once the system is fully initialised
  security.lockKernelModules = lib.mkDefault true;

  # Prevent replacing the running kernel image
  security.protectKernelImage = lib.mkDefault true;

  # Disable unprivileged user namespaces, unless containers are enabled
  security.unprivilegedUsernsClone = lib.mkDefault config.virtualisation.containers.enable;

  # Disable sudo for anyone not in the wheel group
  security.sudo.execWheelOnly = lib.mkDefault true;
}
