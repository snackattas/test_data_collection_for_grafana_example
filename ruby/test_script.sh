#!/bin/bash
# GITHUB_RUN_ID=`uuidgen` \
# GITHUB_RUN_ATTEMPT=1 \
# GITHUB_REF_NAME=my_funky_branch \
# GITHUB_SHA=`echo -n $(uuidgen) | openssl dgst -sha1 | cut -c14-` \
# GITHUB_SERVER_URL="https://github.com" \
# GITHUB_REPOSITORY=merepo \
# GITHUB_ACTOR=snackattas \
# bundle exec parallel_rspec -n 2 \
# -- \
# --require ./rspec_db_formatter/formatter.rb \
# --format RSpecDBFormatter \
# --format documentation \
# --tag api --tag unit \
# -- \
# spec


GITHUB_RUN_ID=AD3B2443-736E-4EECa-AaAD4-1D1833EC77DD \
GITHUB_RUN_ATTEMPT=1 \
GITHUB_REF_NAME=my_funky_branch \
GITHUB_SHA=`echo -n $(uuidgen) | openssl dgst -sha1 | cut -c14-` \
GITHUB_SERVER_URL="https://github.com" \
GITHUB_REPOSITORY=merepo \
GITHUB_ACTOR=snackattas \
bundle exec parallel_rspec \
-- \
--require ./rspec_db_formatter/formatter.rb \
--format RSpecDBFormatter \
--only-failures \
-- \
spec



# GITHUB_RUN_ID=`uuidgen` \
# GITHUB_RUN_ATTEMPT=1 \
# GITHUB_REF_NAME=my_funky_branch \
# GITHUB_SHA=`echo -n $(uuidgen) | openssl dgst -sha1 | cut -c14-` \
# GITHUB_SERVER_URL="https://github.com" \
# GITHUB_REPOSITORY=merepo \
# GITHUB_ACTOR=snackattas \
# bundle exec rspec \
# --tag api --tag unit \
# --format documentation \
# --require ./rspec_db_formatter/formatter.rb \
# --format RSpecDBFormatter