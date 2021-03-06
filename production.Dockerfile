FROM antoniogamiz/documentable-testing

LABEL version="1.0.0" maintainer="Antonio Gamiz <antoniogamiz10@gmail.com>"

ARG branch_name=master

RUN git clone -b $branch_name --single-branch https://github.com/Raku/Documentable.git \
    && cd Documentable \
    && zef install --deps-only --/test . \
    && zef install . \
    && cd .. \
    && mkdir /documentable

WORKDIR /documentable

ENTRYPOINT ["sh"]