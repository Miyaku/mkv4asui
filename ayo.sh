#!/sbin/sh
# 
# /system/addon.d/ayo.sh
#
. /tmp/backuptool.functions

list_files() {
cat <<EOF
ayo.sh
app/As.apk
app/AsUI.apk
app/As/As.apk
app/AsUI/AsUI.apk
app/ViPER4Android/ViPER4Android.apk
app/ViPER4Android/lib/arm/libV4AJniUtils.so
lib/soundfx/libv4a.so
lib/libV4AJniUtils.so
lib/libdlbdapstorage.so
lib/soundfx/libswdap-mod.so
su.d/50viper.sh
su.d/enforce.sh
etc/dolby/ds-default.xml
V4AVi
EOF
}

case "$1" in
  backup)
    list_files | while read FILE DUMMY; do
      backup_file $S/$FILE
    done
  ;;
  restore)
    list_files | while read FILE REPLACEMENT; do
      R=""
      [ -n "$REPLACEMENT" ] && R="$S/$REPLACEMENT"
      [ -f "$C/$S/$FILE" ] && restore_file $S/$FILE $R
    done
  ;;
  pre-backup)
    # Stub
  ;;
  post-backup)
    # Stub
  ;;
  pre-restore)
	# Stub
  ;;
  post-restore)
    # Normal/vendor config locations
	CONFIG_FILE=/system/etc/audio_effects.conf
	VENDOR_CONFIG=/system/vendor/etc/audio_effects.conf

	# If vendor exists, patch it
	if [ -f $VENDOR_CONFIG ];
	then
		sed -i '/dap {/,/}/d' $VENDOR_CONFIG
		sed -i '/v4a_fx {/,/}/d' $VENDOR_CONFIG
		sed -i '/v4a_standard_fx {/,/}/d' $VENDOR_CONFIG
		# Add libary V4A+dap
		sed -i 's/^libraries {/libraries {\n  v4a_fx {\n    path \/system\/lib\/soundfx\/libv4a.so\n  }/g' $VENDOR_CONFIG
		sed -i 's/^libraries {/libraries {\n  dap {\n    path \/system\/lib\/soundfx\/libswdap-mod.so\n  }/g' $VENDOR_CONFIG
		# Add effect V4A+dap
		sed -i 's/^effects {/effects {\n  v4a_standard_fx {\n    library v4a_fx\n    uuid 41d3c987-e6cf-11e3-a88a-11aba5d5c51b\n  }/g' $CONFIG_FILE
		sed -i 's/^effects {/effects {\n  dap {\n    library dap\n    uuid 9d4921da-8225-4f29-aefa-39537a041337\n  }/g' $CONFIG_FILE
	fi
	
	# Remove library & effect
	sed -i '/dap {/,/}/d' $CONFIG_FILE
	sed -i '/v4a_fx {/,/}/d' $CONFIG_FILE
	sed -i '/v4a_standard_fx {/,/}/d' $CONFIG_FILE
	
	# Add libary V4A+dap
	sed -i 's/^libraries {/libraries {\n  v4a_fx {\n    path \/system\/lib\/soundfx\/libv4a.so\n  }/g' $CONFIG_FILE
	sed -i 's/^libraries {/libraries {\n  dap {\n    path \/system\/lib\/soundfx\/libswdap-mod.so\n  }/g' $CONFIG_FILE

	# Add effect V4A+dap
	sed -i 's/^effects {/effects {\n  v4a_standard_fx {\n    library v4a_fx\n    uuid 41d3c987-e6cf-11e3-a88a-11aba5d5c51b\n  }/g' $CONFIG_FILE
	sed -i 's/^effects {/effects {\n  dap {\n    library dap\n    uuid 9d4921da-8225-4f29-aefa-39537a041337\n  }/g' $CONFIG_FILE
	
	echo " " >> /system/build.prop
	echo "## MK.ViPER4Android+Dolby by Miya ##" >> /system/build.prop
	echo "lpa.decode=false" >> /system/build.prop
	echo "tunnel.decode=false" >> /system/build.prop
	echo "lpa.use-stagefright=false" >> /system/build.prop
	echo "tunnel.audiovideo.decode=false" >> /system/build.prop
	echo "lpa.releaselock=false" >> /system/build.prop
	echo "persist.sys.media.use-awesome=1" >> /system/build.prop
	echo "af.resampler.quality=255" >> /system/build.prop
	echo "persist.af.resampler.quality=255" >> /system/build.prop
	echo "persist.dev.pm.dyn_samplingrate=1" >> /system/build.prop
	echo "## End of Compatible V4A ##" >> /system/build.prop
  ;;
esac
