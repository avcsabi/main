class Address < ApplicationRecord
  validate :not_blank

  def to_s
    %i[address_line_1 address_line_2 locality country postal_code].map{|f| self[f].presence}.compact.join(', ')
  end

  def not_blank
    %i[address_line_1 address_line_2 locality country postal_code].any?(&:present?)
  end

end
