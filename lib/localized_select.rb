# = LocalizedSelect
# 
# View helper for displaying select list with localized entries:
# 
#     localized_select(:user, :category, :categories)
# 
#
# You can easily translate  codes in your application like this:
#     <%= I18n.t @user.category, :scope => 'categories' %>
# 
# Uses the Rails internationalization framework (I18n) for translating the names.
#
# Code adapted from localized_country_select plugin 
#
module LocalizedSelect
  class << self
    # Returns array with codes and localized names (according to <tt>I18n.locale</tt>)
    # for <tt><option></tt> tags
    # Avoid changing key to String if it is numeric.
    def localized_entries_array(localized_entries)
      I18n.translate(localized_entries).map { |key, value| [value, key.to_s ] }.
                                 sort_by { |entry| entry.first.parameterize }
    end
    # Return array with codes and localized names for array of codes passed as argument
    # == Example
    #   priority_entries_array([:TW, :CN])
    #   # => [ ['Taiwan', 'TW'], ['China', 'CN'] ]
    def priority_entries_array(localized_entries,codes=[])
      list = I18n.translate(localized_entries)
      codes.map { |code| [list[code.to_s.upcase.to_sym], code.to_s.upcase] }
    end
  end
end

module ActionView
  module Helpers

    module FormOptionsHelper

      # Return select and option tags for the given object and method, using +localized_options_for_select+
      # to generate the list of option tags. Uses <b> code</b>, not name as option +value+.
      #  codes listed as an array of symbols in +priority_countries+ argument will be listed first
      # TODO : Implement pseudo-named args with a hash, not the "somebody said PHP?" multiple args sillines
      def localized_select(object, method, localized_entries, priority_entries = nil, options = {}, html_options = {})
        tag = if defined?(ActionView::Helpers::InstanceTag) && ActionView::Helpers::InstanceTag.instance_method(:initialize).arity != 0
                InstanceTag.new(object, method, self, options.delete(:object))
              else
                Select.new(object, method, self, options)
              end
          tag.to_localized_select_tag(localized_entries, priority_entries, options, html_options).html_safe
      end

      # Return "named" select and option tags according to given arguments.
      # Use +selected_value+ for setting initial value
      # It behaves likes older object-binded brother +localized__select+ otherwise
      # TODO : Implement pseudo-named args with a hash, not the "somebody said PHP?" multiple args sillines
      def localized_select_tag(name, localized_entries, selected_value = nil, priority_entries = nil, html_options = {})
        select_tag(name.to_sym, localized_options_for_select(localized_entries, selected_value, priority_entries), html_options.stringify_keys).html_safe
      end

      # Returns a string of option tags according to locale. Supply the code in upper-case
      # as +selected+ to have it marked as the selected option tag.
      # codes listed as an array of symbols in +priority_entries+ argument will be listed first
      def localized_options_for_select(localized_entries, selected = nil, priority_entries = nil)
        entry_options = ""
        if priority_entries
          entry_options += options_for_select(LocalizedSelect::priority_entries_array(localized_entries, priority_entries), selected)
          entry_options += "<option value=\"\" disabled=\"disabled\">-------------</option>\n"
        end
        return (entry_options + options_for_select(LocalizedSelect::localized_entries_array(localized_entries), selected)).html_safe
      end
      
    end

    module ToLocalizedSelect
      def to_localized_select_tag(localized_entries,priority_entries, options, html_options)
        html_options = html_options.stringify_keys
        add_default_name_and_id(html_options)
        value = value(object).to_s
        content_tag("select",
          add_options(
            localized_options_for_select(localized_entries, value, priority_entries),
            options, value
          ), html_options
        ).html_safe
      end
    end

    if defined?(ActionView::Helpers::InstanceTag) && ActionView::Helpers::InstanceTag.instance_method(:initialize).arity != 0
      class InstanceTag
        include ToLocalizedSelect
      end
    else
      class Select < Tags::Base
        include ToLocalizedSelect
      end
    end
    
    class FormBuilder
      def localized_select(method,localized_entries, priority_entries = nil, options = {}, html_options = {})
        @template.localized_select(@object_name, method,localized_entries, priority_entries, options.merge(:object => @object), html_options)
      end
    end
  end
end