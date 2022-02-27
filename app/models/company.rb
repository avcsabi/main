class Company < ApplicationRecord
  self.inheritance_column = 'sti_type'
  belongs_to :address, optional: true
  accepts_nested_attributes_for :address, reject_if: :all_blank

  validates :company_name, presence: true
  validates_uniqueness_of :company_number, message: '- a company with this number is already saved'
end
