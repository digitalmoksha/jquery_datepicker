require 'date'

module JqueryDatepicker
  module FormHelper
    
    include ActionView::Helpers::JavaScriptHelper

    # Method that generates datepicker input field inside a form
    def datepicker(object_name, method, options = {})
      input_tag =  JqueryDatepicker::InstanceTag.new(object_name, method, self, options.delete(:object))
      dp_options, tf_options =  input_tag.split_options(options)
      tf_options[:value] = input_tag.format_date(tf_options[:value], String.new(dp_options[:dateFormat])) if  tf_options.has_key?(:value) && dp_options.has_key?(:dateFormat)
      html = input_tag.to_input_field_tag("text", tf_options)
      html += javascript_tag("jQuery(document).ready(function(){$('##{input_tag.get_name_and_id["id"]}').datepicker(#{dp_options.to_json})});")
      html.html_safe
    end

    # Method that generates datetimepicker input field inside a form
    def datetimepicker(object_name, method, options = {})
      input_tag =  JqueryDatepicker::InstanceTag.new(object_name, method, self, options.delete(:object))
      dp_options, tf_options =  input_tag.split_options(options, true);
      tf_options[:value] =  (input_tag.format_date(tf_options[:value], String.new(dp_options[:dateFormat])) if  tf_options.has_key?(:value) && dp_options.has_key?(:dateFormat)) +
                            (" " + input_tag.format_time(tf_options[:value], String.new(dp_options[:timeFormat]))) if  tf_options.has_key?(:value) && dp_options.has_key?(:timeFormat)
      html = input_tag.to_input_field_tag("text", tf_options)
      html += javascript_tag("jQuery(document).ready(function(){$('##{input_tag.get_name_and_id["id"]}').datetimepicker(#{dp_options.to_json})});")
      html.html_safe
    end

  end

end

module JqueryDatepicker::FormBuilder
  def datepicker(method, options = {})
    @template.datepicker(@object_name, method, objectify_options(options))
  end

  def datetimepicker(method, options = {})
    @template.datetimepicker(@object_name, method, objectify_options(options))
  end
end

class JqueryDatepicker::InstanceTag < ActionView::Helpers::InstanceTag

  FORMAT_REPLACEMENTES      = { "yy" => "%Y", "mm" => "%m", "MM" => "%B", "M" => "%b", "dd" => "%d", "d" => "%-d", "m" => "%-m", "y" => "%y" }
  FORMAT_TIME_REPLACEMENTES = { "hh" => "%I", "mm" => "%M", "TT" => "%P" }
  
  # Extending ActionView::Helpers::InstanceTag module to make Rails build the name and id
  # Just returns the options before generate the HTML in order to use the same id and name (see to_input_field_tag mehtod)
  
  def get_name_and_id(options = {})
    add_default_name_and_id(options)
    options
  end
  
  def available_datepicker_options
    [:disabled, :altField, :altFormat, :appendText, :autoSize, :buttonImage, :buttonImageOnly, :buttonText, :calculateWeek, :changeMonth, :changeYear, :closeText, :constrainInput, :currentText, :dateFormat, :dayNames, :dayNamesMin, :dayNamesShort, :defaultDate, :duration, :firstDay, :gotoCurrent, :hideIfNoPrevNext, :isRTL, :maxDate, :minDate, :monthNames, :monthNamesShort, :navigationAsDateFormat, :nextText, :numberOfMonths, :prevText, :selectOtherMonths, :shortYearCutoff, :showAnim, :showButtonPanel, :showCurrentAtPos, :showMonthAfterYear, :showOn, :showOptions, :showOtherMonths, :showWeek, :stepMonths, :weekHeader, :yearRange, :yearSuffix]
  end

  def available_datetimepicker_options
    [:ampm, :timeFormat, :seperator, :showHour, :showMinute, :showSecond, :showMillisec, :stepHour, :stepMinute, :stepSecond, :stepMillices, :hour, :minute, :second, :millisec, :hourMin,
      :hourMax, :minuteMin, :minuteMax, :secondMin, :secondMax, :millisecMin, :millisecMax, :timeOnlyTitle, :timeText, :hourText, :minuteText, 
      :secondText, :millisecText, :currentText, :closeText, :hourGrid, :minuteGrid, :secondGrid, :millisecGrid, :onSelect, :disabled, :altField, :altFormat, :appendText, :autoSize, :buttonImage, :buttonImageOnly, :buttonText, :calculateWeek, :changeMonth, :changeYear, :closeText, :constrainInput, :currentText, :dateFormat, :dayNames, :dayNamesMin, :dayNamesShort, :defaultDate, :duration, :firstDay, :gotoCurrent, :hideIfNoPrevNext, :isRTL, :maxDate, :minDate, :monthNames, :monthNamesShort, :navigationAsDateFormat, :nextText, :numberOfMonths, :prevText, :selectOtherMonths, :shortYearCutoff, :showAnim, :showButtonPanel, :showCurrentAtPos, :showMonthAfterYear, :showOn, :showOptions, :showOtherMonths, :showWeek, :stepMonths, :weekHeader, :yearRange, :yearSuffix]
  end
  
  def split_options(options, include_time = false)
    tf_options = include_time ? options.slice!(*available_datetimepicker_options) : options.slice!(*available_datepicker_options)
    return options, tf_options
  end

  def format_date(tb_formatted, format)
    new_format = translate_format(format)
    Date.parse(tb_formatted).strftime(new_format)
  end
  def format_time(tb_formatted, format)
    new_format = translate_time_format(format)
    DateTime.parse(tb_formatted).strftime(new_format)
  end

  # Method that translates the datepicker date formats, defined in (http://docs.jquery.com/UI/Datepicker/formatDate)
  # to the ruby standard format (http://www.ruby-doc.org/core-1.9.3/Time.html#method-i-strftime).
  # This gem is not going to support all the options, just the most used.

  def translate_format(format)
    format.gsub!(/#{FORMAT_REPLACEMENTES.keys.join("|")}/) { |match| FORMAT_REPLACEMENTES[match] }
  end
  def translate_time_format(format)
    format.gsub!(/#{FORMAT_TIME_REPLACEMENTES.keys.join("|")}/) { |match| FORMAT_TIME_REPLACEMENTES[match] }
  end
end