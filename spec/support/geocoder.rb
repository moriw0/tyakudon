Geocoder.configure(lookup: :test)

Geocoder::Lookup::Test.add_stub(
  '〒101-0023 東京都千代田区神田松永町16', [
    {
      'coordinates' => [35.7000396, 139.7752222]
    }
  ]
)
Geocoder::Lookup::Test.add_stub(
  'Tokyo', [
    {
      'coordinates' => [35.689, 139.692]
    }
  ]
)
Geocoder::Lookup::Test.add_stub(
  'Osaka', [
    {
      'coordinates' => [34.686, 135.520]
    }
  ]
)
Geocoder::Lookup::Test.add_stub(
  '東京都新宿区', [
    {
      'coordinates' => [35.6905, 139.6995]
    }
  ]
)
