# code-server --bind-addr=0.0.0.0:8080 --auth=none --disable-telemetry --cert
USER_DATA_DIR=/usr/user_data
mkdir -p $USER_DATA_DIR
code-server --bind-addr=0.0.0.0:8080 --auth=password --disable-telemetry --cert --disable-workspace-trust --user-data-dir=$USER_DATA_DIR --disable-workspace-trust --disable-getting-started-override --install-extension 'James-Yu.latex-workshop'
