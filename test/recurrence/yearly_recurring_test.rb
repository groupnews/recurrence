# frozen_string_literal: true

require "test_helper"

class YearlyRecurringTest < Minitest::Test
  test "recurs until limit date" do
    r = Recurrence.yearly(on: [12, 31])
    assert_equal Date.parse("2037-12-31"), r.events[-1]
  end

  test "repeats until 7 years from now" do
    date = 7.years.from_now
    r = recurrence(
      every: :year,
      on: [date.month, date.day],
      until: date.to_date
    )
    assert_equal date.to_date, r.events[-1]
  end

  test "repeats through 7 years from now" do
    date = 7.years.from_now
    r = recurrence(
      every: :year,
      on: [date.month, date.day],
      through: date.to_date
    )
    assert_equal date.to_date, r.events[-1]
  end

  test "starts 2 years ago" do
    date = 2.years.ago
    r = recurrence(
      every: :year,
      on: [date.month, date.day],
      starts: date.to_date
    )
    assert_equal date.to_date, r.events[0]
  end

  test "starts at 2003-06-07 and repeat until 2018-06-07" do
    starts = Date.parse("2003-06-07")
    ends = Date.parse("2018-06-07")

    r = recurrence(
      every: :year,
      on: [starts.month, starts.day],
      starts: starts,
      until: ends
    )
    assert_equal "2003-06-07", r.events[0].to_s
    assert_equal "2018-06-07", r.events[-1].to_s
  end

  test "starts at 2003-06-07 and repeat through 2018-06-07" do
    starts = Date.parse("2003-06-07")
    ends = Date.parse("2018-06-07")

    r = recurrence(
      every: :year,
      on: [starts.month, starts.day],
      starts: starts,
      through: ends
    )
    assert_equal "2003-06-07", r.events[0].to_s
    assert_equal "2018-06-07", r.events[-1].to_s
  end

  test "uses interval" do
    starts = Date.parse("2008-09-21")

    r = recurrence(
      every: :year,
      on: [starts.month, starts.day],
      interval: 2,
      starts: starts
    )
    assert_equal "2008-09-21", r.events[0].to_s
    assert_equal "2010-09-21", r.events[1].to_s
    assert_equal "2012-09-21", r.events[2].to_s
    assert_equal "2014-09-21", r.events[3].to_s
  end

  test "uses repeat" do
    starts = Date.parse("2008-09-21")

    r = recurrence(
      every: :year,
      on: [starts.month, starts.day],
      starts: starts,
      repeat: 5
    )
    assert_equal 5, r.events.size
  end

  test "includes the through date when less than a perfect interval" do
    starts = Date.parse("2003-06-07")
    ends = Date.parse("2018-07-12")

    r = recurrence(
      every: :year,
      on: [starts.month, starts.day],
      starts: starts,
      through: ends
    )
    assert_equal "2019-06-07", r.events[-1].to_s
  end

  test "runs until next available date when chosen settings are greater than " \
       "start date" do
    starts = Date.parse("2008-09-03")

    r = recurrence(every: :year, on: [10, 27], starts: starts)
    assert_equal "2008-10-27", r.events[0].to_s
  end

  test "runs until next available date when chosen settings are smaller than " \
       "start date" do
    starts = Date.parse("2008-09-03")
    r = recurrence(every: :year, on: [7, 1], starts: starts)
    assert_equal "2009-07-01", r.events[0].to_s

    starts = Date.parse("2008-09-03")
    r = recurrence(every: :year, on: [9, 1], starts: starts)
    assert_equal "2009-09-01", r.events[0].to_s
  end

  test "uses except" do
    r = Recurrence.yearly(on: [12, 31],
                          except: "#{Time.now.year + 3}-12-31")

    assert r.events.include?("#{Time.now.year + 2}-12-31".to_date)
    refute r.events.include?("#{Time.now.year + 3}-12-31".to_date)
  end

  test "allows multiple days per year" do
    r = recurrence(
      every: :year,
      on: [[1, 15], [6, 15]],
      starts: "2021-06-01"
    )
    assert_equal "2022-01-15", r.events[0].to_s
    assert_equal "2022-06-15", r.events[1].to_s
    assert_equal "2023-01-15", r.events[2].to_s
    assert_equal "2023-06-15", r.events[3].to_s
  end
  
  test "uses :last correctly" do
    starts = Date.parse("2008-03-01")

    r = recurrence(
      every: :year,
      on: [7, :last],
      starts: starts
    )
    assert_equal "2008-07-31", r.events[0].to_s
    assert_equal "2009-07-31", r.events[1].to_s
    assert_equal "2010-07-31", r.events[2].to_s
  end
    
  test "uses :last correctly when multiple dates are defined" do
    starts = Date.parse("2008-03-01")

    r = recurrence(
      every: :year,
      on: [[7, 'last'], [12, :last]],
      starts: starts
    )
    assert_equal "2008-07-31", r.events[0].to_s
    assert_equal "2008-12-31", r.events[1].to_s
    assert_equal "2009-07-31", r.events[2].to_s
    assert_equal "2009-12-31", r.events[3].to_s
    assert_equal "2010-07-31", r.events[4].to_s
    assert_equal "2010-12-31", r.events[5].to_s
  end
  
  test ":last handles leap years correctly" do
    starts = Date.parse("2018-02-01")

    r = recurrence(
      every: :year,
      on: [2, :last],
      starts: starts
    )
    assert_equal "2018-02-28", r.events[0].to_s
    assert_equal "2019-02-28", r.events[1].to_s
    assert_equal "2020-02-29", r.events[2].to_s # Leap year
    assert_equal "2021-02-28", r.events[3].to_s
  end
end
