FROM drydock-prod.workiva.net/workiva/smithy-runner-generator:179735 as build
ARG NPM_TOKEN
# Build Environment Vars
ARG BUILD_ID
ARG BUILD_NUMBER
ARG BUILD_URL
ARG GIT_COMMIT
ARG GIT_BRANCH
ARG GIT_TAG
ARG GIT_COMMIT_RANGE
ARG GIT_HEAD_URL
ARG GIT_MERGE_HEAD
ARG GIT_MERGE_BRANCH
WORKDIR /build/
ADD . /build/
RUN echo "installing npm packages"
RUN npm install
RUN echo "Starting the script sections" && \
		pub get && \
		echo "Script sections completed"
ARG BUILD_ARTIFACTS_BUILD=/build/pubspec.lock

RUN mkdir /audit/
ARG BUILD_ARTIFACTS_AUDIT=/audit/*

RUN npm ls -s --json --depth=10 > /audit/npm.lock || [ $? -eq 1 ] || exit
FROM scratch
