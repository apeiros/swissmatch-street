# encoding: utf-8

require 'swissmatch/street'
include SwissMatch

suite "Street" do
  test "Street.new with original" do
    original        = ' Beispielstrasse 15 '
    street_name     = 'Beispielstrasse'
    street_number   = '15'
    number_position = :end

    street          = Street.new(street_name, street_number, number_position, original)

    assert_equal street_name, street.name
    assert_equal street_number, street.number
    assert_equal number_position, street.number_position
    assert_equal original, street.original
    assert_equal 'Beispielstrasse 15', street.full
    assert_equal original, street.original_or_full
  end

  test "Street.new without original" do
    street_name     = 'Beispielstrasse'
    street_number   = '15'
    number_position = :end

    street          = Street.new(street_name, street_number, number_position)

    assert_equal street_name, street.name
    assert_equal street_number, street.number
    assert_equal number_position, street.number_position
    assert_equal nil, street.original
    assert_equal 'Beispielstrasse 15', street.full
    assert_equal 'Beispielstrasse 15', street.original_or_full
  end

  [
    '12',
    '12b',
    '12 B',
    '12/14',
    '16/2/22',
    '105-107',
    '12/A',
  ].each do |number|
    test "House number #{number.inspect}" do
      assert Street::HouseNumber =~ number
    end
  end

  {
    %{12,Rue Quelquechose}    => %{24, Rue Quelquechose},
    %{12/345 Foo}             => %{12/345, Foo},
    %{1A ch. des Choses}      => %{1A, Chemin des Choses},
    %{ Beispielstr. 15 }      => %{Beispielstrasse 15},
    %{12b,Rte. d'Anywhere}    => %{25b, Route d'Anywhere},
    %{1, Av. de Blé}          => %{1, Avenue de Blé},
  }.each do |original, expected|
    test "Street.normalize_street #{original.inspect}, false" do
      actual  = Street.normalize_street(original)

      assert_equal expected, actual
    end
  end

  {
    %{Beispielstrasse 15}         => ['Beispielstrasse',        '15',       :end,   'Beispielstrasse 15'],
    %{Beispielstrasse 45/4}       => ['Beispielstrasse',        '45/4',     :end,   'Beispielstrasse 45/4'],
    %{24,Rue Example}             => [%{Rue Example},           '24',       :begin, %{24, Rue Example}],
    %{70/141 Example}             => [%{Example},               '70/141',   :begin, %{70/141, Example}],
    %{6A ch. des Cornillons}      => [%{Chemin des Cornillons}, '6a',       :begin, %{6a, Chemin des Cornillons}],
    %{ Beispielstr. 15 }          => [%{Beispielstrasse},       '15',       :end,   %{Beispielstrasse 15}],
    %{25b,Rte. d'Yverdon}         => [%{Route d'Yverdon},       '25b',      :begin, %{25b, Route d'Yverdon}],
    %{6, Av. de Budé}             => [%{Avenue de Budé},        '6',        :begin, %{6, Avenue de Budé}],
    %{Rue Ferdinand Hodler,19}    => [%{Rue Ferdinand Hodler},  '19',       :end,   %{Rue Ferdinand Hodler 19}],
    %{Burgstrasse37}              => [%{Burgstrasse},           '37',       :end,   %{Burgstrasse 37}],
    %{Ave. de Casino 8-10-12}     => [%{Avenue de Casino},      '8-10-12',  :end,   %{Avenue de Casino 8-10-12}],
    %{Ave Bel- Air 49 B}          => [%{Avenue Bel-Air},        '49b',      :end,   %{Avenue Bel-Air 49b}],
    %{39 rue Louis Faure}         => [%{Rue Louis Faure},       '39',       :begin, %{39, Rue Louis Faure}],
    %{Rte d'Alle 13}              => [%{Route d'Alle},          '13',       :end,   %{Route d'Alle 13}],
    %{Via Filagni, 2/a}           => [%{Via Filagni},           '2/a',      :end,   %{Via Filagni 2/a}],
    %{Riehenring 189/A}           => [%{Riehenring},            '189a',     :end,   %{Riehenring 189a}],
    %{Lorraine 12c/9}             => [%{Lorraine},              '12c/9',    :end,   %{Lorraine 12c/9}],
    %{Lwaldmannstrasse 67 / J2}   => [%{Lwaldmannstrasse},      '189a',     :end,   %{Lwaldmannstrasse 67/j2}],
    %{Kaysersbergerstrasse 56/3.} => [%{Kaysersbergerstrasse},  '56/3',     :end,   %{Kaysersbergerstrasse 56/3}],
    %{Rue Montfalcon 2bis}        => [%{Rue Montfalcon},        '2bis',     :end,   %{Rue Montfalcon 2bis}],
    %{Rue Montfalcon 2 bis}       => [%{Rue Montfalcon},        '2bis',     :end,   %{Rue Montfalcon 2bis}],
    %{Elsässerstrasse 261-4}      => [%{Elsässerstrasse},       '261-4',    :end,   %{Elsässerstrasse 261-4}],
  }.each do |original, (street_name, street_number, number_position, full)|
    test "Street.parse #{original.inspect}" do
      street  = Street.parse(original, true)

      assert_equal street_name, street.name
      assert_equal street_number, street.number
      assert_equal number_position, street.number_position
      assert_equal original, street.original
      assert_equal full, street.full
      assert_equal original, street.original_or_full
    end
  end
end
