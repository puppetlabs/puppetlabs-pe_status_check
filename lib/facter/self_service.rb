# frozen_string_literal: true

Facter.add(:self_service, type: :aggregate) do
  chunk(:check_1) do
    'check 1 is here'
  end

  chunk(:check_2) do
    'check 2 is here'
  end

  aggregate do |chunks|
    # The return value for this block determines the value of the fact.
    sum = 0
    chunks.each_value do |i|
      sum += i
    end

    sum
  end
end
