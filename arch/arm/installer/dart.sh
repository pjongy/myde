DART_VERSION=3.2.3

wget https://storage.googleapis.com/dart-archive/channels/stable/release/$DART_VERSION/sdk/dartsdk-linux-arm64-release.zip -O $INSTALL_PATH/dartsdk-linux-arm64-release.zip
unzip $INSTALL_PATH/dartsdk-linux-arm64-release.zip -d /opt/dart

update-alternatives --remove-all dart
update-alternatives --remove-all dartaotruntime
update-alternatives --install /usr/bin/dart dart /opt/dart/dart-sdk/bin/dart 100 --force
update-alternatives --install /usr/bin/dartaotruntime dartaotruntime /opt/dart/dart-sdk/bin/dartaotruntime 100 --force
