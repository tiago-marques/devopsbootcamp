#####
## This Dockerfile is used in order to build a distroless container that runs the Quarkus application in native (no JVM)
##
##
## docker build -t devopsbootcamp/java .
##
## Then run the container using:
##
## docker run --rm -it devopsbootcamp/java
##
#####
### Stage 1 : build with maven builder image with native capabilities
FROM maven:3.8.4-openjdk-17 as mavencache
ENV MAVEN_OPTS="-Dmaven.repo.local=/mvnrepo"
COPY pom.xml /app/
WORKDIR /app
RUN mvn test-compile -DskipTests=true dependency:resolve dependency:resolve-plugins
### Stage 2 : build with graalvm builder image a static image using musl
FROM ghcr.io/graalvm/graalvm-ce:java17-21.3.0 AS native-image
USER root
ENV MAVEN_OPTS="-Dmaven.repo.local=/mvnrepo"
COPY --from=mavencache /mvnrepo/ /mvnrepo/
COPY . /app
WORKDIR /app
ENV GRAALVM_HOME=/usr
ARG TOOLCHAIN_DIR="/staticlibs"
WORKDIR /staticlibs
RUN gu install native-image
COPY x86_64-linux-musl-native.tgz musl.tar.gz
RUN tar -xvzf musl.tar.gz -C /staticlibs --strip-components 1
ENV CC=${TOOLCHAIN_DIR}/bin/x86_64-linux-musl-gcc
RUN curl -L -o zlib.tar.gz https://zlib.net/zlib-1.2.11.tar.gz && \
   mkdir zlib && tar -xvzf zlib.tar.gz -C zlib --strip-components 1 && cd zlib && \
   ./configure --prefix=${TOOLCHAIN_DIR} --static && \
    make && make install && rm -rf zlib && rm -f zlib.tar.gz
ENV PATH="$PATH:${TOOLCHAIN_DIR}"
ENV PATH="$PATH:${TOOLCHAIN_DIR}/bin"
WORKDIR /app
RUN ./mvnw package -Pnative -Dmaven.test.skip=true -DskipTests=true && \
    mkdir -p /dist && \
    cp /app/target/*-runner /dist/application
WORKDIR /app
USER root
RUN chmod 777 /dist
RUN ./upx --lzma /dist/application
### Stage 3 : Final image based on scratch containing only the binary
FROM scratch
COPY --chown=1000 --from=native-image /dist /work
# it is possible to add timezone, certificat and new user/group
# COPY --from=xxx /usr/share/zoneinfo /usr/share/zoneinfo
# COPY --from=xxx /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
# COPY --from=xxx /etc/passwd /etc/passwd
# COPY --from=xxx /etc/group /etc/group
EXPOSE 8080
USER 1000
WORKDIR /work/
CMD ["./application", "-Djava.io.tmpdir=/work/tmp"]