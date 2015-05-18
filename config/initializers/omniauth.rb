Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, '369921866546593', '5d89571bfbdfbd2873a2b7be4bc809b7', image_size: 'square'
end