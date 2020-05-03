[[ "${CO2_HONESTY_CHECKER_VERSION}" == "" ]] && (echo "CO2_HONESTY_CHECKER_VERSION is not set" && exit 1)

FILEJAR=co2-honesty-checker-${CO2_HONESTY_CHECKER_VERSION}.jar

echo "Downloading ${FILEJAR}..."
curl --fail -L --output ${FILEJAR} https://github.com/diogenes-lang/diogenes-honesty/releases/download/v${CO2_HONESTY_CHECKER_VERSION}/co2-honesty-checker-${CO2_HONESTY_CHECKER_VERSION}.jar

[[ $? != 0 ]] && echo "There was an error downloading ${FILEJAR}, exiting..." && exit 1

echo "Installing ${FILEJAR}..."
mvn install:install-file \
  -Dfile=${FILEJAR} \
  -DgroupId=it.unica.co2 \
  -DartifactId=co2-honesty-checker \
  -Dversion=${CO2_HONESTY_CHECKER_VERSION} \
  -Dpackaging=jar

[[ $? != 0 ]] && echo "There was an error installing ${FILEJAR}, exiting..." && exit 2

exit 0