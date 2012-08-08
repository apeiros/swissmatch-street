# encoding: utf-8



require 'swissmatch/street/version'



module SwissMatch

  # Street
  # Parse and handle street names and numbers.
  class Street
    # House number formats:
    # '12'
    # '12b'
    # '12bis', '12BIS', '12Bis', '12 bis', … - see development/Noteworthy_things.txt
    # '12 B'
    # '12/14'
    # '105-107'
    # '16/2/22'
    # '8-10-12'
    # '16-2/22'
    # '16/2-22'
    HouseNumber                       = /\d+(?:\x20?\w{1,2}|(?:\/\d+|-\d+\w{1,2})*)/
    FrontHouseNumber                  = /\d+(?:\x20?(?!ch|bd|av)\w{1,2}|(?:\/\d+|-\d+\w{1,2})*)/i
    MatchStreetAndStreetNumberGerman  = /\A(.*?)(?:(?: |, ?)(#{HouseNumber}))\z/
    MatchStreetAndStreetNumberFrench  = /\A(?:(#{FrontHouseNumber}), )(.*?)\z/
    MatchBrokenStreetAndNumberGerman  = /\A(.*?)(?:(#{HouseNumber}))\z/
    MatchBrokenStreetAndNumberFrench  = /\A(?:(#{FrontHouseNumber})[.,]| )(.*?)\z/

    # Abbreviations that can be expanded
    Replacements = {
      'ch'    => 'Chemin',
      'chem'  => 'Chemin',
      'rte'   => 'Route',
      'bd'    => 'Boulevard',
      'av'    => 'Avenue',
      'ave'   => 'Avenue',
      'str'   => 'strasse',
      'mte'   => 'Monte',
      's'     => 'san',
    }
    # Detect the abbreviations to expand
    ReplacementsMatch = /\b(?:ch|chem|rte|bd|ave?|mte)(?:\.|\b)|\bs(?:\.|\b)(?!$)|\Bstr(?:\.|\b)/i


    NoCapitalize = {
      'auf'     => 'auf',
      'uf'      => 'uf',   # hurray for swiss german street names :D
      'em'      => 'em',
      'der'     => 'der',
      'die'     => 'die',
      'das'     => 'das',
      'von'     => 'von',
      'nach'    => 'nach',
      'im'      => 'im',
      'in'      => 'in',
      'zum'     => 'zum',
      'zur'     => 'zur',
      'unteren' => 'unteren',
      'oberen'  => 'oberen',

      'd'       => 'd',
      'de'      => 'de',
      'des'     => 'des',
      'du'      => 'du',
      'l'       => 'l',
      'le'      => 'le',
      'la'      => 'la',
      'les'     => 'les',
      'vers'    => 'vers',

      'il'      => 'il',
      'dei'     => 'dei',
      'di'      => 'di',
      'delle'   => 'delle',
      'della'   => 'della',
      'al'      => 'al',
      'alla'    => 'alla',
      'alle'    => 'alle',
      'ai'      => 'ai',
    }

    def self.normalize_street(street)
      return '' unless street

      street.strip.
        squeeze(' ').
        gsub(/\s*-\s*/, '-').
        gsub(/\A(#{FrontHouseNumber}) /, '\1, '). # '24 Rue Baulacre'     => '24, Rue Baulacre' - but not '24 bd blabla' -> '24 Boulevard, Blabla'
        gsub(/\s*([.,])(?=\S)/, '\1 ').           # '283,Rte.de Meyrin'   => '283, Rte. de Meyrin; '283 ,Foo' => '283, Foo'
        gsub(ReplacementsMatch) { |m|             # ch., chem., str. etc. => chemin, strasse etc.
          Replacements[m.downcase.chomp('.')]
        }.
        gsub(/\s*n°\s*/, ' ')
    end

    def self.normalize_name(name)
      name.
        gsub(/\b[\p{Letter}\p{Mark}\p{Connector_Punctuation}]{2,}\b/) { |word| NoCapitalize.fetch(word.downcase) { word.capitalize } }.
        sub(/\b[\p{Letter}\p{Mark}\p{Connector_Punctuation}]{2,}\b/) { |word| word.capitalize } # [\p{Letter}\p{Mark}\p{Connector_Punctuation}] is \p{Word} without digits
    end

    def self.normalize_number(number)
      return unless number
      normalized = number.downcase.delete('^0-9a-z/()-')

      normalized.empty? ? nil : normalized
    end

    def self.parse(street, normalize=false)
      normalized        = normalize_street(street)
      name, number, pos = case normalized
        when MatchStreetAndStreetNumberGerman then [$1, $2, :end]
        when MatchStreetAndStreetNumberFrench then [$2, $1, :begin]
        when MatchBrokenStreetAndNumberGerman then [$1, $2, :end]
        when MatchBrokenStreetAndNumberFrench then [$2, $1, :begin]
        else [normalized, nil, nil]
      end
      name    = normalize_name(name) if normalize
      number  = normalize_number(number) if normalize

      new(name, number, pos, street)
    end

    attr_reader :original, :name, :number, :number_position, :full

    def initialize(name, number=nil, number_position=:end, original=nil)
      @name             = name
      @number           = number
      @number_position  = number_position
      @original         = original
      @full             = case number_position
        when :end then [name, number].compact.join(" ")
        when :begin then [number, name].compact.join(", ")
        when nil then name.dup
        else raise ArgumentError, "Invalid value for number_position: #{number_position.inspect}"
      end
    end

    def original_or_full
      @original || @full
    end

    alias to_s full

    def inspect
      "#<Street #{self}>"
    end
  end
end
