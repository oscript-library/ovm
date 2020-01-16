#!/bin/bash
set -e

oscript tasks/coverage.os

temp=`cat src/cmd/Модули/ПараметрыПриложения.os | grep "Версия = " | sed 's|[^"]*"||' | sed -r 's/".+//'`
version=${temp##*|}

if [ "$TRAVIS_BRANCH" == "develop" ] && [ "$TRAVIS_PULL_REQUEST" == "false" ]; then
     sonar-scanner \
         -Dsonar.host.url=https://sonar.openbsl.org \
         -Dsonar.login=$SONAR_TOKEN \
         -Dsonar.projectVersion=$version\
         -Dsonar.scanner.skip=false
fi
