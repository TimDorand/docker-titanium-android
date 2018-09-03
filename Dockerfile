FROM ubuntu:14.04

# Install java8
RUN apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:webupd8team/java && apt-get update
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN apt-get install -y oracle-java8-installer

# Install Deps
RUN dpkg --add-architecture i386 && apt-get update && \
    apt-get install -y --force-yes expect git wget libc6-i386 lib32stdc++6 \
    lib32gcc1 lib32ncurses5 lib32z1 python curl unzip

# Install Android SDK
RUN cd /opt && wget --output-document=android-sdk-tools.zip \
    --quiet https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip && \
    unzip android-sdk-tools.zip -d android-sdk-tools && rm -f android-sdk-tools.zip && \
    chown -R root.root android-sdk-tools

# Install Android NDK
RUN cd /opt && wget --output-document=android-ndk.zip \
    --quiet https://dl.google.com/android/repository/android-ndk-r17b-linux-x86_64.zip && \
    unzip -q android-ndk.zip && rm -f android-ndk.zip

# Setup environment
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
ENV ANDROID_HOME /opt/android-sdk-tools/
ENV ANDROID_NDK_HOME /opt/android-ndk-r12b
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

# Install node6
RUN rm -vfr /var/lib/apt/lists/*
RUN cd /tmp && curl -sL https://deb.nodesource.com/setup_6.x -o /tmp/nodesource_setup.sh && chmod +x /tmp/nodesource_setup.sh && /tmp/nodesource_setup.sh
RUN apt-get update -y && apt-get install nodejs subversion -y

# Install sdk elements*
RUN echo "y" | /opt/android-sdk-tools/tools/bin/sdkmanager "platform-tools" "platforms;android-25" "platforms;android-26" "build-tools;26.0.2"
RUN echo "y" | /opt/android-sdk-tools/tools/bin/sdkmanager --update

WORKDIR /home
RUN npm install -g titanium alloy tisdk
RUN tisdk install 7.2.0.GA

WORKDIR /home/root
COPY tiapp.xml ./
COPY appicon.png default.png DefaultIcon.png itunesConnect.png MarketplaceArtwork.png ./
COPY plugins ./plugins/
COPY i18n ./i18n/
COPY scripts ./scripts/
COPY tools ./tools/
COPY app ./app/

RUN ti build -p android --force --build-only

CMD [ "/bin/true" ]
