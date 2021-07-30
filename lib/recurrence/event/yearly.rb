# frozen_string_literal: true

class Recurrence_
  module Event
    class Yearly < Base # :nodoc: all
      MONTHS = {
        "jan" => 1, "january" => 1,
        "feb" => 2, "february" => 2,
        "mar" => 3, "march" => 3,
        "apr" => 4, "april" => 4,
        "may" => 5,
        "jun" => 6, "june" => 6,
        "jul" => 7, "july" => 7,
        "aug" => 8, "august" => 8,
        "sep" => 9, "september" => 9,
        "oct" => 10, "october" => 10,
        "nov" => 11, "november" => 11,
        "dec" => 12, "december" => 12
      }.freeze

      private def validate
        if @options[:on].first.is_a?(Array)
          validated_dates = []
          @options[:on].each do |date|
            month = date.first
            day = date.last
            validated_dates << validate_date(month, day)
          end

          @options[:on] = validated_dates.sort_by do |date|
            # Using 32 because that'll guarantee its sorted last compared to other days in the month
            day = date.last.to_s == "last" ? 32 : date.last
            [date.first, day]
          end
        else
          month = @options[:on].first
          day = @options[:on].last
          validated_date = validate_date(month, day)
          @options[:on] = validated_date
        end

        @_date_pointer = 0
        @_date_count = @options[:on].first.is_a?(Array) ? @options[:on].length : 0
      end

      private def validate_date(month, day)
        valid_month_day?(day) unless day.to_s == "last"

        if month.is_a?(Numeric)
          valid_month?(month)
          return [month, day]
        end
        valid_month_name?(month)
        [MONTHS[month.to_s], day]
      end

      private def next_in_recurrence
        if initialized?
          advance(@date)
        else
          new_date = advance(@date, 0)
          new_date = advance(new_date) if @date > new_date
          @options[:handler].call(new_date.day, new_date.month, new_date.year)
        end
      end

      private def advance(date, interval = @options[:interval])
        if @options[:on].first.is_a?(Array)
          if initialized? && @_date_count > @_date_pointer += 1
            next_year = date.year
          else
            @_date_pointer = 0
            next_year = date.year + interval
          end
          next_month = @options[:on][@_date_pointer].first
          next_day   = parse_day(next_year, next_month,
                                 @options[:on][@_date_pointer].last)
        else
          next_year  = date.year + interval
          next_month = @options[:on].first
          next_day   = parse_day(next_year, next_month, @options[:on].last)
        end
        @options[:handler].call(next_day, next_month, next_year)
      end

      private def shift_to(date)
        @options[:on] = [date.month, date.day]
      end

      private def valid_month?(month)
        return if (1..12).cover?(month)

        raise ArgumentError, "invalid month #{month}"
      end

      private def valid_month_name?(month)
        return if MONTHS.key?(month.to_s)

        raise ArgumentError, "invalid month #{month}"
      end
    end
  end
end
