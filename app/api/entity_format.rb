module EntityFormat
  module TimestampExposer
    def self.extended(base)
      base.format_with(:iso_timestamp) { |dt| dt.utc }

      base.with_options(format_with: :iso_timestamp) do
        base.expose :created_at
        base.expose :updated_at
      end
    end
  end
end