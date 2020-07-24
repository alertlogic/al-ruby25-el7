set -ex

# if local build, exit
if [ -z "${CODEBUILD_BUILD_IMAGE}" ]; then
  exit 0
fi

# download latest external dependancies
mkdir -p RPMS/{x86_64,noarch}/
yumdownloader --destdir=RPMS/x86_64/ \
  rh-ruby25-rubygem-psych \
  rh-ruby25-ruby-libs \
  rh-ruby25-rubygem-did_you_mean \
  rh-ruby25-rubygem-io-console \
  rh-ruby25-ruby \
  rh-ruby25-ruby-devel \
  rh-ruby25-runtime \
  rh-ruby25-rubygem-json \
  rh-ruby25-rubygem-bigdecimal \
  rh-ruby25-rubygem-openssl

yumdownloader --destdir=RPMS/noarch/ \
  rh-ruby25-ruby-irb \
  rh-ruby25-rubygem-rdoc \
  rh-ruby25-rubygems \
  rh-ruby25-rubygems-devel

# upload files
DISTRIBUTION="el7"
RELEASE_DIRS="dev"
# if production release, add prod
if [ ! -z "${PROD_RELEASE}" ]; then
  RELEASE_DIRS="${RELEASE_DIRS} prod"
fi
for RELEASE_DIR in $RELEASE_DIRS; do
  for DIR in RPMS SRPMS SPECS SOURCES; do
    aws s3 cp --recursive ./${DIR}/ s3://${S3REPOBUCKET}/${RELEASE_DIR}/${DISTRIBUTION}/${DIR}/
  done
done
