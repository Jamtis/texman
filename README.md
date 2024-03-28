building the image: `podman build -t nicholasbrandt/texman .`
to push an image to hub.docker.com: `podman push nicholasbrandt/texman`
login to docker.io: `podman login docker.io`
(re-)install: sh install.sh /w sudo installed

Installing the Latex-Workshop in the Dockerfile doesn't work atm, because we mount /root/.local/share/code-server/ instead of /root/.local/share/code-server/User which works (bug? permission issue?)
