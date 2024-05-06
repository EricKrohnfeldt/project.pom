#!/bin/bash

#
# This file is part of herbmarshall.com: project.pom  ( hereinafter "project.pom" ).
# project.pom is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 2 of the License, or (at your option) any later version.
# project.pom is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with project.pom. If not, see <https://www.gnu.org/licenses/>.
#

set -e

# Using non-cdlocal because may be ran by jenkins
cd "$( dirname "$( realpath "$( readlink -f "$0" )" )" )"

OPERATION='build'
DEST=
BUILD_DIR=$( pwd )
SKIP_CHECKS=
SKIP_TESTS=

printUsage() {
  echo 'Options:'
  echo '   -c --noChecks   Ignore run checkstyle'
  echo '   -t --noTests    Dont run unit tests ( or coverage )'
  echo '   -x              Both --noChecks and --noTests'
}

while test $# -gt 0
do
		case "$1" in
		  -\?)
		    printUsage
		    exit 1
		    ;;
		  -c|--noChecks)
		    SKIP_CHECKS='-Dcheckstyle.skip=true'
		    ;;
		  -t|--noTests)
		    SKIP_TESTS='-Dmaven.test.skip.exec'
		    ;;
		  -x)
		    SKIP_CHECKS='-Dcheckstyle.skip=true'
		    SKIP_TESTS='-Dmaven.test.skip.exec'
		    ;;
			*)
				DEST="$1"
				;;
		esac
		shift
done


if [[ "build" == "${OPERATION}" ]]; then

  # Because maven.herb uses jenkins user instead of root
  WORK_DIR="/home/jenkins/workspace"
  M2_DIR="${HOME}/.m2"

  docker run -it --rm \
    -v "${M2_DIR}":/home/jenkins/.m2 \
    -v "${BUILD_DIR}":"${WORK_DIR}" \
    -w "${WORK_DIR}" \
    docker.herb.herbmarshall.com/maven.herb \
    mvn clean install javadoc:javadoc ${SKIP_CHECKS} ${SKIP_TESTS}

fi
