require 'rails_helper'

RSpec.describe RecordUploader do
  before :each do
    @uploaded = Rack::Test::UploadedFile.new(Rails.root.join('spec/files/blob.wav'), "audio/wav")
    @record = FactoryGirl.build(:record)
  end

  describe '#filename' do
    it 'should renamed to secure random value' do
      @record.file = @uploaded
      @record.save!

      expect(@record.file).not_to eq(@uploaded.original_filename)
    end
  end
end