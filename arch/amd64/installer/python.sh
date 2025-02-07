PYTHON_VERSION_MAJOR=3.12
PYTHON_VERSION=$PYTHON_VERSION_MAJOR.0

/opt/.pyenv/bin/pyenv install $PYTHON_VERSION

sudo update-alternatives --remove-all python3
sudo update-alternatives --remove-all pip3

sudo update-alternatives --install /usr/bin/python3 python3 $HOME/.pyenv/versions/$PYTHON_VERSION/bin/python3 100 --force
sudo update-alternatives --install /usr/bin/pip3 pip3 $HOME/.pyenv/versions/$PYTHON_VERSION/bin/pip3 100 --force
sudo ln -s /usr/share/pyshared/lsb_release.py $HOME/.pyenv/versions/$PYTHON_VERSION/lib/python$PYTHON_VERSION_MAJOR/site-packages/lsb_release.py

# Install ptpython (python console)
python3 -m pip install ptpython
sudo update-alternatives --remove-all ptpython
sudo update-alternatives --install /usr/bin/ptpython ptpython $HOME/.pyenv/versions/$PYTHON_VERSION/bin/ptpython 100 --force

# python lsp server (pylsp)
python3 -m pip install "python-lsp-server[all]"
