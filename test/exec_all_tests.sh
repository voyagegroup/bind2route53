#!/bin/bash 
cd "./test/"

COLOR=$1

TESTS=(\
"test_libs_common.rb" \
"test_libs_cloudformation.rb" \
"test_my_option_parser.rb" \ 
"test_convert_zonefile.rb" \
)

echo "==== TEST START ====="

STATUS=0

TEST_COM='rg'
if [ -z ${COLOR} ];then
	TEST_COM='ruby'
fi

for TEST in ${TESTS[@]}; do
	bundle exec $TEST_COM $TEST
	if [ $? = 1 ];then STATUS=1; fi
done

echo "====  TEST END  ====="
exit $STATUS
