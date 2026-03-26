require "test_helper"

class GuidanceTest < ActiveSupport::TestCase
  test "newborn bucket returns notes for 0-14 days" do
    notes = Guidance.for_age_in_days(1)
    assert_equal 2, notes.size
    assert notes.all? { |n| n.is_a?(String) && n.present? }
  end

  test "newborn bucket returns notes for exactly 14 days" do
    notes = Guidance.for_age_in_days(14)
    assert_equal 2, notes.size
  end

  test "early_weeks bucket returns notes for 15-42 days" do
    notes = Guidance.for_age_in_days(15)
    assert_equal 2, notes.size

    notes_at_42 = Guidance.for_age_in_days(42)
    assert_equal 2, notes_at_42.size
  end

  test "six_weeks bucket returns notes for 43-56 days" do
    notes = Guidance.for_age_in_days(43)
    assert_equal 2, notes.size
  end

  test "two_months bucket returns notes for 57-84 days" do
    notes = Guidance.for_age_in_days(57)
    assert_equal 2, notes.size
  end

  test "three_months bucket returns notes for 85-112 days" do
    notes = Guidance.for_age_in_days(85)
    assert_equal 2, notes.size
  end

  test "four_months bucket returns notes for 113-140 days" do
    notes = Guidance.for_age_in_days(113)
    assert_equal 2, notes.size
  end

  test "five_months bucket returns notes for 141-168 days" do
    notes = Guidance.for_age_in_days(141)
    assert_equal 2, notes.size
  end

  test "six_months bucket returns notes for 169-196 days" do
    notes = Guidance.for_age_in_days(169)
    assert_equal 2, notes.size
  end

  test "returns empty array for ages beyond defined buckets" do
    notes = Guidance.for_age_in_days(200)
    assert_empty notes
  end

  test "returns empty array for negative ages" do
    notes = Guidance.for_age_in_days(-1)
    assert_empty notes
  end

  test "never returns more than 2 notes" do
    bucket = Guidance::CONTENT[:newborn]
    original_notes = bucket[:notes].dup

    # Temporarily add more notes to test the limit
    bucket[:notes] = [
      "Note one",
      "Note two",
      "Note three",
      "Note four"
    ]

    notes = Guidance.for_age_in_days(1)
    assert_equal 2, notes.size
    assert_equal [ "Note one", "Note two" ], notes
  ensure
    bucket[:notes] = original_notes
  end

  test "bucket_for_age returns correct bucket" do
    assert_equal Guidance::CONTENT[:newborn], Guidance.bucket_for_age(7)
    assert_equal Guidance::CONTENT[:early_weeks], Guidance.bucket_for_age(21)
    assert_equal Guidance::CONTENT[:six_weeks], Guidance.bucket_for_age(50)
  end

  test "all buckets returns all bucket keys" do
    buckets = Guidance.all_buckets
    assert_includes buckets, :newborn
    assert_includes buckets, :early_weeks
    assert_includes buckets, :six_months
  end
end
