require 'rails_helper'

RSpec.describe Record, type: :model do
  context "with no title" do
    subject { Record.new }
    it { is_expected.not_to be_valid }
  end

  context "with title" do
    subject { Record.new(title: "test title") }
    it { is_expected.to be_valid }
  end

  context "when deleted record is present" do
    before :each do
      3.times { FactoryGirl.create(:record) }
      # Need to implement soft delete
      # issue #52 (https://github.com/HwaYo/parrot/issues/52)
      Record.last.update_attributes!(deleted: true)
    end

    it "should show only remaining" do
      expect(Record.remaining.size).to eq(2)
    end
  end
end