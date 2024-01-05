#! bin/bash
GITHUB_RUN_ID=`uuidgen` \
GITHUB_RUN_ATTEMPT=1 \
GITHUB_REF_NAME=my_funky_branch \
GITHUB_SHA=`echo -n $(uuidgen) | openssl dgst -sha1 | cut -c14-` \
GITHUB_SERVER_URL="https://github.com" \
GITHUB_REPOSITORY=merepo \
GITHUB_ACTOR=snackattas \
bundle exec parallel_rspec -n 2 \
-- \
--require ./rspec_db_formatter/formatter.rb \
--format RSpecDBFormatter \
-- \
spec


GITHUB_RUN_ID=`uuidgen` \
GITHUB_RUN_ATTEMPT=1 \
GITHUB_REF_NAME=my_funky_branch \
GITHUB_SHA=`echo -n $(uuidgen) | openssl dgst -sha1 | cut -c14-` \
GITHUB_SERVER_URL="https://github.com" \
GITHUB_REPOSITORY=merepo \
GITHUB_ACTOR=snackattas \
bundle exec rspec \
--require ./rspec_db_formatter/formatter.rb \
--format RSpecDBFormatter \
spec