#!/bin/sh
set -e
set -u
set -o pipefail

function on_error {
  echo "$(realpath -mq "${0}"):$1: error: Unexpected failure"
}
trap 'on_error $LINENO' ERR

if [ -z ${UNLOCALIZED_RESOURCES_FOLDER_PATH+x} ]; then
  # If UNLOCALIZED_RESOURCES_FOLDER_PATH is not set, then there's nowhere for us to copy
  # resources to, so exit 0 (signalling the script phase was successful).
  exit 0
fi

mkdir -p "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy-${TARGETNAME}.txt
> "$RESOURCES_TO_COPY"

XCASSET_FILES=()

# This protects against multiple targets copying the same framework dependency at the same time. The solution
# was originally proposed here: https://lists.samba.org/archive/rsync/2008-February/020158.html
RSYNC_PROTECT_TMP_FILES=(--filter "P .*.??????")

case "${TARGETED_DEVICE_FAMILY:-}" in
  1,2)
    TARGET_DEVICE_ARGS="--target-device ipad --target-device iphone"
    ;;
  1)
    TARGET_DEVICE_ARGS="--target-device iphone"
    ;;
  2)
    TARGET_DEVICE_ARGS="--target-device ipad"
    ;;
  3)
    TARGET_DEVICE_ARGS="--target-device tv"
    ;;
  4)
    TARGET_DEVICE_ARGS="--target-device watch"
    ;;
  *)
    TARGET_DEVICE_ARGS="--target-device mac"
    ;;
esac

