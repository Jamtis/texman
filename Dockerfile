FROM texlive/texlive

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get autoremove -y
RUN apt-get autoclean -y

RUN curl -fsSL https://code-server.dev/install.sh | sh
RUN code-server --install-extension 'James-Yu.latex-workshop'

RUN echo 'alias update_codeserver="curl -fsSL https://code-server.dev/install.sh | sh"' >> ~/.bashrc

ADD start-container.sh /

ENTRYPOINT ["sh", "/start-container.sh"]
