require 'test/unit'

require 'rubygems'
require 'active_support'
require 'action_controller'
require 'action_view'
require 'action_view/helpers'
require 'action_view/helpers/tag_helper'
require 'i18n'

begin
  require 'redgreen'
rescue LoadError
  puts "[!] Install redgreen gem for better test output ($ sudo gem install redgreen)"
end unless ENV["TM_FILEPATH"]

require 'localized_select'

class LocalizedSelectTest < Test::Unit::TestCase

  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::FormTagHelper

  def test_action_view_should_include_helper_for_object
    assert ActionView::Helpers::FormBuilder.instance_methods.include?('localized_select')
    assert ActionView::Helpers::FormOptionsHelper.instance_methods.include?('localized_select')
  end

  def test_action_view_should_include_helper_tag
    assert ActionView::Helpers::FormOptionsHelper.instance_methods.include?('localized_select_tag')
  end

  def test_should_return_select_tag_with_proper_name_for_object
    assert localized_select(:user, :entry, :entries) =~
              Regexp.new(Regexp.escape('<select id="user_entry" name="user[entry]">')),
              "Should have proper name for object"
  end

  def test_should_return_select_tag_with_proper_name
    assert localized_select_tag( "competition_submission[data][citizenship]", :entries, :nil) =~
              Regexp.new(
              Regexp.escape('<select id="competition_submission_data_citizenship" name="competition_submission[data][citizenship]">') ),
              "Should have proper name"
  end

  def test_should_return_option_tags
    assert localized_select(:user, :entry, :entries) =~ Regexp.new(Regexp.escape('<option value="FR">France</option>'))
  end

  def test_should_return_localized_option_tags
    I18n.locale = 'nl'
    assert localized_select(:user, :entry, :entries) =~ Regexp.new(Regexp.escape('<option value="FR">Frankrijk</option>'))
  end

  def test_should_return_priority_entries_first
    assert localized_options_for_select(:entries, :entry, [:FR, :AD]) =~ Regexp.new(
      Regexp.escape("<option value=\"FR\">France</option>\n<option value=\"AD\">Andorra</option><option value=\"\" disabled=\"disabled\">-------------</option>\n<option value=\"AD\">Andorra</option>\n"))
  end

  def test_i18n_should_know_about_entries
    assert_equal 'France', I18n.t('FR', :scope => 'entries')
    I18n.locale = 'nl'
    assert_equal 'Frankrijk', I18n.t('FR', :scope => 'entries')
  end

  def test_localized_entries_array_returns_correctly
    assert_nothing_raised { LocalizedSelect::localized_entries_array(:entries) }
    I18n.locale = 'en'
    assert_equal 7, LocalizedSelect::localized_entries_array(:entries).size
    assert_equal 'Andorra', LocalizedSelect::localized_entries_array(:entries).first[0]
    I18n.locale = 'nl'
    assert_equal 6, LocalizedSelect::localized_entries_array(:entries).size
    assert_equal 'Andorra', LocalizedSelect::localized_entries_array(:entries).first[0]
    I18n.locale = 'fr'
    assert_equal 3, LocalizedSelect::localized_entries_array(:entries).size
    assert_equal 'blank', LocalizedSelect::localized_entries_array(:entries).first[0]
  end

  def test_priority_entries_returns_correctly_and_in_correct_order
    assert_nothing_raised { LocalizedSelect::priority_entries_array(:entries,[:UK, :FR]) }
    I18n.locale = 'en'
    assert_equal [ ['United Kingdom', 'UK'], ['France', 'FR'] ], LocalizedSelect::priority_entries_array(:entries, [:UK, :FR])
  end

  def test_priority_entries_allows_passing_either_symbol_or_string
    I18n.locale = 'en'
    assert_equal [ ['United Kingdom', 'UK'], ['France', 'FR'] ], LocalizedSelect::priority_entries_array(:entries, ['UK', 'FR'])
  end

  def test_priority_entries_allows_passing_upcase_or_lowercase
    I18n.locale = 'en'
    assert_equal [ ['United Kingdom', 'UK'], ['France', 'FR'] ], LocalizedSelect::priority_entries_array(:entries,['uk', 'fr'])
    assert_equal [ ['United Kingdom', 'UK'], ['France', 'FR'] ], LocalizedSelect::priority_entries_array(:entries,[:uk, :fr])
  end

  def test_should_list_entries_with_accented_names_in_correct_order
    I18n.locale = 'nl'
    assert_match Regexp.new(Regexp.escape(%Q{<option value="BE">België</option>\n<option value="HV">Cézanne</option>})), localized_select(:user, :entry, :entries)
  end

  class User
    def entry_1
      return 1
    end
    def entry_bl
      return :bl
    end
    def entry_uk
      return 'UK'
    end
  end
  
  def test_with_user_symbol
    @user = User.new
    I18n.locale='fr'
    assert_match Regexp.new(Regexp.escape(%Q{<option value="bl" selected="selected">blank</option>})), localized_select(:user,:entry_bl,:entries)
  end

  def test_with_user_string
    @user = User.new
    I18n.locale='en'
    assert_match Regexp.new(Regexp.escape(%Q{<option value="UK" selected="selected">United Kingdom</option>})), localized_select(:user,:entry_uk,:entries)
  end
  def test_with_user_fixnum
    @user = User.new
    I18n.locale='en'
    assert_match Regexp.new(Regexp.escape(%Q{<option value="1" selected="selected">test</option>})), localized_select(:user,:entry_1,:entries)
  end


  private

  def setup
    $KCODE = 'u'
    ['nl', 'en'].each do |locale|
        I18n.load_path += Dir[ File.join(File.dirname(__FILE__), '..', 'locale', "#{locale}.yml") ]
    end
    I18n.load_path += Dir[ File.join(File.dirname(__FILE__), '..', 'locale', "fr.rb") ]
    I18n.locale = 'en'
  end

end
