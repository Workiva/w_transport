FROM drydock-prod.workiva.net/workiva/dart2_base_image:0.0.0-dart2.18.7gha
WORKDIR /build/
ADD . /build/
RUN dart pub get
FROM scratch
