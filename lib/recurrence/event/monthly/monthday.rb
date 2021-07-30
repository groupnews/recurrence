# frozen_string_literal: true

class Recurrence_
  module Event
    class Monthly < Base
      module Monthday
        def advance(date, interval = @options[:interval])
          if initialized? && @_day_count > @_day_pointer += 1
            next_year  = date.year
            next_month = date.month
          else
            @_day_pointer = 0

            # Have a raw month from 0 to 11 interval
            raw_month  = date.month + interval - 1

            next_year  = date.year + raw_month.div(12)
            next_month = (raw_month % 12) + 1 # change back to ruby interval
          end
          next_day = parse_day(next_year, next_month,
                               @options[:on][@_day_pointer])

          @options[:handler].call(
            next_day,
            next_month,
            next_year
          )
        end

        def validate_and_prepare!
          days = Array.wrap(@options[:on]).map do |day|
            valid_month_day?(day) unless day.to_s == "last"
            day
          end

          @options[:on] =
            days.grep(Integer).sort + days.grep(String) + days.grep(Symbol)

          valid_shift_options?

          if @options[:interval].is_a?(Symbol)
            valid_interval?(@options[:interval])
            @options[:interval] = INTERVALS[@options[:interval]]
          end

          @_day_pointer = 0
          @_day_count = @options[:on].length
        end

        def valid_shift_options?
          return unless @options[:shift] && @options[:on].length > 1

          raise ArgumentError,
                "Invalid options. Unable to use :shift with multiple :on days"
        end

        def shift_to(date)
          @options[:on][0] = date.day
        end
      end
    end
  end
end
