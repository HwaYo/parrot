Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, '358224821049631', '547e61dc5f766ef6ebf76d83e0eeac69', image_size: 'square'
end