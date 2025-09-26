OmniAuth.configure do |c|
  c.test_mode = true
  c.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
    "provider" => "google_oauth2",
    "uid" => "100000000000000000000",
    "info" => {
      "name" => "test employee",
      "email" => "tester1@example.com",
      "image" => "https://example.com"
    }
  })
end
