#!/bin/bash
# set -o xtrace
set -e

echo "PROFILES: ${PROFILES}"

export CONTAINER_DIR=/0/java # $HOSTNAME may be a suitable unique identifier for multiple instances (pods) of the same deployment

SWARM_ARGS=""
if [ -n "${JENKINS_USERNAME}" ]; then
    SWARM_ARGS="${SWARM_ARGS} -username ${JENKINS_USERNAME}"
fi

if [ -n "${JENKINS_PASSWORD}" ]; then
    SWARM_ARGS="${SWARM_ARGS} -passwordEnvVariable JENKINS_PASSWORD"
fi

if [ -n "${SWARM_EXECUTORS}" ]; then
    SWARM_ARGS="${SWARM_ARGS} -executors ${SWARM_EXECUTORS}"
fi

SWARM_ARGS="${SWARM_ARGS} -labels jdk21"

exec java -jar "/usr/share/jenkins/swarm-client-${SWARM_CLIENT_VERSION}.jar" -disableSslVerification -fsroot "${JENKINS_HOME}${CONTAINER_DIR}" ${SWARM_ARGS} -master "http://${JENKINS_HOST}:${JENKINS_PORT}${JENKINS_PREFIX}"
