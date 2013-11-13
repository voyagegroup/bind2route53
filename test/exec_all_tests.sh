#!/bin/bash 
cd "./test/"

TESTS=(\
"test_libs_common.rb" \
"test_libs_cloudformation.rb" \
"test_my_option_parser.rb" \ 
"test_convert_zonefile.rb" \
)

echo "==== TEST START ====="

STATUS=0
for TEST in ${TESTS[@]}; do
	bundle exec rg $TEST
  if [ $? = 1 ];then STATUS=1; fi
done

echo "====  TEST END  ====="
exit $STATUS
