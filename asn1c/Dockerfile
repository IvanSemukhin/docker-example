FROM base-26.04:2026-04-20 AS builder
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt -y upgrade && \
  apt -y install --no-install-recommends \
  git build-essential automake libtool flex wget coreutils util-linux ca-certificates

RUN wget https://mirror.truenetwork.ru/gnu/bison/bison-2.7.1.tar.xz && \
  echo "b409adcbf245baadb68d2f66accf6fdca5e282cafec1b865f4b5e963ba8ea7fb bison-2.7.1.tar.xz" | sha256sum -c && \
  tar -xf bison-2.7.1.tar.xz && \
  cd bison-2.7.1 && \
  sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' lib/fseterr.c && \
  ./configure && \
  make -j$(nproc) && \
  make check -j$(nproc) && \
  make install && \
  cd .. && \
  git clone https://github.com/mouse07410/asn1c.git && \
  cd asn1c && \
  git fetch --tags && \
  git checkout $(git describe --tags --abbrev=0 $(git rev-list --tags --max-count=1)) && \
  test -f configure || autoreconf -iv && \
  ./configure && \
  make -j$(nproc) && \
  make check && \
  make install DESTDIR=/tmp/asn1c-root

FROM base-26.04:2026-04-20
ENV DEBIAN_FRONTEND=noninteractive
COPY --from=builder /tmp/asn1c-root/ /

RUN --mount=type=secret,id=user_password \
  apt update && \
  apt -y upgrade || apt -y install --fix-missing || true && \
  useradd -m user && \
  USER_PASSWORD=$(cat /run/secrets/user_password) && \
  echo "user:${USER_PASSWORD}" | chpasswd && \
  mkdir -p /home/user && \
  chown user:user /home/user && \
  echo "user ALL=(ALL:ALL) ALL" >> /etc/sudoers && \
  apt clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER user
WORKDIR /home/user
CMD ["/bin/bash"]
