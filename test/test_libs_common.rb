#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/test_helper.rb'
include Bind2Route53

class TestLibsCommon < Test::Unit::TestCase
  def setup
  end

  def test_zonename2stackname
    prefix     = 'R53-'
    test_sets  = [
      ['abc-def.com'     ,'R53-Abc-def-Com'       ], 
      ['abc-def.com.'    ,'R53-Abc-def-Com'       ], 
      ['abc.def.com'     ,'R53-Abc-Def-Com'       ],
      ['abcdef.com'      ,'R53-Abcdef-Com'        ],
      ['abc-1def.com'    ,'R53-Abc-DASH-1def-Com' ],
      ['abc.1def.com'    ,'R53-Abc-1def-Com'      ],
      ['abc1def.com'     ,'R53-Abc1def-Com'       ],
      ['0/25.abc.com'    ,'R53-0-SLA-25-Abc-Com'  ],
      ['0\05725.abc.com' ,'R53-0-SLA-25-Abc-Com'  ],
    ]
    test_sets.each do |test_set|
      assert_equal test_set[1], zonename2stackname(test_set[0], prefix)
    end
  end

  def test_zonename2stackname_returns_unique_stackname
    prefix     = 'R53-'
    test_sets  = [
      ['abc-def.com',  'abc.def.com',  'abcdef.com'],
      ['abc-1def.com', 'abc.1def.com', 'abc1def.com']
    ]

    test_sets.each do |test_set|
      stacknames = Array.new
      test_set.each do |zonename|
        stacknames << zonename2stackname(zonename, prefix)
      end
      assert_equal stacknames.length, stacknames.uniq.length
    end
  end

  def test_zonename2resourcename
    prefix     = 'R53'
    test_sets  = [
      ['abc-def.com'    ,'R53AbcdefCom' ], 
      ['abc-def.com.'   ,'R53AbcdefCom' ], 
      ['abc.def.com'    ,'R53AbcDefCom' ],
      ['abcdef.com'     ,'R53AbcdefCom' ],
      ['abc-1def.com'   ,'R53Abc1defCom'],
      ['abc.1def.com'   ,'R53Abc1defCom'],
      ['abc1def.com'    ,'R53Abc1defCom'],
      ['0/25.abc.com'   ,'R53025AbcCom' ],
      ['0\05725.abc.com','R53025AbcCom' ]
    ]

    test_sets.each do |test_set|
      assert_equal test_set[1], zonename2resourcename(test_set[0], prefix)
    end

  end
end
