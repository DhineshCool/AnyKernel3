### AnyKernel3 Ramdisk Mod Script
## osm0sis @ xda-developers

### AnyKernel setup
# global properties
properties() { '
kernel.string=Cybertron Kernel by cool585
do.devicecheck=1
do.modules=1
do.systemless=0
do.cleanup=1
do.cleanuponabort=0
device.name1=hanoip
device.name2=hanoip
device.name3=
device.name4=
device.name5=
supported.versions=
supported.patchlevels=
supported.vendorpatchlevels=
'; } # end properties


### AnyKernel install
## boot files attributes
boot_attributes() {
set_perm_recursive 0 0 755 644 $RAMDISK/*;
set_perm_recursive 0 0 750 750 $RAMDISK/init* $RAMDISK/sbin;
} # end attributes

# boot shell variables
BLOCK=auto;
IS_SLOT_DEVICE=auto;
RAMDISK_COMPRESSION=auto;
PATCH_VBMETA_FLAG=auto;

# backwards compatibility variables
block=$BLOCK;
is_slot_device=$IS_SLOT_DEVICE;
ramdisk_compression=$RAMDISK_COMPRESSION;
patch_vbmeta_flag=$PATCH_VBMETA_FLAG;

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh;

# ensure directory variables for custom scripts
[ "$home" ] || home=$AKHOME;
[ "$AKHOME" ] || AKHOME=$home;

# boot install
dump_boot; # use split_boot to skip ramdisk unpack, e.g. for devices with init_boot ramdisk

write_boot; # use flash_boot to skip ramdisk repack, e.g. for devices with init_boot ramdisk
## end boot install

# Force-replace kernel modules into /vendor/lib/modules and Magisk if present
if [ -d $AKHOME/modules ] || [ -d $home/modules ]; then
  MODULES_DIR=$AKHOME/modules;
  [ -d "$MODULES_DIR" ] || MODULES_DIR=$home/modules;
  ui_print " " "Force-replacing kernel modules...";
  if [ -d /dev/block/mapper ]; then
    for s in "" _a _b; do
      blockdev --setrw /dev/block/mapper/vendor$s 2>/dev/null;
    done;
  fi;
  mount -o rw,remount /vendor 2>/dev/null || true;
  for mod in $(find $MODULES_DIR -name '*.ko' 2>/dev/null); do
    modname=$(basename $mod);
    target=$(find /vendor -name "$modname" 2>/dev/null | head -n1);
    if [ -z "$target" ]; then
      target="/vendor/lib/modules/$modname";
    fi;
    mkdir -p $(dirname $target) 2>/dev/null;
    cp -f "$mod" "$target" 2>/dev/null;
    chown 0:0 "$target" 2>/dev/null;
    chmod 644 "$target" 2>/dev/null;
    chcon u:object_r:vendor_file:s0 "$target" 2>/dev/null;
    ui_print "  -> Replaced $target";
  done;
  if [ -d /data/adb/modules ]; then
    magisk_mod="/data/adb/modules/ak3-helper";
    mkdir -p "$magisk_mod/system/vendor/lib/modules";
    for mod in $(find $MODULES_DIR -name '*.ko' 2>/dev/null); do
      cp -f "$mod" "$magisk_mod/system/vendor/lib/modules/" 2>/dev/null;
      chmod 644 "$magisk_mod/system/vendor/lib/modules/$(basename "$mod")" 2>/dev/null;
    done;
    cat <<EOM > "$magisk_mod/module.prop"
id=ak3-helper
name=Cybertron Kernel Modules
version=Cybertron
versionCode=1
author=cool585
description=Kernel modules and tunings for Cybertron Kernel
EOM
    cat <<EOM > "$magisk_mod/service.sh"
#!/system/bin/sh
sleep 10
setprop sys.sysctl.swappiness 160
echo 160 > /proc/sys/vm/swappiness
EOM
    chmod 755 "$magisk_mod/service.sh";
    ui_print "  -> Magisk kernel helper module updated.";
  fi;
fi;


## init_boot files attributes
#init_boot_attributes() {
#set_perm_recursive 0 0 755 644 $RAMDISK/*;
#set_perm_recursive 0 0 750 750 $RAMDISK/init* $RAMDISK/sbin;
#} # end attributes

# init_boot shell variables
#BLOCK=init_boot;
#IS_SLOT_DEVICE=1;
#RAMDISK_COMPRESSION=auto;
#PATCH_VBMETA_FLAG=auto;

# reset for init_boot patching
#reset_ak;

# init_boot install
#dump_boot; # unpack ramdisk since it is the new first stage init ramdisk where overlay.d must go

#write_boot;
## end init_boot install


## vendor_kernel_boot shell variables
#BLOCK=vendor_kernel_boot;
#IS_SLOT_DEVICE=1;
#RAMDISK_COMPRESSION=auto;
#PATCH_VBMETA_FLAG=auto;

# reset for vendor_kernel_boot patching
#reset_ak;

# vendor_kernel_boot install
#split_boot; # skip unpack/repack ramdisk, e.g. for dtb on devices with hdr v4 and vendor_kernel_boot

#flash_boot;
## end vendor_kernel_boot install


## vendor_boot files attributes
#vendor_boot_attributes() {
#set_perm_recursive 0 0 755 644 $RAMDISK/*;
#set_perm_recursive 0 0 750 750 $RAMDISK/init* $RAMDISK/sbin;
#} # end attributes

# vendor_boot shell variables
#BLOCK=vendor_boot;
#IS_SLOT_DEVICE=1;
#RAMDISK_COMPRESSION=auto;
#PATCH_VBMETA_FLAG=auto;

# reset for vendor_boot patching
#reset_ak;

# vendor_boot install
#dump_boot; # use split_boot to skip ramdisk unpack, e.g. for dtb on devices with hdr v4 but no vendor_kernel_boot

#write_boot; # use flash_boot to skip ramdisk repack, e.g. for dtb on devices with hdr v4 but no vendor_kernel_boot
## end vendor_boot install
