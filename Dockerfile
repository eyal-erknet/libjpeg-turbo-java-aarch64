FROM --platform=arm64 rockylinux:9

ARG JDK_VERSION=11

RUN dnf --enablerepo=devel install -y \
    git \
    java-${JDK_VERSION}-openjdk \
    java-${JDK_VERSION}-openjdk-devel \
    nasm \
    make \
    autoconf \
    automake \
    libtool

RUN mkdir -p /build && \
    mkdir -p /assets && \
    cd /build && \
    git clone --recurse-submodules https://github.com/CGDogan/libjpeg-turbo-java.git && \
    export JAVA_HOME=$(find /usr/lib/jvm -maxdepth 1 -type d -name "java-${JDK_VERSION}-openjdk-*" | head -n 1) && \
    export CPPFLAGS="-I${JAVA_HOME}/include -I${JAVA_HOME}/include/linux" && \
    cd /build/libjpeg-turbo-java/libjpeg-turbo && \
    autoreconf -fiv && \
    mkdir build && \
    cd build && \
    ../configure --with-java --enable-shared && \
    make && \
    cd /build/libjpeg-turbo-java && \
    ./gradlew --stacktrace clean jar && \
    cd build/libs && \
    jar xvvf libjpeg-turbo*.jar && \
    mkdir -p META-INF/lib/linux_arm64 && \
    cp ../../libjpeg-turbo/build/.libs/libturbojpeg.so META-INF/lib/linux_arm64/ && \
    jar uvvf libjpeg-turbo*.jar META-INF/lib/*

VOLUME [ "/export" ]

CMD cp /build/libjpeg-turbo-java/build/libs/libjpeg-turbo*.jar /export && \
    cp -L /build/libjpeg-turbo-java/libjpeg-turbo/build/.libs/*.so /export
