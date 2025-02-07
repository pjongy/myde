DART_VERSION=3.6.2
wget https://storage.googleapis.com/dart-archive/channels/stable/release/3.6.2/sdk/dartsdk-linux-x64-release.zip -O $INSTALL_PATH/dartsdk-linux-x64-release.zip
sudo unzip $INSTALL_PATH/dartsdk-linux-x64-release.zip -d /opt/dart

sudo update-alternatives --remove-all dart
sudo update-alternatives --remove-all dartaotruntime
sudo update-alternatives --install /usr/bin/dart dart /opt/dart/dart-sdk/bin/dart 100 --force
sudo update-alternatives --install /usr/bin/dartaotruntime dartaotruntime /opt/dart/dart-sdk/bin/dartaotruntime 100 --force