install_resource()
{
  if [[ "$1" = /* ]] ; then
    RESOURCE_PATH="$1"
  else
    RESOURCE_PATH="${PODS_ROOT}/$1"
  fi
  if [[ ! -e "$RESOURCE_PATH" ]] ; then
    cat << EOM
error: Resource "$RESOURCE_PATH" not found. Run 'pod install' to update the copy resources script.
EOM
    exit 1
  fi
  case $RESOURCE_PATH in
    *.storyboard)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile ${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .storyboard`.storyboardc $RESOURCE_PATH --sdk ${SDKROOT} ${TARGET_DEVICE_ARGS}" || true
      ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .storyboard`.storyboardc" "$RESOURCE_PATH" --sdk "${SDKROOT}" ${TARGET_DEVICE_ARGS}
      ;;
    *.xib)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile ${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .xib`.nib $RESOURCE_PATH --sdk ${SDKROOT} ${TARGET_DEVICE_ARGS}" || true
      ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .xib`.nib" "$RESOURCE_PATH" --sdk "${SDKROOT}" ${TARGET_DEVICE_ARGS}
      ;;
    *.framework)
      echo "mkdir -p ${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}" || true
      mkdir -p "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      echo "rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" $RESOURCE_PATH ${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}" || true
      rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodel)
      echo "xcrun momc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH"`.mom\"" || true
      xcrun momc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodel`.mom"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodeld`.momd\"" || true
      xcrun momc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodeld`.momd"
      ;;
    *.xcmappingmodel)
      echo "xcrun mapc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcmappingmodel`.cdm\"" || true
      xcrun mapc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcmappingmodel`.cdm"
      ;;
    *.xcassets)
      ABSOLUTE_XCASSET_FILE="$RESOURCE_PATH"
      XCASSET_FILES+=("$ABSOLUTE_XCASSET_FILE")
      ;;
    *)
      echo "$RESOURCE_PATH" || true
      echo "$RESOURCE_PATH" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
if [[ "$CONFIGURATION" == "Debug" ]]; then
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/add.imageset/add.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/add.imageset/add@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/add.imageset/add@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/add.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/arrow_left.imageset/arrow_left.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/arrow_left.imageset/arrow_left@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/arrow_left.imageset/arrow_left@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/arrow_left.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/back_fill.imageset/back_fill.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/back_fill.imageset/back_fill@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/back_fill.imageset/back_fill@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/back_fill.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/camera.imageset/camera.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/camera.imageset/camera@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/camera.imageset/camera@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/camera.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/capture_back.imageset/capture_back.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/capture_back.imageset/capture_back@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/capture_back.imageset/capture_back@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/capture_back.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/capture_focus.imageset/capture_focus.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/capture_focus.imageset/capture_focus@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/capture_focus.imageset/capture_focus@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/capture_focus.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/capture_rotate_camera.imageset/capture_rotate_camera.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/capture_rotate_camera.imageset/capture_rotate_camera@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/capture_rotate_camera.imageset/capture_rotate_camera@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/capture_rotate_camera.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/checked.imageset/checked.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/checked.imageset/checked@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/checked.imageset/checked@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/checked.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/crop_reset.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/crop_reset.imageset/crop_reset.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/crop_reset.imageset/crop_reset@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/crop_reset.imageset/crop_reset@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_adjust.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_adjust.imageset/edit_adjust.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_adjust.imageset/edit_adjust@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_adjust.imageset/edit_adjust@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_brightness.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_brightness.imageset/edit_brightness.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_brightness.imageset/edit_brightness@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_brightness.imageset/edit_brightness@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_contrast.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_contrast.imageset/edit_contrast.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_contrast.imageset/edit_contrast@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_contrast.imageset/edit_contrast@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_crop.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_crop.imageset/edit_crop.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_crop.imageset/edit_crop@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_crop.imageset/edit_crop@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_filter.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_filter.imageset/edit_filter.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_filter.imageset/edit_filter@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_filter.imageset/edit_filter@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_graffiti.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_graffiti.imageset/edit_graffiti.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_graffiti.imageset/edit_graffiti@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_graffiti.imageset/edit_graffiti@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_mosaic.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_mosaic.imageset/edit_mosaic.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_mosaic.imageset/edit_mosaic@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_mosaic.imageset/edit_mosaic@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_paster.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_paster.imageset/edit_paster.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_paster.imageset/edit_paster@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_paster.imageset/edit_paster@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_saturability.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_saturability.imageset/edit_saturability.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_saturability.imageset/edit_saturability@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_saturability.imageset/edit_saturability@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_text.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_text.imageset/edit_text.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_text.imageset/edit_text@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_text.imageset/edit_text@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/icloud.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/icloud.imageset/icloud.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/icloud.imageset/icloud@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/icloud.imageset/icloud@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/livephoto.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/livephoto.imageset/livephoto.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/livephoto.imageset/livephoto@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/livephoto.imageset/livephoto@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/paster_back.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/paster_back.imageset/paster_back.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/paster_back.imageset/paster_back@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/paster_back.imageset/paster_back@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/photo_edited.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/photo_edited.imageset/photo_edited.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/photo_edited.imageset/photo_edited@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/photo_edited.imageset/photo_edited@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/rotate_left.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/rotate_left.imageset/rotate_left.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/rotate_left.imageset/rotate_left@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/rotate_left.imageset/rotate_left@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/rotate_right.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/rotate_right.imageset/rotate_right.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/rotate_right.imageset/rotate_right@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/rotate_right.imageset/rotate_right@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/select_fill.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/select_fill.imageset/select_fill.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/select_fill.imageset/select_fill@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/select_fill.imageset/select_fill@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/select_normal.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/select_normal.imageset/select_normal.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/select_normal.imageset/select_normal@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/select_normal.imageset/select_normal@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/text_nowrap.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/text_nowrap.imageset/text_nowrap.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/text_nowrap.imageset/text_nowrap@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/text_nowrap.imageset/text_nowrap@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/text_wrap.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/text_wrap.imageset/text_wrap.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/text_wrap.imageset/text_wrap@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/text_wrap.imageset/text_wrap@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/trashcan.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/trashcan.imageset/trashcan.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/trashcan.imageset/trashcan@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/trashcan.imageset/trashcan@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/trashcan_open.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/trashcan_open.imageset/trashcan_open.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/trashcan_open.imageset/trashcan_open@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/trashcan_open.imageset/trashcan_open@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/undo.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/undo.imageset/undo.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/undo.imageset/undo@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/undo.imageset/undo@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/video.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/video.imageset/video.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/video.imageset/video@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/video.imageset/video@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/video_play.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/video_play.imageset/video_play.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/video_play.imageset/video_play@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/video_play.imageset/video_play@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/warning.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/warning.imageset/warning.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/warning.imageset/warning@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/warning.imageset/warning@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/add.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/arrow_left.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/back_fill.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/camera.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/capture_back.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/capture_focus.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/capture_rotate_camera.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/checked.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/crop_reset.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_adjust.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_brightness.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_contrast.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_crop.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_filter.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_graffiti.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_mosaic.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_paster.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_saturability.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_text.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/icloud.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/Icons"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/livephoto.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/paster_back.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/photo_edited.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/rotate_left.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/rotate_right.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/select_fill.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/select_normal.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/text_nowrap.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/text_wrap.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/trashcan.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/trashcan_open.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/undo.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/video.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/video_play.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/warning.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Localizable"
fi
if [[ "$CONFIGURATION" == "Release" ]]; then
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/add.imageset/add.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/add.imageset/add@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/add.imageset/add@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/add.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/arrow_left.imageset/arrow_left.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/arrow_left.imageset/arrow_left@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/arrow_left.imageset/arrow_left@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/arrow_left.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/back_fill.imageset/back_fill.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/back_fill.imageset/back_fill@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/back_fill.imageset/back_fill@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/back_fill.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/camera.imageset/camera.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/camera.imageset/camera@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/camera.imageset/camera@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/camera.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/capture_back.imageset/capture_back.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/capture_back.imageset/capture_back@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/capture_back.imageset/capture_back@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/capture_back.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/capture_focus.imageset/capture_focus.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/capture_focus.imageset/capture_focus@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/capture_focus.imageset/capture_focus@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/capture_focus.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/capture_rotate_camera.imageset/capture_rotate_camera.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/capture_rotate_camera.imageset/capture_rotate_camera@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/capture_rotate_camera.imageset/capture_rotate_camera@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/capture_rotate_camera.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/checked.imageset/checked.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/checked.imageset/checked@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/checked.imageset/checked@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/checked.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/crop_reset.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/crop_reset.imageset/crop_reset.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/crop_reset.imageset/crop_reset@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/crop_reset.imageset/crop_reset@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_adjust.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_adjust.imageset/edit_adjust.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_adjust.imageset/edit_adjust@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_adjust.imageset/edit_adjust@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_brightness.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_brightness.imageset/edit_brightness.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_brightness.imageset/edit_brightness@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_brightness.imageset/edit_brightness@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_contrast.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_contrast.imageset/edit_contrast.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_contrast.imageset/edit_contrast@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_contrast.imageset/edit_contrast@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_crop.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_crop.imageset/edit_crop.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_crop.imageset/edit_crop@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_crop.imageset/edit_crop@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_filter.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_filter.imageset/edit_filter.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_filter.imageset/edit_filter@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_filter.imageset/edit_filter@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_graffiti.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_graffiti.imageset/edit_graffiti.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_graffiti.imageset/edit_graffiti@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_graffiti.imageset/edit_graffiti@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_mosaic.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_mosaic.imageset/edit_mosaic.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_mosaic.imageset/edit_mosaic@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_mosaic.imageset/edit_mosaic@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_paster.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_paster.imageset/edit_paster.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_paster.imageset/edit_paster@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_paster.imageset/edit_paster@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_saturability.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_saturability.imageset/edit_saturability.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_saturability.imageset/edit_saturability@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_saturability.imageset/edit_saturability@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_text.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_text.imageset/edit_text.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_text.imageset/edit_text@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_text.imageset/edit_text@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/icloud.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/icloud.imageset/icloud.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/icloud.imageset/icloud@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/icloud.imageset/icloud@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/livephoto.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/livephoto.imageset/livephoto.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/livephoto.imageset/livephoto@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/livephoto.imageset/livephoto@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/paster_back.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/paster_back.imageset/paster_back.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/paster_back.imageset/paster_back@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/paster_back.imageset/paster_back@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/photo_edited.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/photo_edited.imageset/photo_edited.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/photo_edited.imageset/photo_edited@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/photo_edited.imageset/photo_edited@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/rotate_left.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/rotate_left.imageset/rotate_left.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/rotate_left.imageset/rotate_left@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/rotate_left.imageset/rotate_left@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/rotate_right.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/rotate_right.imageset/rotate_right.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/rotate_right.imageset/rotate_right@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/rotate_right.imageset/rotate_right@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/select_fill.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/select_fill.imageset/select_fill.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/select_fill.imageset/select_fill@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/select_fill.imageset/select_fill@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/select_normal.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/select_normal.imageset/select_normal.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/select_normal.imageset/select_normal@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/select_normal.imageset/select_normal@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/text_nowrap.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/text_nowrap.imageset/text_nowrap.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/text_nowrap.imageset/text_nowrap@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/text_nowrap.imageset/text_nowrap@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/text_wrap.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/text_wrap.imageset/text_wrap.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/text_wrap.imageset/text_wrap@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/text_wrap.imageset/text_wrap@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/trashcan.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/trashcan.imageset/trashcan.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/trashcan.imageset/trashcan@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/trashcan.imageset/trashcan@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/trashcan_open.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/trashcan_open.imageset/trashcan_open.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/trashcan_open.imageset/trashcan_open@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/trashcan_open.imageset/trashcan_open@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/undo.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/undo.imageset/undo.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/undo.imageset/undo@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/undo.imageset/undo@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/video.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/video.imageset/video.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/video.imageset/video@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/video.imageset/video@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/video_play.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/video_play.imageset/video_play.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/video_play.imageset/video_play@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/video_play.imageset/video_play@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/warning.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/warning.imageset/warning.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/warning.imageset/warning@2x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/warning.imageset/warning@3x.png"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/add.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/arrow_left.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/back_fill.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/camera.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/capture_back.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/capture_focus.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/capture_rotate_camera.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/checked.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/crop_reset.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_adjust.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_brightness.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_contrast.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_crop.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_filter.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_graffiti.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_mosaic.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_paster.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_saturability.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/edit_text.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/icloud.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/Icons"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/livephoto.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/paster_back.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/photo_edited.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/rotate_left.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/rotate_right.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/select_fill.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/select_normal.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/text_nowrap.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/text_wrap.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/trashcan.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/trashcan_open.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/undo.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/video.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/video_play.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Assets.xcassets/warning.imageset"
  install_resource "${PODS_ROOT}/../../WLPhotoPicker/Resources/Localizable"
fi

mkdir -p "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
if [[ "${ACTION}" == "install" ]] && [[ "${SKIP_INSTALL}" == "NO" ]]; then
  mkdir -p "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
  rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
rm -f "$RESOURCES_TO_COPY"

if [[ -n "${WRAPPER_EXTENSION}" ]] && [ "`xcrun --find actool`" ] && [ -n "${XCASSET_FILES:-}" ]
then
  # Find all other xcassets (this unfortunately includes those of path pods and other targets).
  OTHER_XCASSETS=$(find -L "$PWD" -iname "*.xcassets" -type d)
  while read line; do
    if [[ $line != "${PODS_ROOT}*" ]]; then
      XCASSET_FILES+=("$line")
    fi
  done <<<"$OTHER_XCASSETS"

  if [ -z ${ASSETCATALOG_COMPILER_APPICON_NAME+x} ]; then
    printf "%s\0" "${XCASSET_FILES[@]}" | xargs -0 xcrun actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${!DEPLOYMENT_TARGET_SETTING_NAME}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
  else
    printf "%s\0" "${XCASSET_FILES[@]}" | xargs -0 xcrun actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${!DEPLOYMENT_TARGET_SETTING_NAME}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}" --app-icon "${ASSETCATALOG_COMPILER_APPICON_NAME}" --output-partial-info-plist "${TARGET_TEMP_DIR}/assetcatalog_generated_info_cocoapods.plist"
  fi
fi
